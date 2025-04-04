class Payment {
  final int id;
  final String? paymentMethod;
  final String? orderToken;
  final String? paymentUrl;
  final double? amount;
  final String? status;
  final DateTime? paymentDate;

  Payment({
    required this.id,
    this.paymentMethod,
    this.orderToken,
    this.paymentUrl,
    this.amount,
    this.status,
    this.paymentDate,
  });

  factory Payment.fromJson(Map<String, dynamic> json) {
    return Payment(
      id: json['id'] ?? 0,
      paymentMethod: json['paymentMethod'],
      orderToken: json['orderToken'],
      paymentUrl: json['paymentUrl'],
      amount:
          json['amount'] != null ? (json['amount'] as num).toDouble() : null,
      status: json['status'],
      paymentDate: json['paymentDate'] != null
          ? DateTime.parse(json['paymentDate'])
          : null,
    );
  }
}
