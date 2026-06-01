class Product {
  final String id;
  final String name;
  final int price;
  final String description;
  final String imageBase64;
  final String category;
  final List<String> variants;

  Product({
    required this.id,
    required this.name,
    required this.price,
    required this.description,
    required this.imageBase64,
    required this.category,
    required this.variants,
  });

  factory Product.fromFirestore(
    Map<String, dynamic> data,
    String id,
  ) {
    return Product(
      id: id,
      name: data['name'] ?? '',
      price: data['price'] ?? 0,
      description: data['description'] ?? '',
      imageBase64: data['imageBase64'] ?? '',
      category: data['category'] ?? 'Balls',
      variants: List<String>.from(
        data['variants'] ?? [],
      ),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'price': price,
      'description': description,
      'imageBase64': imageBase64,
      'category': category,
      'variants': variants,
    };
  }
}