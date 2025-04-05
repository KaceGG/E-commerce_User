import 'package:ecommerce_user/providers/auth_provider.dart';
import 'package:ecommerce_user/views/auth/register_screen.dart';
import 'package:ecommerce_user/views/main_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueAccent,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Consumer<AuthProvider>(
            builder: (context, authProvider, child) {
              return SingleChildScrollView(
                child: Center(
                  child: Card(
                    elevation: 8,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Logo or Title Section
                          Text(
                            'Xin chào!',
                            style: GoogleFonts.roboto(
                              fontWeight: FontWeight.bold,
                              fontSize: 24,
                              color: Colors.blueAccent,
                            ),
                          ),
                          const SizedBox(height: 16),
                          // Username field
                          TextFormField(
                            controller: _usernameController,
                            decoration: InputDecoration(
                              labelText: 'Username',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              prefixIcon: const Icon(Icons.person),
                            ),
                          ),
                          const SizedBox(height: 16),
                          // Password field
                          TextFormField(
                            controller: _passwordController,
                            obscureText: true,
                            decoration: InputDecoration(
                              labelText: 'Password',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              prefixIcon: const Icon(Icons.lock),
                            ),
                          ),
                          const SizedBox(height: 16),
                          // Login Button
                          if (authProvider.isLoading)
                            const CircularProgressIndicator()
                          else
                            ElevatedButton(
                              onPressed: () async {
                                final username = _usernameController.text;
                                final password = _passwordController.text;
                                final success = await authProvider.login(
                                    username, password);
                                if (success && mounted) {
                                  Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              const MainScreen()));
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                padding: const EdgeInsets.all(16),
                                backgroundColor: Colors.blueAccent,
                                foregroundColor: Colors.white,
                              ),
                              child: const Text('Đăng nhập'),
                            ),
                          const SizedBox(height: 16),
                          // Register Button
                          TextButton(
                            onPressed: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          const RegisterScreen()));
                            },
                            child: const Text(
                              "Chưa có tài khoản? Đăng ký ngay",
                              style: TextStyle(color: Colors.blueAccent),
                            ),
                          ),
                          // Error message
                          if (authProvider.errorMessage.isNotEmpty) ...[
                            const SizedBox(height: 16),
                            Text(
                              authProvider.errorMessage,
                              style: const TextStyle(color: Colors.red),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
