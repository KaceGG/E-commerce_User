import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class OrderHistoryScreen extends StatelessWidget {
  const OrderHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Theo dõi đơn hàng',
          style: GoogleFonts.roboto(
              fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: Colors.blueAccent,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          ListTile(
            title: Text('Đơn hàng #1234', style: GoogleFonts.roboto()),
            subtitle:
                Text('Trạng thái: Đang giao', style: GoogleFonts.roboto()),
          ),
          ListTile(
            title: Text('Đơn hàng #5678', style: GoogleFonts.roboto()),
            subtitle: Text('Trạng thái: Đã giao', style: GoogleFonts.roboto()),
          ),
          // Thêm các đơn hàng khác nếu cần
        ],
      ),
    );
  }
}
