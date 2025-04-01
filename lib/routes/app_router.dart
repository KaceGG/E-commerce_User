import 'package:ecommerce_user/views/auth/login_screen.dart';
import 'package:ecommerce_user/views/auth/register_screen.dart';
import 'package:ecommerce_user/views/home/home_screen.dart';
import 'package:ecommerce_user/views/main_screen.dart';
import 'package:ecommerce_user/views/product/product_screen.dart';
import 'package:ecommerce_user/views/cart/cart_screen.dart';
import 'package:go_router/go_router.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const MainScreen(),
      ),
      GoRoute(
        path: '/home',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/products',
        builder: (context, state) => const ProductScreen(),
      ),
      GoRoute(
        path: '/cart',
        builder: (context, state) => const CartScreen(),
      )
    ],
  );
}
