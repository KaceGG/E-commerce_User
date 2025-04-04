import 'package:ecommerce_user/models/order_item_model.dart';
import 'package:ecommerce_user/models/payment_model.dart';

class Order {
  final int id;
  final DateTime orderDate;
  final double totalAmount;
  final String shippingAddress;
  final String userId;
  final String? status;
  final List<OrderItem>? items;
  final Payment? payment;

  Order({
    required this.id,
    required this.orderDate,
    required this.totalAmount,
    required this.shippingAddress,
    required this.userId,
    this.status,
    this.items,
    this.payment,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'] ?? 0,
      orderDate: DateTime.parse(json['orderDate']),
      totalAmount: (json['totalAmount'] as num).toDouble(),
      shippingAddress: json['shippingAddress'] ?? 'Unknown Address',
      userId: json['userId'] ?? '',
      status: json['status'],
      items: json['items'] != null
          ? (json['items'] as List)
              .map((item) => OrderItem.fromJson(item))
              .toList()
          : null,
      payment:
          json['payment'] != null ? Payment.fromJson(json['payment']) : null,
    );
  }
}
