import 'package:ecommerce_user/models/product_model.dart';

class Cart {
  final int id;
  final List<CartItem> cartItems;
  final double totalPrice;

  Cart({
    required this.id,
    required this.cartItems,
    required this.totalPrice,
  });

  factory Cart.fromJson(Map<String, dynamic> json) {
    return Cart(
      id: json['id'] as int,
      cartItems: (json['cartItems'] as List)
          .map((item) => CartItem.fromJson(item as Map<String, dynamic>))
          .toList(),
      totalPrice: (json['totalPrice'] as num).toDouble(),
    );
  }
}

class CartItem {
  final int id;
  final int productId;
  final String productName;
  final double productPrice;
  final String productImageUrl;
  final int quantity;

  CartItem({
    required this.id,
    required this.productId,
    required this.productName,
    required this.productPrice,
    required this.productImageUrl,
    required this.quantity,
  });

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      id: json['id'] as int,
      productId: json['productId'] as int,
      productName: json['productName'] as String,
      productPrice: (json['productPrice'] as num).toDouble(),
      productImageUrl: json['productImageUrl'] as String,
      quantity: json['quantity'] as int,
    );
  }

  Product toProduct() {
    return Product(
      id: productId,
      name: productName,
      description: '',
      price: productPrice,
      quantity: quantity,
      imageUrl: productImageUrl,
      categoryIds: [],
    );
  }
}
