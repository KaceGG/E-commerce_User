class CartItem {
  final int id;
  final int productId;
  final String productName;
  final String productImageUrl;
  final double productPrice;
  final int quantity;

  CartItem({
    required this.id,
    required this.productId,
    required this.productName,
    required this.productImageUrl,
    required this.productPrice,
    required this.quantity,
  });

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      id: json['id'],
      productId: json['productId'],
      productName: json['productName'],
      productImageUrl: json['productImageUrl'],
      productPrice: json['productPrice'].toDouble(),
      quantity: json['quantity'],
    );
  }
}
