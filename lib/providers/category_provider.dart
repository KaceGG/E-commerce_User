// ignore_for_file: avoid_print

import 'dart:convert';

import 'package:ecommerce_user/DTO/response/api_response.dart';
import 'package:ecommerce_user/models/category_model.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class CategoryProvider extends ChangeNotifier {
  // ignore: constant_identifier_names
  static const String BASE_URL = 'http://192.168.1.119:8080/category';

  List<Category> _categories = [];
  bool _isLoading = false;
  String _errorMessage = '';

  List<Category> get categories => _categories;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;

  Future<void> fetchCategories() async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await http.get(Uri.parse('$BASE_URL/getAll'));

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(utf8.decode(response.bodyBytes));

        final apiResponse = ApiResponse<List<Category>>.fromJson(
          jsonResponse,
          (json) => (json as List)
              .map((data) => Category.fromJSON(data as Map<String, dynamic>))
              .toList(),
        );

        if (apiResponse.code == 200 && apiResponse.result != null) {
          _categories = apiResponse.result!;
          _errorMessage = '';
        } else {
          _errorMessage = apiResponse.message ?? 'Lỗi không xác định';
        }
      } else {
        _errorMessage = 'Failed to load categories: ${response.reasonPhrase}';
      }
    } catch (error) {
      _errorMessage = 'An error occurred: $error';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
