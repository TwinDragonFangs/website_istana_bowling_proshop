import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/product.dart';

class FirebaseService {
  final _db = FirebaseFirestore.instance;

  Future<List<Product>> getProducts() async {
    Future<List<Product>>
    getProductsByCategory(
      String category,
    ) async {

      final snapshot =
          await _db
              .collection('products')
              .where(
                'category',
                isEqualTo: category,
              )
              .get();

      return snapshot.docs.map((doc) {

        return Product.fromFirestore(
          doc.data(),
          doc.id,
        );

      }).toList();
    }
    final snapshot =
        await _db.collection('products').get();

    return snapshot.docs.map((doc) {
      return Product.fromFirestore(
        doc.data(),
        doc.id,
      );
    }).toList();
  }
}