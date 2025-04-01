import 'package:ecommerce_user/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class UpdateProfileScreen extends StatefulWidget {
  const UpdateProfileScreen({super.key});

  @override
  State<UpdateProfileScreen> createState() => _UpdateProfileScreenState();
}

class _UpdateProfileScreenState extends State<UpdateProfileScreen> {
  final _newUsernameController = TextEditingController();

  @override
  void dispose() {
    _newUsernameController.dispose();
    super.dispose();
  }

  void _updateUserInfo(AuthProvider authProvider) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text('Thông tin đã được cập nhật!',
              style: GoogleFonts.poppins())),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        return Scaffold(
          appBar: AppBar(
            title: Text(
              'Cập nhật thông tin',
              style: GoogleFonts.poppins(
                  fontWeight: FontWeight.bold, color: Colors.white),
            ),
            backgroundColor: Colors.blueAccent,
            elevation: 0,
          ),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: _newUsernameController,
                  decoration: InputDecoration(
                    labelText: 'Tên người dùng mới',
                    labelStyle: GoogleFonts.poppins(),
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => _updateUserInfo(authProvider),
                  child: Text('Cập nhật', style: GoogleFonts.poppins()),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
