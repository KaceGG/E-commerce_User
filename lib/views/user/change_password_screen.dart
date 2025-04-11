import 'package:ecommerce_user/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _oldPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  final _newPassFocus = FocusNode();
  final _confirmPassFocus = FocusNode();

  bool _showOld = false;
  bool _showNew = false;
  bool _showConfirm = false;

  @override
  void dispose() {
    _oldPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    _newPassFocus.dispose();
    _confirmPassFocus.dispose();
    super.dispose();
  }

  void _showMessage(String message, {bool isSuccess = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: GoogleFonts.roboto()),
        backgroundColor: isSuccess ? Colors.green : Colors.redAccent,
      ),
    );
  }

  Future<void> _handleChangePassword(AuthProvider authProvider) async {
    final oldPassword = _oldPasswordController.text.trim();
    final newPassword = _newPasswordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();

    if (oldPassword.isEmpty || newPassword.isEmpty || confirmPassword.isEmpty) {
      _showMessage('Vui lòng nhập đầy đủ thông tin');
      return;
    }

    if (newPassword != confirmPassword) {
      _showMessage('Mật khẩu mới và xác nhận không khớp');
      return;
    }

    final success = await authProvider.changePassword(
      oldPassword: oldPassword,
      newPassword: newPassword,
      confirmPassword: confirmPassword,
    );

    if (success && mounted) {
      _showMessage('Đổi mật khẩu thành công!', isSuccess: true);
      Navigator.pop(context);
    } else if (mounted) {
      _showMessage(authProvider.errorMessage.isNotEmpty
          ? authProvider.errorMessage
          : 'Đổi mật khẩu thất bại');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        if (!authProvider.isAuthenticated()) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            context.go('/login');
          });
          return const Center(child: CircularProgressIndicator());
        }

        return Scaffold(
          appBar: AppBar(
            title: Text(
              'Đổi mật khẩu',
              style: GoogleFonts.roboto(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            backgroundColor: Colors.blueAccent,
            elevation: 0,
          ),
          backgroundColor: const Color(0xFFF5F7FB),
          body: Center(
            child: SingleChildScrollView(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20.0, vertical: 40),
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.lock, size: 60, color: Colors.blueAccent),
                      const SizedBox(height: 16),
                      Text(
                        'Thay đổi mật khẩu',
                        style: GoogleFonts.roboto(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Old Password
                      _buildPasswordField(
                        controller: _oldPasswordController,
                        label: 'Mật khẩu cũ',
                        showText: _showOld,
                        toggleShow: () => setState(() => _showOld = !_showOld),
                        onSubmitted: (_) => _newPassFocus.requestFocus(),
                      ),
                      const SizedBox(height: 16),

                      // New Password
                      _buildPasswordField(
                        controller: _newPasswordController,
                        label: 'Mật khẩu mới',
                        showText: _showNew,
                        toggleShow: () => setState(() => _showNew = !_showNew),
                        focusNode: _newPassFocus,
                        onSubmitted: (_) => _confirmPassFocus.requestFocus(),
                      ),
                      const SizedBox(height: 16),

                      // Confirm Password
                      _buildPasswordField(
                        controller: _confirmPasswordController,
                        label: 'Xác nhận mật khẩu mới',
                        showText: _showConfirm,
                        toggleShow: () =>
                            setState(() => _showConfirm = !_showConfirm),
                        focusNode: _confirmPassFocus,
                        onSubmitted: (_) => _handleChangePassword(authProvider),
                      ),
                      const SizedBox(height: 30),

                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        child: authProvider.isLoading
                            ? const CircularProgressIndicator(
                                key: ValueKey('loading'))
                            : SizedBox(
                                key: const ValueKey('button'),
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: () =>
                                      _handleChangePassword(authProvider),
                                  style: ElevatedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 16),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    backgroundColor: Colors.blueAccent,
                                  ),
                                  child: Text(
                                    'Đổi mật khẩu',
                                    style: GoogleFonts.roboto(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String label,
    required bool showText,
    required VoidCallback toggleShow,
    FocusNode? focusNode,
    void Function(String)? onSubmitted,
  }) {
    return TextField(
      controller: controller,
      obscureText: !showText,
      focusNode: focusNode,
      onSubmitted: onSubmitted,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.roboto(),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        prefixIcon: const Icon(Icons.lock_outline),
        suffixIcon: IconButton(
          icon: Icon(showText ? Icons.visibility_off : Icons.visibility),
          onPressed: toggleShow,
        ),
        filled: true,
        fillColor: Colors.white,
      ),
    );
  }
}
