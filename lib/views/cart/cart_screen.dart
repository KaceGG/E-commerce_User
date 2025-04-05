import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:ecommerce_user/providers/auth_provider.dart';
import 'package:ecommerce_user/providers/cart_provider.dart';
import 'package:ecommerce_user/views/auth/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';
import 'package:ecommerce_user/core/utils/constant.dart' as constant;

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  bool _hasFetched = false;
  bool _hasShownLoginDialog = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_hasFetched) {
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        final cartProvider = Provider.of<CartProvider>(context, listen: false);
        if (authProvider.isLoggedIn && authProvider.userId != null) {
          cartProvider.fetchCart(authProvider.userId!);
        } else if (!_hasShownLoginDialog) {
          _showLoginDialog(context);
          _hasShownLoginDialog = true;
        }
        _hasFetched = true;
      }
    });
  }

  Future<void> _refreshData() async {
    await Future.delayed(const Duration(seconds: 1));
    setState(() {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final cartProvider = Provider.of<CartProvider>(context, listen: false);
      if (authProvider.isLoggedIn && authProvider.userId != null) {
        cartProvider.fetchCart(authProvider.userId!);
      }
    });
  }

  void _showLoginDialog(BuildContext context) {
    AwesomeDialog(
      context: context,
      dialogType: DialogType.info,
      animType: AnimType.topSlide,
      title: 'Thông báo',
      desc: 'Vui lòng đăng nhập để tiếp tục',
      btnOkText: 'Đăng nhập',
      btnOkOnPress: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        ).then((result) {
          if (result != null && mounted) {
            final authProvider =
                Provider.of<AuthProvider>(context, listen: false);
            final cartProvider =
                Provider.of<CartProvider>(context, listen: false);
            if (authProvider.isLoggedIn && authProvider.userId != null) {
              cartProvider.fetchCart(authProvider.userId!);
            }
          }
        });
      },
      btnCancelText: 'Hủy',
      btnCancelOnPress: () {
        Navigator.pop(context);
      },
    ).show();
  }

  Future<void> _initiateZaloPayPayment(int amount, String userId) async {
    const String zaloPayUrl =
        '${constant.BASE_URL}/payment/zalopay/create-order';
    try {
      final cartProvider = Provider.of<CartProvider>(context, listen: false);
      final cartItems = cartProvider.cart?.cartItems ?? [];

      final List<Map<String, dynamic>> orderItems = cartItems.map((cartItem) {
        return {
          'productId': cartItem.productId,
          'quantity': cartItem.quantity,
          'price': cartItem.productPrice,
        };
      }).toList();

      final response = await http.post(
        Uri.parse(zaloPayUrl),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'userId': userId,
          'amount': amount,
          'shippingAddress': 'Default Address',
          'items': orderItems,
        }),
      );

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        final orderUrl = jsonResponse['result']['orderUrl'];
        if (orderUrl != null) {
          final Uri url = Uri.parse(orderUrl);
          if (await canLaunchUrl(url)) {
            await launchUrl(url, mode: LaunchMode.externalApplication);
            // Sau khi thanh toán thành công, làm mới giỏ hàng
            cartProvider.fetchCart(userId);
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Không thể mở ZaloPay')),
            );
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Không nhận được URL thanh toán')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  'Thanh toán thất bại: ${response.statusCode} - ${response.body}')),
        );
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi khi gọi ZaloPay: $error')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final numberFormat = NumberFormat('#,###', 'vi_VN');

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Giỏ hàng',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.blueAccent,
        elevation: 0,
      ),
      body: RefreshIndicator(
        onRefresh: _refreshData,
        child: Container(
          color: Colors.white,
          child: Consumer2<AuthProvider, CartProvider>(
            builder: (context, authProvider, cartProvider, child) {
              if (!authProvider.isLoggedIn || authProvider.userId == null) {
                return Center(
                  child: Text(
                    'Vui lòng đăng nhập để xem giỏ hàng',
                    style: GoogleFonts.poppins(fontSize: 16),
                  ),
                );
              }

              if (cartProvider.isLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              if (cartProvider.errorMessage.isNotEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        cartProvider.errorMessage,
                        style: GoogleFonts.poppins(color: Colors.red),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () =>
                            cartProvider.fetchCart(authProvider.userId!),
                        child: Text('Thử lại', style: GoogleFonts.poppins()),
                      ),
                    ],
                  ),
                );
              }

              if (cartProvider.cart == null ||
                  cartProvider.cart!.cartItems.isEmpty) {
                return Center(
                  child: Text(
                    'Giỏ hàng trống',
                    style: GoogleFonts.poppins(fontSize: 16),
                  ),
                );
              }

              return Column(
                children: [
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.all(16.0),
                      itemCount: cartProvider.cart!.cartItems.length,
                      itemBuilder: (context, index) {
                        final cartItem = cartProvider.cart!.cartItems[index];
                        return Card(
                          elevation: 5,
                          margin: const EdgeInsets.symmetric(vertical: 8.0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: Image.network(
                                    cartItem.productImageUrl,
                                    width: 100,
                                    height: 100,
                                    fit: BoxFit.contain,
                                    loadingBuilder:
                                        (context, child, loadingProgress) {
                                      if (loadingProgress == null) return child;
                                      return Container(
                                        width: 100,
                                        height: 100,
                                        color: Colors.grey[200],
                                        child: const Center(
                                            child: CircularProgressIndicator()),
                                      );
                                    },
                                    errorBuilder: (context, error, stackTrace) {
                                      return Container(
                                        width: 100,
                                        height: 100,
                                        color: Colors.grey[200],
                                        child: const Icon(
                                          Icons.image_not_supported,
                                          size: 50,
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
                                        cartItem.productName,
                                        style: GoogleFonts.poppins(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                          color: Colors.black87,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        '${numberFormat.format(cartItem.productPrice)} VNĐ',
                                        style: GoogleFonts.poppins(
                                          color: Colors.redAccent,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Row(
                                        children: [
                                          IconButton(
                                            onPressed: () {
                                              if (cartItem.quantity > 1) {
                                                cartProvider.updateQuantity(
                                                  authProvider.userId!,
                                                  cartItem.id,
                                                  cartItem.quantity - 1,
                                                );
                                              } else {
                                                // Xóa sản phẩm nếu số lượng về 0
                                                cartProvider.removeFromCart(
                                                  authProvider.userId!,
                                                  cartItem.id,
                                                );
                                              }
                                            },
                                            icon: const Icon(
                                                Icons.remove_circle_outline),
                                            color: Colors.blueAccent,
                                          ),
                                          Text(
                                            '${cartItem.quantity}',
                                            style: GoogleFonts.poppins(
                                                fontSize: 14),
                                          ),
                                          IconButton(
                                            onPressed: () {
                                              cartProvider.updateQuantity(
                                                authProvider.userId!,
                                                cartItem.id,
                                                cartItem.quantity + 1,
                                              );
                                            },
                                            icon: const Icon(
                                                Icons.add_circle_outline),
                                            color: Colors.blueAccent,
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete,
                                      color: Colors.red),
                                  onPressed: () {
                                    // Xóa sản phẩm khỏi giỏ hàng
                                    cartProvider.removeFromCart(
                                      authProvider.userId!,
                                      cartItem.id,
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Tổng tiền:',
                              style: GoogleFonts.poppins(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              '${numberFormat.format(cartProvider.cart!.totalPrice)} VNĐ',
                              style: GoogleFonts.poppins(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.redAccent,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              if (authProvider.userId != null) {
                                _initiateZaloPayPayment(
                                  cartProvider.cart!.totalPrice.toInt(),
                                  authProvider.userId!,
                                );
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text(
                                          'Vui lòng đăng nhập để thanh toán')),
                                );
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blueAccent,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: Text(
                              'Thanh toán',
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
