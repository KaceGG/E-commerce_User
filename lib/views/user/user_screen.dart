import 'package:ecommerce_user/providers/auth_provider.dart';
import 'package:ecommerce_user/views/cart/cart_screen.dart';
import 'package:ecommerce_user/views/order/order_history_screen.dart';
import 'package:ecommerce_user/views/user/change_password_screen.dart';
import 'package:ecommerce_user/views/user/update_profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class UserScreen extends StatefulWidget {
  const UserScreen({super.key});

  @override
  State<UserScreen> createState() => _UserScreenState();
}

class _UserScreenState extends State<UserScreen> {
  Future<void> _onRefresh() async {
    await Future.delayed(const Duration(seconds: 1));
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        return Scaffold(
          appBar: AppBar(
            title: Text(
              'Thông tin người dùng',
              style: GoogleFonts.roboto(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            backgroundColor: Colors.blueAccent,
            elevation: 0,
          ),
          body: RefreshIndicator(
            onRefresh: _onRefresh,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(8.0),
              children: [
                _buildSectionTitle('Cập nhật thông tin'),
                _buildListTile(
                  context,
                  Icons.person,
                  'Cập nhật thông tin',
                  const UpdateProfileScreen(),
                ),
                _buildSectionTitle('Bảo mật'),
                _buildListTile(
                  context,
                  Icons.lock,
                  'Đổi mật khẩu',
                  const ChangePasswordScreen(),
                ),
                _buildSectionTitle('Giỏ hàng và Đơn hàng'),
                _buildListTile(
                  context,
                  Icons.shopping_cart,
                  'Giỏ hàng',
                  const CartScreen(),
                ),
                _buildListTile(
                  context,
                  Icons.history,
                  'Theo dõi đơn hàng',
                  const OrderHistoryScreen(),
                ),
                _buildSectionTitle('Đăng xuất'),
                _buildListTile(
                  context,
                  Icons.logout,
                  'Đăng xuất',
                  null,
                  color: Colors.red,
                  onTap: () => context.go('/login'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Helper function to build section titles
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        title,
        style: GoogleFonts.roboto(
          fontWeight: FontWeight.bold,
          fontSize: 18,
          color: Colors.blueAccent,
        ),
      ),
    );
  }

  // Helper function to create ListTile with better styling
  Widget _buildListTile(
    BuildContext context,
    IconData icon,
    String title,
    Widget? screen, {
    Color? color,
    VoidCallback? onTap,
  }) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap ??
            () {
              if (screen != null) {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => screen),
                );
              }
            },
        borderRadius: BorderRadius.circular(12),
        child: ListTile(
          leading: Icon(
            icon,
            color: color ?? Colors.blueAccent,
          ),
          title: Text(
            title,
            style: GoogleFonts.roboto(),
          ),
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        ),
      ),
    );
  }
}
