import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../providers/cart_provider.dart';

class Navbar extends StatelessWidget {
  final Function(String) onCategorySelected;
  final bool isGuest;
  final bool isAdmin;

  final VoidCallback? onAdd;
  final VoidCallback? onManage;
  final VoidCallback? onOrdersAdmin;
  final VoidCallback? onProfileAdmin;

  final VoidCallback? onProfileUser;
  final VoidCallback? onCart;
  final VoidCallback? onOrdersUser;

  const Navbar({
    super.key,
    required this.onCategorySelected,
    this.isAdmin = false,
    this.isGuest = false,
    this.onAdd,
    this.onManage,
    this.onOrdersAdmin,
    this.onProfileAdmin,
    this.onProfileUser,
    this.onCart,
    this.onOrdersUser,
  });

  @override
    Widget build(BuildContext context) {
      final width = MediaQuery.of(context).size.width;

      if (width < 768) {
        return _buildMobileNavbar(context);
      }
        return _buildDesktopNavbar(context);
    }

    Widget _buildDesktopNavbar(BuildContext context) {
      final cart = Provider.of<CartProvider>(context);
      final user = FirebaseAuth.instance.currentUser;
    return Container(
      height: 70,
      padding: const EdgeInsets.symmetric(horizontal: 25),
      color: Colors.black,
      child: Row(
        children: [
          Image.asset(
            "assets/images/logo-ibp.png",
            width: 40,
            height: 40,
          ),

          const SizedBox(width: 10),

          const Text(
            "ISTANA BOWLING PROSHOP",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),

          const SizedBox(width: 30),

          _menu("All", () => onCategorySelected("All")),
          _menu("Balls", () => onCategorySelected("Ball")),
          _menu("Shoes", () => onCategorySelected("Shoes")),
          _menu("Bags", () => onCategorySelected("Bag")),
          _menu("Accessories",
              () => onCategorySelected("Accessories")),

          const Spacer(),

          // ================= USER MODE =================
          if (!isAdmin) ...[
            // CART BADGE
            Stack(
              children: [
                IconButton(
                  icon: const Icon(Icons.shopping_cart,
                      color: Colors.white),
                  onPressed: onCart,
                  tooltip: "Keranjang",
                ),
                if (cart.items.isNotEmpty)
                  Positioned(
                    right: 6,
                    top: 6,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        cart.items.length.toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                        ),
                      ),
                    ),
                  ),
              ],
            ),

            const SizedBox(width: 10),

            // USER ORDERS BADGE
            if (isGuest)
              IconButton(
                icon: const Icon(
                  Icons.receipt_long,
                  color: Colors.white,
                ),
                onPressed: onOrdersUser,
              )
            else
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('orders')
                    .where(
                      'customerEmail',
                      isEqualTo: user?.email?.trim().toLowerCase(),
                    )
                    .snapshots(),
              builder: (context, snapshot) {
                int count = 0;

                  if (snapshot.hasData) {
                    count = snapshot.data!.docs.where((doc) {
                      final data = doc.data() as Map<String, dynamic>;

                      final status =
                          (data['status'] ?? '').toString();

                      return status != 'Selesai' &&
                          status != 'Dibatalkan';
                    }).length;
                  }

                return Stack(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.receipt_long,
                          color: Colors.white),
                      onPressed: onOrdersUser,
                      tooltip: "Pesanan Saya",
                    ),
                    if (count > 0)
                      Positioned(
                        right: 6,
                        top: 6,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: Colors.blue,
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            count.toString(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                            ),
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),

            const SizedBox(width: 10),

            IconButton(
              icon: const Icon(Icons.person,
                  color: Colors.white),
              onPressed: onProfileUser,
              tooltip: "Profil",
            ),
          ],

          // ================= ADMIN MODE =================
          if (isAdmin)
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('orders')
                  .where('status', whereNotIn: [
                    'Selesai',
                    'Dibatalkan'
                  ])
                  .snapshots(),
              builder: (context, snapshot) {
                int pending = snapshot.data?.docs.length ?? 0;

                return Stack(
                  children: [
                    PopupMenuButton<String>(
                      icon: const Icon(Icons.menu,
                          color: Colors.white),
                      onSelected: (value) {
                        switch (value) {
                          case "add":
                            onAdd?.call();
                            break;
                          case "manage":
                            onManage?.call();
                            break;
                          case "orders":
                            onOrdersAdmin?.call();
                            break;
                          case "profile":
                            onProfileAdmin?.call();
                            break;
                        }
                      },
                      itemBuilder: (context) => const [
                        PopupMenuItem(
                            value: "add",
                            child: Text("Tambah Produk")),
                        PopupMenuItem(
                            value: "manage",
                            child: Text("Kelola Produk")),
                        PopupMenuItem(
                            value: "orders",
                            child: Text("Kelola Pesanan")),
                        PopupMenuItem(
                            value: "profile",
                            child: Text("Profil Admin")),
                      ],
                    ),

                    // ADMIN BADGE
                    if (pending > 0)
                      Positioned(
                        right: 0,
                        top: 0,
                        child: Container(
                          padding: const EdgeInsets.all(5),
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            pending.toString(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
        ],
      ),
    );
  }
  Widget _buildMobileNavbar(BuildContext context) {
    final cart = Provider.of<CartProvider>(context);

    return Container(
      height: 70,
      padding: const EdgeInsets.symmetric(horizontal: 15),
      color: Colors.black,
      child: Row(
        children: [
          Image.asset(
            "assets/images/logo-ibp.png",
            width: 35,
            height: 35,
          ),

          const SizedBox(width: 10),

          const Expanded(
            child: Text(
              "Istana Bowling Proshop",
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          // CART
          Stack(
            children: [
              IconButton(
                icon: const Icon(
                  Icons.shopping_cart,
                  color: Colors.white,
                ),
                onPressed: onCart,
              ),

              if (cart.items.isNotEmpty)
                Positioned(
                  right: 5,
                  top: 5,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      cart.items.length.toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                      ),
                    ),
                  ),
                ),
            ],
          ),

          PopupMenuButton<String>(
            icon: const Icon(
              Icons.menu,
              color: Colors.white,
            ),
            onSelected: (value) {
              if (isAdmin) {
                switch (value) {
                  case "All":
                  case "Ball":
                  case "Shoes":
                  case "Bag":
                  case "Accessories":
                    onCategorySelected(value);
                    break;

                  case "add":
                    onAdd?.call();
                    break;

                  case "manage":
                    onManage?.call();
                    break;

                  case "ordersAdmin":
                    onOrdersAdmin?.call();
                    break;

                  case "profileAdmin":
                    onProfileAdmin?.call();
                    break;
                }
              } else {
                switch (value) {
                  case "All":
                  case "Ball":
                  case "Shoes":
                  case "Bag":
                  case "Accessories":
                    onCategorySelected(value);
                    break;

                  case "orders":
                    onOrdersUser?.call();
                    break;

                  case "profile":
                    onProfileUser?.call();
                    break;
                }
              }
            },
            itemBuilder: (context) {
              if (isAdmin) {
                return [
                  const PopupMenuItem(
                    value: "All",
                    child: Text("All Products"),
                  ),
                  const PopupMenuItem(
                    value: "Ball",
                    child: Text("Balls"),
                  ),
                  const PopupMenuItem(
                    value: "Shoes",
                    child: Text("Shoes"),
                  ),
                  const PopupMenuItem(
                    value: "Bag",
                    child: Text("Bags"),
                  ),
                  const PopupMenuItem(
                    value: "Accessories",
                    child: Text("Accessories"),
                  ),
                  const PopupMenuDivider(),
                  const PopupMenuItem(
                    value: "add",
                    child: Text("Tambah Produk"),
                  ),
                  const PopupMenuItem(
                    value: "manage",
                    child: Text("Kelola Produk"),
                  ),
                  const PopupMenuItem(
                    value: "ordersAdmin",
                    child: Text("Kelola Pesanan"),
                  ),
                  const PopupMenuItem(
                    value: "profileAdmin",
                    child: Text("Profil Admin"),
                  ),
                ];
              }

              return [
                const PopupMenuItem(
                  value: "All",
                  child: Text("All Products"),
                ),
                const PopupMenuItem(
                  value: "Ball",
                  child: Text("Balls"),
                ),
                const PopupMenuItem(
                  value: "Shoes",
                  child: Text("Shoes"),
                ),
                const PopupMenuItem(
                  value: "Bag",
                  child: Text("Bags"),
                ),
                const PopupMenuItem(
                  value: "Accessories",
                  child: Text("Accessories"),
                ),
                const PopupMenuDivider(),
                const PopupMenuItem(
                  value: "orders",
                  child: Text("Pesanan Saya"),
                ),
                const PopupMenuItem(
                  value: "profile",
                  child: Text("Profil"),
                ),
              ];
            },
          )
        ],
      ),
    );
  }

  Widget _menu(String text, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Text(
          text,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 15,
          ),
        ),
      ),
    );
  }
}