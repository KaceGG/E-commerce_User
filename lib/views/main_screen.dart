import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:convex_bottom_bar/convex_bottom_bar.dart';
import 'package:ecommerce_user/providers/auth_provider.dart';
import 'package:ecommerce_user/views/home/home_screen.dart';
import 'package:ecommerce_user/views/product/product_screen.dart';
import 'package:ecommerce_user/views/user/user_screen.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  static const List<Widget> _pages = [
    HomeScreen(),
    ProductScreen(),
    UserScreen(),
  ];

  void _showLoginDialog(BuildContext context) {
    AwesomeDialog(
      context: context,
      dialogType: DialogType.info,
      animType: AnimType.topSlide,
      title: 'Thông báo',
      desc: 'Vui lòng đăng nhập để tiếp tục',
      btnOkText: 'Đăng nhập',
      btnOkOnPress: () {
        context.go('/login');
      },
      btnCancelText: 'Hủy',
      btnCancelOnPress: () {},
    ).show();
  }

  void _onItemTapped(int index) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    // Kiểm tra khi chọn tab "Người dùng" (index == 2)
    if (index == 2 && !authProvider.isAuthenticated()) {
      _showLoginDialog(context);
      return;
    }
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: ConvexAppBar(
        style: TabStyle.reactCircle, // Kiểu cong với vòng tròn nổi
        backgroundColor: Colors.blueAccent,
        activeColor: Colors.white,
        color: Colors.white70,
        items: const [
          TabItem(icon: Icons.home, title: 'Home'),
          TabItem(icon: Icons.shop, title: 'Sản phẩm'),
          TabItem(icon: Icons.person, title: 'Người dùng'),
        ],
        initialActiveIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}
