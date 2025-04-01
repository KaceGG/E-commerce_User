import 'package:ecommerce_user/providers/category_provider.dart';
import 'package:ecommerce_user/providers/product_provider.dart';
import 'package:ecommerce_user/views/home/product_details_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class ProductScreen extends StatefulWidget {
  const ProductScreen({super.key});

  @override
  State<ProductScreen> createState() => _ProductScreenState();
}

class _ProductScreenState extends State<ProductScreen> {
  String _selectedCategory = 'Tất cả';
  bool _isInitialized = false;

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      if (!_isInitialized) {
        final categoryProvider =
            Provider.of<CategoryProvider>(context, listen: false);
        final productProvider =
            Provider.of<ProductProvider>(context, listen: false);
        categoryProvider.fetchCategories();
        if (productProvider.products.isEmpty && !productProvider.isLoading) {
          productProvider.fetchProducts();
        }
        _isInitialized = true;
      }
    });
    super.initState();
  }

  Future<void> _refreshData() async {
    await Future.delayed(const Duration(seconds: 1));
    setState(() {
      Provider.of<CategoryProvider>(context, listen: false).fetchCategories();
      Provider.of<ProductProvider>(context, listen: false).fetchProducts();
    });
  }

  @override
  Widget build(BuildContext context) {
    final numberFormat = NumberFormat("#,###", "vi_VN");

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Sản phẩm',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.blueAccent,
        elevation: 0,
      ),
      body: RefreshIndicator(
        onRefresh: _refreshData,
        child: Container(
          color: Colors.white,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Consumer<CategoryProvider>(
                  builder: (context, categoryProvider, child) {
                    final categories = ['Tất cả'] +
                        categoryProvider.categories
                            .map((cat) => cat.name)
                            .toList();
                    return SizedBox(
                      width: double.infinity,
                      child: DropdownButton<String>(
                        isExpanded: true,
                        value: _selectedCategory,
                        onChanged: (value) {
                          setState(() {
                            _selectedCategory = value!;
                            final productProvider =
                                Provider.of<ProductProvider>(context,
                                    listen: false);
                            if (_selectedCategory == 'Tất cả') {
                              productProvider.fetchProducts();
                            } else {
                              final selectedCategory =
                                  categoryProvider.categories.firstWhere(
                                      (cat) => cat.name == _selectedCategory);
                              productProvider
                                  .fetchProductsByCategory(selectedCategory.id);
                            }
                          });
                        },
                        items: categories.map((category) {
                          return DropdownMenuItem<String>(
                            value: category,
                            child: Text(category, style: GoogleFonts.poppins()),
                          );
                        }).toList(),
                      ),
                    );
                  },
                ),
              ),
              Expanded(
                child: Consumer<ProductProvider>(
                  builder: (context, productProvider, child) {
                    if (productProvider.isLoading) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (productProvider.errorMessage.isNotEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              productProvider.errorMessage,
                              style: GoogleFonts.poppins(color: Colors.red),
                            ),
                            const SizedBox(height: 20),
                            ElevatedButton(
                              onPressed: () => productProvider.fetchProducts(),
                              child:
                                  Text('Thử lại', style: GoogleFonts.poppins()),
                            ),
                          ],
                        ),
                      );
                    }

                    if (productProvider.products.isEmpty) {
                      return Center(
                        child: Text('Không có sản phẩm',
                            style: GoogleFonts.poppins()),
                      );
                    }

                    return GridView.builder(
                      padding: const EdgeInsets.all(16.0),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 16.0,
                        mainAxisSpacing: 16.0,
                        childAspectRatio: 0.65,
                      ),
                      itemCount: productProvider.products.length,
                      itemBuilder: (context, index) {
                        final product = productProvider.products[index];
                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      ProductDetailScreen(product: product)),
                            );
                          },
                          child: Card(
                            elevation: 5,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                ClipRRect(
                                  borderRadius: const BorderRadius.vertical(
                                      top: Radius.circular(15)),
                                  child: Image.network(
                                    product.imageUrl,
                                    height: 150,
                                    width: double.infinity,
                                    fit: BoxFit.contain,
                                    loadingBuilder:
                                        (context, child, loadingProgress) {
                                      if (loadingProgress == null) return child;
                                      return Container(
                                        height: 150,
                                        color: Colors.grey[200],
                                        child: const Center(
                                          child: CircularProgressIndicator(),
                                        ),
                                      );
                                    },
                                    errorBuilder: (context, error, stackTrace) {
                                      return Container(
                                        height: 150,
                                        color: Colors.grey[200],
                                        child: const Icon(
                                          Icons.image_not_supported,
                                          size: 50,
                                          color: Colors.grey,
                                        ),
                                      );
                                    },
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(12.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        product.name,
                                        style: GoogleFonts.poppins(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                          color: Colors.black87,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        '${numberFormat.format(product.price)} VNĐ',
                                        style: GoogleFonts.poppins(
                                          color: Colors.redAccent,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
