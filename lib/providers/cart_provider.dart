// ignore_for_file: constant_identifier_names

import 'dart:convert';
import 'package:ecommerce_user/models/cart_model.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:ecommerce_user/core/utils/constant.dart' as constant;

class CartProvider extends ChangeNotifier {
  static const String BASE_URL = '${constant.BASE_URL}/cart';
  Cart? _cart;
  bool _isLoading = false;
  String _errorMessage = '';

  Cart? get cart => _cart;
  bool get isLoading => _isLoading;
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

  Future<void> fetchCart(String userId) async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      final response = await http.get(
        Uri.parse('$BASE_URL?userId=$userId'),
      );

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(utf8.decode(response.bodyBytes));
        if (jsonResponse['code'] == 200 && jsonResponse['result'] != null) {
          _cart = Cart.fromJson(jsonResponse['result'] as Map<String, dynamic>);
          _errorMessage = '';
        } else {
          _errorMessage = jsonResponse['message'] ?? 'Failed to retrieve cart';
          _cart = null;
        }
      } else {
        _errorMessage = 'Failed to load cart: ${response.statusCode}';
        _cart = null;
      }
    } catch (error) {
      _errorMessage = 'An error occurred: $error';
      _cart = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateQuantity(
      String userId, int cartItemId, int newQuantity) async {
    try {
      final response = await http.put(
        Uri.parse('$BASE_URL/update/$cartItemId?userId=$userId'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'quantity': newQuantity,
        }),
      );

      if (response.statusCode == 200) {
        await fetchCart(
            userId); // Cập nhật lại giỏ hàng sau khi thay đổi số lượng
        _errorMessage = '';
      } else {
        _errorMessage = 'Failed to update quantity: ${response.statusCode}';
      }
    } catch (error) {
      _errorMessage = 'An error occurred: $error';
    } finally {
      notifyListeners();
    }
  }

  Future<void> removeFromCart(String userId, int cartItemId) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await http.delete(
        Uri.parse('$BASE_URL/remove/$cartItemId?userId=$userId'),
      );

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(utf8.decode(response.bodyBytes));
        _cart = Cart.fromJson(jsonResponse['result']);
        _errorMessage = '';
      } else {
        _errorMessage = 'Failed to remove cart item: ${response.statusCode}';
      }
    } catch (error) {
      _errorMessage = 'An error occurred: $error';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
