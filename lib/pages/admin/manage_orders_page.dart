import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/product.dart';

class ManageOrdersPage extends StatefulWidget {
  const ManageOrdersPage({super.key});

  @override
  State<ManageOrdersPage> createState() => _ManageOrdersPageState();
}

class _ManageOrdersPageState extends State<ManageOrdersPage> {
    final TextEditingController searchController =
      TextEditingController();

  String searchText = "";
  static const List<String> statuses = [
    "Menunggu Pembayaran",
    "Diproses",
    "Pre Order",
    "Dikirim",
    "Selesai",
    "Dibatalkan",
  ];

  String formatRupiah(int value) {
    return "Rp ${value.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (m) => '${m[1]}.',
    )}";
  }

  bool isLocked(String status) {
    return status == "Selesai" || status == "Dibatalkan";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.black,
        onPressed: () => _showAddOrderDialog(context),
        child: const Icon(Icons.add, color: Colors.white),
      ),

      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: const Text("Kelola Pesanan"),
      ),

      body: Column(
        children: [

          Padding(
            padding: const EdgeInsets.all(10),
            child: TextField(
              controller: searchController,
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.search),
                hintText: "Cari nama customer...",
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() {
                  searchText = value.toLowerCase();
                });
              },
            ),
          ),

          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('orders')
                  .orderBy('createdAt', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {

                if (!snapshot.hasData) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                final orders = snapshot.data!.docs;

                final filteredOrders = orders.where((doc) {
                  final data =
                      doc.data() as Map<String, dynamic>;

                  final name =
                      (data['customerName'] ?? '')
                          .toString()
                          .toLowerCase();

                  return name.contains(searchText);
                }).toList();

                if (filteredOrders.isEmpty) {
                  return const Center(
                    child: Text("Data tidak ditemukan"),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: filteredOrders.length,
                  itemBuilder: (context, index) {

                    final doc = filteredOrders[index];

                    final data =
                        doc.data() as Map<String, dynamic>;

                    final items =
                        (data['items'] as List?) ?? [];

                    final total =
                        data['totalPrice'] ?? 0;

                    final locked =
                        isLocked(data['status']);

                    return Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [

                            Text(
                              data['customerName'] ?? '-',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight:
                                    FontWeight.bold,
                              ),
                            ),

                            Text(
                              "Email: ${data['customerEmail'] ?? '-'}",
                            ),

                            Text(
                              "No HP: ${data['phone']}",
                            ),

                            Text(
                              "Alamat: ${data['address']}",
                            ),

                            Text(
                              "Tanggal: ${data['orderDate'] ?? '-'}",
                            ),

                            if ((data['preOrderDays'] ?? 0) > 0)
                              Text(
                                "Pre Order: ${data['preOrderDays']} hari",
                                style: const TextStyle(
                                  color: Colors.orange,
                                ),
                              ),

                            const Divider(),

                            ...items.map((e) {
                              return ListTile(
                                leading: e['image'] != null
                                    ? Image.memory(
                                        base64Decode(
                                          e['image'],
                                        ),
                                        width: 40,
                                        height: 40,
                                        fit: BoxFit.cover,
                                      )
                                    : const Icon(
                                        Icons.image,
                                      ),
                                title:
                                    Text(e['name']),
                                subtitle: Text(
                                  "${e['variant']} | ${formatRupiah(e['price'])}",
                                ),
                                trailing: Text(
                                  "x${e['qty']}",
                                ),
                              );
                            }),

                            const SizedBox(height: 10),

                            Text(
                              "TOTAL: ${formatRupiah(total)}",
                              style: const TextStyle(
                                color: Colors.green,
                                fontWeight:
                                    FontWeight.bold,
                              ),
                            ),

                            const SizedBox(height: 10),

                            DropdownButton<String>(
                              value: data['status'],
                              isExpanded: true,
                              items: statuses.map((e) {
                                return DropdownMenuItem(
                                  value: e,
                                  child: Text(e),
                                );
                              }).toList(),
                              onChanged: locked
                                  ? null
                                  : (val) {
                                      FirebaseFirestore
                                          .instance
                                          .collection(
                                              'orders')
                                          .doc(doc.id)
                                          .update({
                                        'status': val
                                      });
                                    },
                            ),
                            const SizedBox(height: 10),

                              if (!locked)
                                Row(
                                  children: [

                                    Expanded(
                                      child: ElevatedButton.icon(
                                        icon: const Icon(Icons.edit),
                                        label: const Text("Edit"),
                                        onPressed: () {
                                          _showEditOrderDialog(
                                            context,
                                            doc.id,
                                            data,
                                          );
                                        },
                                      ),
                                    ),

                                    const SizedBox(width: 10),

                                    Expanded(
                                      child: ElevatedButton.icon(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.red,
                                          foregroundColor: Colors.white,
                                        ),
                                        icon: const Icon(Icons.delete),
                                        label: const Text("Hapus"),
                                        onPressed: () async {

                                          final confirm =
                                              await showDialog<bool>(
                                            context: context,
                                            builder: (_) {
                                              return AlertDialog(
                                                title: const Text(
                                                  "Hapus Pesanan",
                                                ),
                                                content: const Text(
                                                  "Yakin ingin menghapus pesanan ini?",
                                                ),
                                                actions: [

                                                  TextButton(
                                                    onPressed: () =>
                                                        Navigator.pop(
                                                          context,
                                                          false,
                                                        ),
                                                    child: const Text(                                                
                                                      "Batal",
                                                    ),
                                                  ),

                                                  ElevatedButton(
                                                    style:
                                                        ElevatedButton.styleFrom(
                                                      backgroundColor:
                                                          Colors.red,
                                                    ),
                                                    onPressed: () =>
                                                        Navigator.pop(
                                                          context,
                                                          true,
                                                        ),
                                                    child: const Text(
                                                      style: TextStyle(color: Colors.white),
                                                      "Hapus",
                                                    ),
                                                  ),
                                                ],
                                              );
                                            },
                                          );

                                          if (confirm == true) {
                                            await FirebaseFirestore
                                                .instance
                                                .collection('orders')
                                                .doc(doc.id)
                                                .delete();
                                          }
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showAddOrderDialog(BuildContext context) {
    final name = TextEditingController();
    final email = TextEditingController();
    final phone = TextEditingController();
    final address = TextEditingController();
    final orderDate = TextEditingController();

    List<Map<String, dynamic>> cart = [];
    int preOrderDays = 0;
    String selectedStatus = "Menunggu Pembayaran";

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text("Buat Order"),
              content: SizedBox(
                width: 500,
                child: SingleChildScrollView(
                  child: Column(
                    children: [

                      /// FORM CUSTOMER
                      TextField(
                        controller: name,
                        decoration: const InputDecoration(
                          labelText: "Nama Customer",
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 10),

                      TextField(
                        controller: email,
                        decoration: const InputDecoration(
                          labelText: "Email Pembeli",
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 10),

                      TextField(
                        controller: phone,
                        decoration: const InputDecoration(
                          labelText: "Nomor Telepon",
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 10),

                      TextField(
                        controller: address,
                        decoration: const InputDecoration(
                          labelText: "Alamat",
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 10),

                      TextField(
                        controller: orderDate,
                        decoration: const InputDecoration(
                          labelText: "Tanggal Order",
                          hintText: "01/06/2026",
                          border: OutlineInputBorder(),
                        ),
                      ),

                      const SizedBox(height: 15),

                      DropdownButton<String>(
                        value: selectedStatus,
                        isExpanded: true,
                        items: statuses.map((e) {
                          return DropdownMenuItem(
                            value: e,
                            child: Text(e),
                          );
                        }).toList(),
                        onChanged: (val) {
                          setState(() {
                            selectedStatus = val!;
                          });
                        },
                      ),

                      if (selectedStatus == "Pre Order")
                        TextField(
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: "Jumlah Hari",
                            border: OutlineInputBorder(),
                          ),
                          onChanged: (val) {
                            preOrderDays = int.tryParse(val) ?? 0;
                          },
                        ),

                      const Divider(),

                      /// LIST PRODUK
                      StreamBuilder<QuerySnapshot>(
                        stream: FirebaseFirestore.instance.collection('products').snapshots(),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) {
                            return const CircularProgressIndicator();
                          }

                          final products = snapshot.data!.docs;

                          return SizedBox(
                            height: 300,
                            child: ListView.builder(
                              itemCount: products.length,
                              itemBuilder: (context, i) {
                                final data = products[i].data() as Map<String, dynamic>;
                                final product = Product.fromFirestore(data, products[i].id);

                                String? selectedVariant;

                                return StatefulBuilder(
                                  builder: (context, setStateLocal) {
                                    return Card(
                                      margin: const EdgeInsets.only(bottom: 10),
                                      child: Padding(
                                        padding: const EdgeInsets.all(8),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [

                                            /// IMAGE + NAME
                                            Row(
                                              children: [
                                                product.imageBase64.isNotEmpty
                                                    ? Image.memory(
                                                        base64Decode(product.imageBase64),
                                                        width: 50,
                                                        height: 50,
                                                        fit: BoxFit.cover,
                                                      )
                                                    : const Icon(Icons.image),

                                                const SizedBox(width: 10),

                                                Expanded(
                                                  child: Text(
                                                    product.name,
                                                    style: const TextStyle(
                                                      fontWeight: FontWeight.bold,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),

                                            const SizedBox(height: 5),

                                            Text(formatRupiah(product.price)),

                                            const SizedBox(height: 8),

                                            /// VARIANT PICKER (WAJIB PILIH DULU)
                                            if (product.variants.isNotEmpty)
                                              Wrap(
                                                spacing: 6,
                                                children: product.variants.map((v) {
                                                  final isSelected = selectedVariant == v;

                                                  return ChoiceChip(
                                                    label: Text(v),
                                                    selected: isSelected,
                                                    onSelected: (_) {
                                                      setStateLocal(() {
                                                        selectedVariant = v;
                                                      });
                                                    },
                                                  );
                                                }).toList(),
                                              )
                                            else
                                              const Text("No variant"),

                                            const SizedBox(height: 10),

                                            /// ADD BUTTON (INI YANG KAMU KURANG)
                                            ElevatedButton(
                                              onPressed: () {
                                                setState(() {
                                                  final variant = selectedVariant ??
                                                      (product.variants.isNotEmpty
                                                          ? product.variants.first
                                                          : "-");

                                                  final index = cart.indexWhere((item) =>
                                                      item['id'] == product.id &&
                                                      item['variant'] == variant);

                                                  if (index != -1) {
                                                    cart[index]['qty']++;
                                                  } else {
                                                    cart.add({
                                                      'id': product.id,
                                                      'name': product.name,
                                                      'price': product.price,
                                                      'qty': 1,
                                                      'variant': variant,
                                                      'image': product.imageBase64,
                                                    });
                                                  }
                                                });
                                              },
                                              child: const Text("Add to Cart"),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                );
                              },
                            ),
                          );
                        },
                      ),

                      const Divider(),

                      /// CART
                      ...cart.map((e) {
                        return ListTile(
                          title: Text(e['name']),
                          subtitle: Text(
                            "${e['variant']} | ${formatRupiah(e['price'])}",
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.remove),
                                onPressed: () {
                                  setState(() {
                                    e['qty']--;
                                    if (e['qty'] <= 0) {
                                      cart.remove(e);
                                    }
                                  });
                                },
                              ),
                              Text("${e['qty']}"),
                              IconButton(
                                icon: const Icon(Icons.add),
                                onPressed: () {
                                  setState(() {
                                    e['qty']++;
                                  });
                                },
                              ),
                            ],
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              ),

              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Batal"),
                ),

                ElevatedButton(
                  onPressed: () async {
                    int total = cart.fold(
                      0,
                      (sum, item) =>
                          sum + (item['price'] * item['qty']) as int,
                    );

                    await FirebaseFirestore.instance
                        .collection('orders')
                        .add({
                      'customerName': name.text,
                      'customerEmail': email.text.trim().toLowerCase(),
                      'phone': phone.text,
                      'address': address.text,
                      'orderDate': orderDate.text,
                      'items': cart,
                      'totalPrice': total,
                      'status': selectedStatus,
                      'preOrderDays':
                          selectedStatus == "Pre Order"
                              ? preOrderDays
                              : 0,
                      'createdAt':
                          FieldValue.serverTimestamp(),
                    });

                    Navigator.pop(context);
                  },
                  child: const Text("Simpan"),
                ),
              ],
            );
          },
        );
      },
    );
  }
  void _showEditOrderDialog(
    BuildContext context,
    String docId,
    Map<String, dynamic> data,
  ) {

    final cart = List<Map<String, dynamic>>.from(
      (data['items'] ?? []).map(
        (e) => Map<String, dynamic>.from(e),
      ),
    );

    final nameController =
        TextEditingController(text: data['customerName']);

    final emailController =
    TextEditingController(
      text: data['customerEmail'] ?? '',
    );

    final phoneController =
        TextEditingController(text: data['phone']);

    final addressController =
        TextEditingController(text: data['address']);

    String status = data['status'];

    int preOrderDays =
        data['preOrderDays'] ?? 0;

    final preOrderController =
    TextEditingController(
      text: preOrderDays.toString(),
    );

    showDialog(
      context: context,
      builder: (_) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text("Edit Pesanan"),

              content: SizedBox(
                width: 450,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [

                      TextField(
                        controller: nameController,
                        decoration:
                            const InputDecoration(
                          labelText: "Nama Customer",
                          border: OutlineInputBorder(),
                        ),
                      ),

                      const SizedBox(height: 10),

                      TextField(
                        controller: emailController,
                        decoration: 
                            const InputDecoration(
                          labelText: "Email Pembeli",
                          border: OutlineInputBorder(),
                        ),
                      ),

                      const SizedBox(height: 10),

                      TextField(
                        controller: phoneController,
                        decoration:
                            const InputDecoration(
                          labelText: "Nomor Telepon",
                          border: OutlineInputBorder(),
                        ),
                      ),

                      const SizedBox(height: 10),

                      TextField(
                        controller: addressController,
                        decoration:
                            const InputDecoration(
                          labelText: "Alamat",
                          border: OutlineInputBorder(),
                        ),
                      ),

                      const SizedBox(height: 10),

                      DropdownButtonFormField<String>(
                        value: status,
                        decoration:
                            const InputDecoration(
                          border: OutlineInputBorder(),
                        ),
                        items: statuses.map((e) {
                          return DropdownMenuItem(
                            value: e,
                            child: Text(e),
                          );
                        }).toList(),
                        onChanged: (v) {
                          setState(() {
                            status = v!;
                          });
                        },
                      ),

                      const SizedBox(height: 10),

                      const SizedBox(height: 10),

                        if (status == "Pre Order")
                          TextField(
                            controller: preOrderController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: "Jumlah Hari Pre Order",
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.schedule),
                            ),
                            onChanged: (value) {
                              preOrderDays =
                                  int.tryParse(value) ?? 0;
                            },
                          ),

                        const SizedBox(height: 10),

                      const Divider(),

StreamBuilder<QuerySnapshot>(
  stream: FirebaseFirestore.instance
      .collection('products')
      .snapshots(),
  builder: (context, snapshot) {
    if (!snapshot.hasData) {
      return const CircularProgressIndicator();
    }

    final products = snapshot.data!.docs;

    return SizedBox(
      height: 300,
      child: ListView.builder(
        itemCount: products.length,
        itemBuilder: (context, i) {
          final data =
              products[i].data() as Map<String, dynamic>;

          final product = Product.fromFirestore(
            data,
            products[i].id,
          );

          String? selectedVariant;

          return StatefulBuilder(
            builder: (
              context,
              setStateLocal,
            ) {
              return Card(
                margin: const EdgeInsets.only(
                  bottom: 10,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [

                      Row(
                        children: [
                          product.imageBase64.isNotEmpty
                              ? Image.memory(
                                  base64Decode(
                                    product.imageBase64,
                                  ),
                                  width: 50,
                                  height: 50,
                                  fit: BoxFit.cover,
                                )
                              : const Icon(Icons.image),

                          const SizedBox(width: 10),

                          Expanded(
                            child: Text(
                              product.name,
                              style:
                                  const TextStyle(
                                fontWeight:
                                    FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 5),

                      Text(
                        formatRupiah(
                          product.price,
                        ),
                      ),

                      const SizedBox(height: 8),

                      if (product
                          .variants.isNotEmpty)
                        Wrap(
                          spacing: 6,
                          children:
                              product.variants.map(
                            (v) {
                              final isSelected =
                                  selectedVariant ==
                                      v;

                              return ChoiceChip(
                                label: Text(v),
                                selected:
                                    isSelected,
                                onSelected: (_) {
                                  setStateLocal(
                                    () {
                                      selectedVariant =
                                          v;
                                    },
                                  );
                                },
                              );
                            },
                          ).toList(),
                        ),

                      const SizedBox(height: 10),

                      ElevatedButton(
                        onPressed: () {
                          setState(() {

                            final variant =
                                selectedVariant ??
                                    (product.variants
                                            .isNotEmpty
                                        ? product
                                            .variants
                                            .first
                                        : "-");

                            final index = cart.indexWhere(
                              (item) =>
                                  item['id'] ==
                                      product.id &&
                                  item['variant'] ==
                                      variant,
                            );

                            if (index != -1) {
                              cart[index]['qty']++;
                            } else {
                              cart.add({
                                'id':
                                    product.id,
                                'name':
                                    product.name,
                                'price':
                                    product.price,
                                'qty': 1,
                                'variant':
                                    variant,
                                'image':
                                    product.imageBase64,
                              });
                            }
                          });
                        },
                        child: const Text(
                          "Add To Cart",
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  },
),

                    const Divider(),

                    ...cart.map((e) {
                      return ListTile(
                        title: Text(e['name']),
                        subtitle: Text(
                          "${e['variant']} | ${formatRupiah(e['price'])}",
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [

                            IconButton(
                              icon: const Icon(Icons.remove),
                              onPressed: () {
                                setState(() {
                                  e['qty']--;

                                  if (e['qty'] <= 0) {
                                    cart.remove(e);
                                  }
                                });
                              },
                            ),

                            Text("${e['qty']}"),

                            IconButton(
                              icon: const Icon(Icons.add),
                              onPressed: () {
                                setState(() {
                                  e['qty']++;
                                });
                              },
                            ),
                          ],
                        ),
                      );
                    }),
                    ],
                  ),
                ),
              ),

              actions: [

                TextButton(
                  onPressed: () =>
                      Navigator.pop(context),
                  child: const Text("Batal"),
                ),

                ElevatedButton(
                  onPressed: () async {

                    int total = cart.fold(
                      0,
                      (sum, item) =>
                          sum +
                          ((item['price'] as int) *
                              (item['qty'] as int)),
                    );

                    await FirebaseFirestore.instance
                      .collection('orders')
                      .doc(docId)
                      .update({

                    'customerName':
                        nameController.text,

                    'customerEmail':
                        emailController.text
                            .trim()
                            .toLowerCase(),

                    'phone':
                        phoneController.text,

                    'address':
                        addressController.text,

                    'status':
                        status,

                    'preOrderDays':
                      status == "Pre Order"
                          ? int.tryParse(
                                preOrderController.text,
                              ) ??
                              0
                          : 0,

                    'items':
                        cart,

                    'totalPrice':
                        total,
                  });

                    Navigator.pop(context);
                  },
                  child: const Text("Simpan"),
                )
              ],
            );
          },
        );
      },
    );
  }
}