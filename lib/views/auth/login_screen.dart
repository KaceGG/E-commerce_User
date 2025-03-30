import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ecommerce_user/providers/auth_provider.dart';

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
        title: const Text('Login'),
        backgroundColor: Colors.blueAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Consumer<AuthProvider>(
          builder: (context, authProvider, child) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextField(
                  controller: _usernameController,
                  decoration: const InputDecoration(
                    labelText: 'Username',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _passwordController,
                  decoration: const InputDecoration(
                    labelText: 'Password',
                    border: OutlineInputBorder(),
                  ),
                  obscureText: true,
                ),
                const SizedBox(height: 16),
                if (authProvider.isLoading)
                  const CircularProgressIndicator()
                else
                  ElevatedButton(
                    onPressed: () async {
                      final username = _usernameController.text;
                      final password = _passwordController.text;
                      final success =
                          await authProvider.login(username, password);
                      if (success) {
                        Navigator.pop(
                            context); // Quay lại màn hình trước sau khi đăng nhập thành công
                      }
                    },
                    child: const Text('Login'),
                  ),
                if (authProvider.errorMessage.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Text(
                    authProvider.errorMessage,
                    style: const TextStyle(color: Colors.red),
                  ),
                ],
              ],
            );
          },
        ),
      ),
    );
  }
}
