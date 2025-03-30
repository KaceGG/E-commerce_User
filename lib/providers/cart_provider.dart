// ignore_for_file: constant_identifier_names

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class CartProvider extends ChangeNotifier {
  static const String BASE_URL = 'http://192.168.1.119:8080/cart';
  String _errorMessage = '';

  String get errorMessage => _errorMessage;

  Future<bool> addToCart(String userId, int productId) async {
    try {
      final response = await http.post(
        Uri.parse('$BASE_URL/add?userId=$userId'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'productId': productId,
          'quantity': 1, // Mặc định thêm 1 sản phẩm
        }),
      );

      if (response.statusCode == 200) {
        _errorMessage = '';
        notifyListeners();
        return true;
      } else {
        _errorMessage = 'Failed to add to cart: ${response.statusCode}';
        notifyListeners();
        return false;
      }
    } catch (error) {
      _errorMessage = 'An error occurred: $error';
      notifyListeners();
      return false;
    }
  }
}
