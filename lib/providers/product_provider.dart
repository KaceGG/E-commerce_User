// ignore_for_file: avoid_print

import 'dart:convert';
import 'package:ecommerce_user/models/product_model.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:ecommerce_user/core/utils/constant.dart' as constant;

class ProductProvider extends ChangeNotifier {
  // ignore: constant_identifier_names
  static const String BASE_URL = '${constant.BASE_URL}/product';

  List<Product> _products = [];
  bool _isLoading = false;
  String _errorMessage = '';

  List<Product> get products => _products;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;

  Future<void> fetchProducts() async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await http.get(Uri.parse('$BASE_URL/getAll'));

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(utf8.decode(response.bodyBytes));
        // print('Response từ server: $jsonResponse');
        _products = (jsonResponse['result'] as List)
            .map((data) => Product.fromJson(data))
            .toList();
        _errorMessage = '';
      } else {
        _errorMessage = 'Failed to load products';
      }
    } catch (error) {
      _errorMessage = 'An error occurred: $error';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchProductsByCategory(int categoryId) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response =
          await http.get(Uri.parse('$BASE_URL/category/$categoryId'));

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(utf8.decode(response.bodyBytes));
        _products = (jsonResponse['result'] as List)
            .map((data) => Product.fromJson(data))
            .toList();
        _errorMessage = '';
      } else {
        _errorMessage = 'Failed to load products';
      }
    } catch (e) {
      _errorMessage = 'An error occurred: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
