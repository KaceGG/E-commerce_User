// ignore_for_file: constant_identifier_names

import 'dart:convert';
import 'package:ecommerce_user/models/order_model.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class OrderProvider extends ChangeNotifier {
  static const String BASE_URL = 'http://192.168.1.119:8080';
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
        Uri.parse('$BASE_URL/order?userId=$userId'),
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${utf8.decode(response.bodyBytes)}');

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(utf8.decode(response.bodyBytes));
        if (jsonResponse['code'] == 200 && jsonResponse['result'] != null) {
          _orders = (jsonResponse['result'] as List)
              .map((item) => Order.fromJson(item))
              .toList();
          _errorMessage = '';
        } else {
          _errorMessage =
              jsonResponse['message'] ?? 'Failed to retrieve orders';
          _orders = [];
        }
      } else {
        _errorMessage = 'Failed to load orders: ${response.statusCode}';
        _orders = [];
      }
    } catch (error) {
      _errorMessage = 'An error occurred: $error';
      _orders = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
