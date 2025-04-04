class OrderItem {
  final int id;
  final int productId;
  final String productName;
  final String productImageUrl;
  final double price;
  final int quantity;

  OrderItem({
    required this.id,
    required this.productId,
    required this.productName,
    required this.productImageUrl,
    required this.price,
    required this.quantity,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      id: json['id'] ?? 0,
      productId: json['productId'] ?? 0,
      productName: json['productName'] ?? 'Unknown Product',
      productImageUrl: json['productImageUrl'] ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      quantity: json['quantity'] ?? 0,
    );
  }
}
