class Product {
  final int id;
  final String name;
  final String description;
  final double price;
  final int quantity;
  final String imageUrl;
  final List<int> categoryIds;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.quantity,
    required this.imageUrl,
    required this.categoryIds,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      price: json['price'],
      quantity: json['quantity'],
      imageUrl: json['imageUrl'],
      categoryIds: List<int>.from(json['categoryIds']),
    );
  }
}
