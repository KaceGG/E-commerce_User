import 'package:ecommerce_user/providers/category_provider.dart';
import 'package:ecommerce_user/providers/product_provider.dart';
import 'package:ecommerce_user/routes/app_router.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => CategoryProvider()),
        ChangeNotifierProvider(create: (context) => ProductProvider()),
      ],
      child: MaterialApp.router(
        routerConfig: AppRouter.router,
        title: 'Ecommerce App',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
      ),
    );
  }
}
