import 'package:flutter/material.dart';

import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/register_page.dart';
import '../../features/auth/presentation/pages/profile_page.dart';

Map<String, WidgetBuilder> appRoutes() {
  return {
    '/login': (context) => const LoginPage(),
    '/register': (context) => const RegisterPage(),
    '/profile': (context) => const ProfilePage(),
  };
}
