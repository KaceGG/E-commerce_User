import 'package:ecommerce_user/providers/auth_provider.dart';
import 'package:ecommerce_user/providers/order_provider.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class OrderScreen extends StatefulWidget {
  const OrderScreen({super.key});

  @override
  State<OrderScreen> createState() => _OrderScreenState();
}

class _OrderScreenState extends State<OrderScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final orderProvider = Provider.of<OrderProvider>(context, listen: false);
      if (authProvider.isLoggedIn && authProvider.userId != null) {
        orderProvider.fetchOrders(authProvider.userId!);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final numberFormat = NumberFormat('#,###', 'vi_VN');

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Đơn hàng của bạn',
          style: GoogleFonts.roboto(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.blueAccent,
        elevation: 0,
      ),
      body: Consumer2<AuthProvider, OrderProvider>(
        builder: (context, authProvider, orderProvider, child) {
          if (!authProvider.isLoggedIn || authProvider.userId == null) {
            return const Center(child: Text('Vui lòng đăng nhập'));
          }

          if (orderProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (orderProvider.errorMessage.isNotEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    orderProvider.errorMessage,
                    style: GoogleFonts.roboto(color: Colors.red),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () =>
                        orderProvider.fetchOrders(authProvider.userId!),
                    child: Text('Thử lại', style: GoogleFonts.roboto()),
                  ),
                ],
              ),
            );
          }

          if (orderProvider.orders.isEmpty) {
            return const Center(child: Text('Không có đơn hàng nào'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: orderProvider.orders.length,
            itemBuilder: (context, index) {
              final order = orderProvider.orders[index];
              return Card(
                elevation: 5,
                margin: const EdgeInsets.symmetric(vertical: 8.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Mã đơn hàng: ${order.id}',
                        style: GoogleFonts.roboto(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Ngày đặt: ${DateFormat('dd/MM/yyyy HH:mm').format(order.orderDate)}',
                        style: GoogleFonts.roboto(),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Tổng tiền: ${numberFormat.format(order.totalAmount)} VNĐ',
                        style: GoogleFonts.roboto(color: Colors.redAccent),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Địa chỉ giao hàng: ${order.shippingAddress}',
                        style: GoogleFonts.roboto(),
                      ),
                      if (order.items != null && order.items!.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Text(
                          'Sản phẩm:',
                          style:
                              GoogleFonts.roboto(fontWeight: FontWeight.bold),
                        ),
                        ...order.items!.map((item) => Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: Image.network(
                                      item.productImageUrl,
                                      width: 60,
                                      height: 60,
                                      fit: BoxFit.contain,
                                      loadingBuilder:
                                          (context, child, loadingProgress) {
                                        if (loadingProgress == null) {
                                          return child;
                                        }
                                        return Container(
                                          width: 60,
                                          height: 60,
                                          color: Colors.grey[200],
                                          child: const Center(
                                              child:
                                                  CircularProgressIndicator()),
                                        );
                                      },
                                      errorBuilder:
                                          (context, error, stackTrace) {
                                        return Container(
                                          width: 60,
                                          height: 60,
                                          color: Colors.grey[200],
                                          child: const Icon(
                                            Icons.image_not_supported,
                                            size: 30,
                                            color: Colors.grey,
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          item.productName,
                                          style: GoogleFonts.roboto(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          '${item.quantity} x ${numberFormat.format(item.price)} VNĐ',
                                          style: GoogleFonts.roboto(),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            )),
                      ],
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
