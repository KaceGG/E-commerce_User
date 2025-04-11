// ignore_for_file: constant_identifier_names

import 'dart:convert';
import 'package:ecommerce_user/models/order_model.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:ecommerce_user/core/utils/constant.dart' as constant;

class OrderProvider extends ChangeNotifier {
  List<Order> _orders = [];
  bool _isLoading = false;
  String _errorMessage = '';

  List<Order> get orders => _orders;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;

  Future<void> fetchOrders(String userId) async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      final response = await http.get(
        Uri.parse('${constant.BASE_URL}/order?userId=$userId'),
      );

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(utf8.decode(response.bodyBytes));
        if (jsonResponse['code'] == 200 && jsonResponse['result'] != null) {
          _orders = (jsonResponse['result'] as List)
              .map((item) => Order.fromJson(item))
              .toList();
          _errorMessage = '';
        } else {
          _orders = [];
          _errorMessage = '';
        }
      } else {
        _orders = [];
        _errorMessage = 'Failed to load orders: ${response.statusCode}';
      }
    } catch (error) {
      _orders = [];
      _errorMessage = 'An error occurred: $error';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
