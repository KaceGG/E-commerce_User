import 'package:ecommerce_user/models/category_model.dart';
import 'package:ecommerce_user/providers/auth_provider.dart';
import 'package:ecommerce_user/providers/cart_provider.dart';
import 'package:ecommerce_user/views/auth/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:ecommerce_user/models/product_model.dart';
import 'package:ecommerce_user/providers/category_provider.dart';
import 'package:google_fonts/google_fonts.dart';

class ProductDetailScreen extends StatefulWidget {
  final Product product;

  const ProductDetailScreen({super.key, required this.product});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  bool _hasFetchedCategories = false;

  @override
  void initState() {
    super.initState();
    // Trì hoãn việc gọi fetchCategories để tránh lỗi "setState() or markNeedsBuild() called during build"
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final categoryProvider =
          Provider.of<CategoryProvider>(context, listen: false);
      if (categoryProvider.categories.isEmpty &&
          !categoryProvider.isLoading &&
          !_hasFetchedCategories) {
        categoryProvider.fetchCategories();
        setState(() {
          _hasFetchedCategories = true;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final numberFormat = NumberFormat('#,###', 'vi_VN');

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.product.name,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.blueAccent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hình ảnh sản phẩm
            Container(
              width: double.infinity,
              height: 300,
              color: Colors.grey[200],
              child: Image.network(
                widget.product.imageUrl,
                fit: BoxFit.contain,
                width: double.infinity,
                height: 300,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return const Center(child: CircularProgressIndicator());
                },
                errorBuilder: (context, error, stackTrace) {
                  return const Center(
                    child: Icon(
                      Icons.image_not_supported,
                      size: 100,
                      color: Colors.grey,
                    ),
                  );
                },
              ),
            ),
            // Thông tin chi tiết
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Tên sản phẩm
                  const Text('Tên sản phẩm'),
                  Text(
                    widget.product.name,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Giá tiền
                  const Text('Giá tiền'),
                  Text(
                    '${numberFormat.format(widget.product.price)} VNĐ',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Colors.redAccent,
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Mô tả
                  const Text(
                    'Mô tả',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.product.description,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Danh mục
                  const Text(
                    'Danh mục',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Consumer<CategoryProvider>(
                    builder: (context, categoryProvider, child) {
                      if (categoryProvider.isLoading) {
                        return const Text(
                          'Đang tải danh mục...',
                          style: TextStyle(fontSize: 16, color: Colors.black54),
                        );
                      }

                      if (categoryProvider.errorMessage.isNotEmpty) {
                        return Text(
                          'Lỗi: ${categoryProvider.errorMessage}',
                          style:
                              const TextStyle(fontSize: 16, color: Colors.red),
                        );
                      }

                      if (categoryProvider.categories.isEmpty) {
                        return const Text(
                          'Không có danh mục',
                          style: TextStyle(fontSize: 16, color: Colors.black54),
                        );
                      }

                      // Ánh xạ categoryIds thành danh sách tên danh mục
                      final categoryNames =
                          widget.product.categoryIds.map((id) {
                        final category = categoryProvider.categories.firstWhere(
                          (cat) => cat.id == id,
                          orElse: () => Category(
                              id: id,
                              name: 'Không xác định',
                              description: 'Không xác định'),
                        );
                        return category.name;
                      }).toList();

                      return Text(
                        categoryNames.join(', '),
                        style: GoogleFonts.roboto(
                          fontSize: 16,
                          color: Colors.black54,
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  //Add to cart
                  Consumer<AuthProvider>(
                    builder: (context, authProvider, child) {
                      return Consumer<CartProvider>(
                        builder: (context, cartProvider, child) {
                          return Center(
                            child: ElevatedButton(
                              onPressed: () async {
                                if (!authProvider.isLoggedIn) {
                                  // Chưa đăng nhập, điều hướng đến màn hình đăng nhập
                                  final result = await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            const LoginScreen()),
                                  );
                                  // Nếu đăng nhập thành công, tiếp tục thêm vào giỏ hàng
                                  if (result != null &&
                                      authProvider.isLoggedIn) {
                                    print(authProvider.userId);
                                    final success =
                                        await cartProvider.addToCart(
                                      authProvider.userId!,
                                      widget.product.id,
                                    );
                                    if (success && mounted) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                            content:
                                                Text('Đã thêm vào giỏ hàng')),
                                      );
                                    } else {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                            content: Text(
                                                cartProvider.errorMessage)),
                                      );
                                    }
                                  }
                                } else {
                                  // Đã đăng nhập, gọi API để thêm vào giỏ hàng
                                  final success = await cartProvider.addToCart(
                                    authProvider.userId!,
                                    widget.product.id,
                                  );
                                  if (success && mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                          content:
                                              Text('Đã thêm vào giỏ hàng')),
                                    );
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                          content:
                                              Text(cartProvider.errorMessage)),
                                    );
                                  }
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blueAccent,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 32, vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: const Text(
                                'Thêm vào giỏ hàng',
                                style: TextStyle(
                                    fontSize: 16, color: Colors.white),
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
