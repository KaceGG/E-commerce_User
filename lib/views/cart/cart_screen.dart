import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:ecommerce_user/providers/auth_provider.dart';
import 'package:ecommerce_user/providers/cart_provider.dart';
import 'package:ecommerce_user/views/auth/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: GridView.builder(
                      padding: const EdgeInsets.all(16.0),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 16.0,
                        mainAxisSpacing: 16.0,
                        childAspectRatio: 0.65,
                      ),
                      itemCount: cartProvider.cart!.cartItems.length,
                      itemBuilder: (context, index) {
                        final cartItem = cartProvider.cart!.cartItems[index];
                        return Card(
                          elevation: 5,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              ClipRRect(
                                borderRadius: const BorderRadius.vertical(
                                    top: Radius.circular(15)),
                                child: Image.network(
                                  cartItem.productImageUrl,
                                  height: 150,
                                  width: double.infinity,
                                  fit: BoxFit.contain,
                                  loadingBuilder:
                                      (context, child, loadingProgress) {
                                    if (loadingProgress == null) return child;
                                    return Container(
                                      height: 150,
                                      color: Colors.grey[200],
                                      child: const Center(
                                          child: CircularProgressIndicator()),
                                    );
                                  },
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      height: 150,
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
                              Padding(
                                padding: const EdgeInsets.all(12.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
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
                                    Text(
                                      'Số lượng: ${cartItem.quantity}',
                                      style: GoogleFonts.poppins(fontSize: 14),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
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
