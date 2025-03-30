import 'package:ecommerce_user/views/auth/login_screen.dart';
import 'package:ecommerce_user/views/auth/register_screen.dart';
import 'package:ecommerce_user/views/home/home_screen.dart';
import 'package:go_router/go_router.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => RegisterScreen(),
      ),
    ],
  );
}
