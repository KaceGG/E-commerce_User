// ignore_for_file: constant_identifier_names

import 'dart:convert';
import 'package:ecommerce_user/models/user_model.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:ecommerce_user/core/utils/constant.dart' as constant;
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthProvider extends ChangeNotifier {
  static const String BASE_URL = '${constant.BASE_URL}/auth';
  static const String USER_URL = '${constant.BASE_URL}/user';

  String? _userId;
  String? _token;
  User? _user;
  bool _isLoading = false;
  String _errorMessage = '';

  bool get isLoggedIn => _token != null && !JwtDecoder.isExpired(_token!);
  String? get userId => _userId;
  String? get token => _token;
  User? get user => _user;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;

  AuthProvider() {
    _loadToken();
  }

  set errorMessage(String message) {
    _errorMessage = message;
    notifyListeners();
  }

  Future<void> _loadToken() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('token');
    if (_token != null && !JwtDecoder.isExpired(_token!)) {
      _userId = _getUserIdFromToken(_token!);
      await _fetchUserInfo(); // Lấy thông tin user nếu token hợp lệ
    } else {
      _token = null;
      _userId = null;
      await prefs.remove('token'); // Xóa token nếu hết hạn
    }
    notifyListeners();
  }

  Future<bool> register(String username, String password) async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      final response = await http.post(
        Uri.parse('$USER_URL/create'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(
          {'username': username, 'password': password},
        ),
      );

      if (response.statusCode == 200) {
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        final data = jsonDecode(response.body);
        _errorMessage = data['message'] ?? 'Đăng ký thất bại!';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'An error occurred: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

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
        _token = jsonResponse['result']['token'];
        print('Token sau đây đã được lưu: $_token');
        _userId = _getUserIdFromToken(_token!);

        if (_userId != null) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('token', _token!); // Lưu token
          await _fetchUserInfo(); // Lấy thông tin user
          _errorMessage = '';
          _isLoading = false;
          notifyListeners();
          return true;
        } else {
          _errorMessage = 'Không thể giải mã token';
          _isLoading = false;
          notifyListeners();
          return false;
        }
      } else {
        _errorMessage = 'Login failed: ${response.statusCode}';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (error) {
      _errorMessage = 'An error occurred: $error';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  String? _getUserIdFromToken(String token) {
    try {
      final Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
      return decodedToken['sub']
          ?.toString(); // 'sub' là trường chứa userId trong JWT
    } catch (e) {
      print('Error decoding token: $e');
      return null;
    }
  }

  Future<void> _fetchUserInfo() async {
    try {
      final response = await http.get(
        Uri.parse('$USER_URL/$userId'),
        headers: {
          'Content-Type': 'application/json',
          // 'Authorization': 'Bearer $_token',
        },
      );
      if (response.statusCode == 200) {
        final jsonData = jsonDecode(utf8.decode(response.bodyBytes));
        final userData = jsonData['result'];
        _user = User.fromJson(userData);
      } else {
        _errorMessage = 'Failed to fetch user info: ${response.statusCode}';
      }
    } catch (e) {
      _errorMessage = 'Error fetching user info: $e';
    }
    notifyListeners();
  }

  Future<void> updateUserProfile({
    String? fullName,
    DateTime? birthday,
    String? email,
    String? phone,
    String? address,
  }) async {
    if (!isLoggedIn) {
      throw Exception('User not logged in or token expired');
    }

    final url = Uri.parse('$USER_URL/update/$userId');
    final response = await http.put(
      url,
      headers: {
        'Content-Type': 'application/json',
        // 'Authorization': 'Bearer $_token',
      },
      body: jsonEncode({
        'fullName': fullName,
        'birthday': birthday?.toIso8601String(),
        'email': email,
        'phone': phone,
        'address': address,
      }),
    );

    if (response.statusCode == 200) {
      _user = User.fromJson(jsonDecode(response.body));
      notifyListeners();
    } else {
      throw Exception('Failed to update user: ${response.body}');
    }
  }

  Future<void> logout() async {
    print('Token sau đây đã bị xoá: $_token');
    _userId = null;
    _token = null;
    _user = null;
    _errorMessage = '';
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token'); // Xóa token khi đăng xuất
    notifyListeners();
  }

  bool isAuthenticated() {
    return _token != null && !JwtDecoder.isExpired(_token!);
  }

  Future<bool> changePassword({
    required String oldPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    if (!isLoggedIn || _userId == null) {
      _errorMessage = 'User not logged in or token expired';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      final response = await http.post(
        Uri.parse('$USER_URL/$_userId/change-password'),
        headers: {
          'Content-Type': 'application/json',
          // 'Authorization': 'Bearer $_token',
        },
        body: jsonEncode({
          'oldPassword': oldPassword,
          'newPassword': newPassword,
          'confirmPassword': confirmPassword,
        }),
      );

      if (response.statusCode == 200) {
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        final data = jsonDecode(response.body);
        _errorMessage = data['message'] ?? 'Failed to change password';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'Error changing password: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
}
