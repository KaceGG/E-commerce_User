import 'package:convex_bottom_bar/convex_bottom_bar.dart';
import 'package:ecommerce_user/views/home/home_screen.dart';
import 'package:ecommerce_user/views/product/product_screen.dart';
import 'package:ecommerce_user/views/user/user_screen.dart';
import 'package:flutter/material.dart';

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

  void _onItemTapped(int index) {
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
