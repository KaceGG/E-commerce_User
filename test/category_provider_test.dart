import 'package:flutter_test/flutter_test.dart';
import 'package:ecommerce_user/providers/category_provider.dart';
import 'package:http/http.dart' as http;
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'dart:convert';

// Generate the mock file using the command:
// flutter pub run build_runner build

@GenerateMocks([http.Client])
import 'category_provider_test.mocks.dart';

void main() {
  group('CategoryProvider Test', () {
    test(
        'fetchCategories() returns categories if the HTTP call completes successfully',
        () async {
      final client = MockClient();
      final provider = CategoryProvider();

      final mockResponse = {
        "code": 200,
        "result": [
          {"id": 1, "name": "Điện thoại", "description": "Thiết bị di động"},
          {"id": 2, "name": "Laptop", "description": "Máy tính xách tay"}
        ]
      };

      when(client.get(Uri.parse(CategoryProvider.BASE_URL))).thenAnswer(
          (_) async => http.Response(jsonEncode(mockResponse), 200));

      await provider.fetchCategories();

      expect(provider.categories.length, 2);
      expect(provider.categories.first.name, "Điện thoại");
      expect(provider.errorMessage, '');
    });

    test('fetchCategories() returns error message if the HTTP call fails',
        () async {
      final client = MockClient();
      final provider = CategoryProvider();

      when(client.get(Uri.parse(CategoryProvider.BASE_URL)))
          .thenAnswer((_) async => http.Response('Not Found', 404));

      await provider.fetchCategories();

      expect(provider.categories.isEmpty, true);
      expect(provider.errorMessage, isNotEmpty);
    });
  });
}
