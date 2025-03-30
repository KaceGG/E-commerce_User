// ignore_for_file: constant_identifier_names

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class AuthProvider extends ChangeNotifier {
  static const String BASE_URL = 'http://192.168.1.119:8080/auth';

  String? _userId; // Lưu userId sau khi đăng nhập
  bool _isLoading = false;
  String _errorMessage = '';

  bool get isLoggedIn => _userId != null;
  String? get userId => _userId;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;

  // Giả lập đăng nhập
  Future<bool> login(String username, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await http.post(
        Uri.parse('$BASE_URL/login'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'username': username,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        final token = jsonResponse['result']['token'];

        _userId = _getUserIdFromToken(token);
        if (userId != null) {
          _userId = userId;
          _errorMessage = '';
          notifyListeners();
          return true;
        } else {
          _errorMessage = 'Không thể giải mã token';
          notifyListeners();
          return false;
        }
      } else {
        _errorMessage = 'Login failed: ${response.statusCode}';
        notifyListeners();
        return false;
      }
    } catch (error) {
      _errorMessage = 'An error occurred: $error';
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void logout() {
    _userId = null;
    _errorMessage = '';
    notifyListeners();
  }

  String? _getUserIdFromToken(String token) {
    try {
      // Tách token thành ba phần: header, payload, signature
      final parts = token.split('.');
      if (parts.length != 3) {
        return null;
      }

      // Lấy phần payload và giải mã từ Base64
      final payload = parts[1];
      final normalized = base64Url.normalize(payload);
      final decodedBytes = base64Url.decode(normalized);
      final decodedString = utf8.decode(decodedBytes);

      // Chuyển từ String sang Map
      final payloadMap = json.decode(decodedString);

      // Trả về userId từ payload
      return payloadMap['sub'];
    } catch (e) {
      return null;
    }
  }
}
