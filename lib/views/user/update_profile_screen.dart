import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';

class UpdateProfileScreen extends StatefulWidget {
  const UpdateProfileScreen({super.key});

  @override
  State<UpdateProfileScreen> createState() => _UpdateProfileScreenState();
}

class _UpdateProfileScreenState extends State<UpdateProfileScreen> {
  late final TextEditingController _fullNameController;
  late final TextEditingController _birthdayController;
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;
  late final TextEditingController _addressController;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fullNameController = TextEditingController();
    _birthdayController = TextEditingController();
    _emailController = TextEditingController();
    _phoneController = TextEditingController();
    _addressController = TextEditingController();

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    _fullNameController.text = authProvider.user?.fullName ?? '';
    _birthdayController.text = authProvider.user?.birthday != null
        ? DateFormat('yyyy-MM-dd').format(authProvider.user!.birthday!)
        : '';
    _emailController.text = authProvider.user?.email ?? '';
    _phoneController.text = authProvider.user?.phone ?? '';
    _addressController.text = authProvider.user?.address ?? '';
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _birthdayController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _birthdayController.text.isNotEmpty
          ? DateTime.parse(_birthdayController.text)
          : DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null && mounted) {
      setState(() {
        _birthdayController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  void _updateUserInfo(AuthProvider authProvider) async {
    setState(() => _isLoading = true);
    try {
      await authProvider.updateUserProfile(
        fullName: _fullNameController.text,
        birthday: _birthdayController.text.isNotEmpty
            ? DateTime.parse(_birthdayController.text)
            : null,
        email: _emailController.text,
        phone: _phoneController.text,
        address: _addressController.text,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Thông tin đã được cập nhật!',
                  style: GoogleFonts.roboto())),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content:
                  Text('Cập nhật thất bại: $e', style: GoogleFonts.roboto())),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    TextInputType? keyboardType,
    bool readOnly = false,
    VoidCallback? onTap,
    Widget? suffixIcon,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        readOnly: readOnly,
        onTap: onTap,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: GoogleFonts.roboto(),
          suffixIcon: suffixIcon,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        return Scaffold(
          appBar: AppBar(
            title: Text('Cập nhật thông tin',
                style: GoogleFonts.roboto(
                    fontWeight: FontWeight.bold, color: Colors.white)),
            backgroundColor: Colors.blueAccent,
            elevation: 0,
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Avatar + Tên
                const CircleAvatar(
                  radius: 40,
                  backgroundColor: Colors.blueAccent,
                  child: Icon(Icons.person, size: 48, color: Colors.white),
                ),
                const SizedBox(height: 8),
                Text(
                  authProvider.user?.fullName ?? 'Người dùng',
                  style: GoogleFonts.roboto(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 24),

                _buildTextField(
                    label: 'Họ và tên', controller: _fullNameController),
                _buildTextField(
                  label: 'Ngày sinh (YYYY-MM-DD)',
                  controller: _birthdayController,
                  readOnly: true,
                  onTap: () => _selectDate(context),
                  suffixIcon: const Icon(Icons.calendar_today),
                ),
                _buildTextField(
                    label: 'Email',
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress),
                _buildTextField(
                    label: 'Số điện thoại',
                    controller: _phoneController,
                    keyboardType: TextInputType.phone),
                _buildTextField(
                    label: 'Địa chỉ', controller: _addressController),

                const SizedBox(height: 24),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed:
                        _isLoading ? null : () => _updateUserInfo(authProvider),
                    icon: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white),
                          )
                        : const Icon(Icons.save),
                    label: Text('Cập nhật',
                        style: GoogleFonts.roboto(fontSize: 16)),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      backgroundColor: Colors.blueAccent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
