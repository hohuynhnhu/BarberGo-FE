// lib/routes/app_router.dart

import 'package:barbergofe/viewmodels/auth/auth_viewmodel.dart';
import 'package:barbergofe/views/profile/change_password_page.dart';
import 'package:barbergofe/views/profile/personal_info_page..dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'package:barbergofe/core/utils/auth_storage.dart';
import 'package:barbergofe/routes/route_names.dart';
import 'package:barbergofe/routes/shell_routes.dart';

import 'package:barbergofe/views/intro/Screen_intro.dart';
import 'package:barbergofe/views/auth/SignIn_page.dart';
import 'package:barbergofe/views/auth/SignUp_page.dart';
import 'package:barbergofe/views/OTP/page/otp_page.dart';
import 'package:barbergofe/views/forgotPass/forgotPass_page.dart';
import 'package:barbergofe/views/newPass/newPass_page.dart';
import 'package:barbergofe/views/succes/succes_page.dart';
import 'package:barbergofe/views/not_found_page.dart';

import 'package:barbergofe/views/detail_shop/detail_shop_page.dart';
import 'package:barbergofe/views/acne/acne_camera_view.dart';
import 'package:barbergofe/viewmodels/acne_viewmodel.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: RouteNames.getStarted,

    // ==================== REDIRECT LOGIC ====================
    redirect: (context, state) async {
      print('[ROUTER] Checking redirect for: ${state.uri.path}');

      final hasSeenIntro = await AuthStorage.hasSeenIntro();
      final isLoggedIn = await AuthStorage.isLoggedIn();

      print('   Has seen intro: $hasSeenIntro');
      print('   Is logged in: $isLoggedIn');

      final currentPath = state.uri.path;

      // 1. Chưa xem intro → vào intro
      if (!hasSeenIntro && currentPath != RouteNames.getStarted) {
        return RouteNames.getStarted;
      }

      // 2. Đã xem + chưa login + đang ở intro → chuyển login
      if (hasSeenIntro && !isLoggedIn && currentPath == RouteNames.getStarted) {
        return RouteNames.signin;
      }

      // 3. Đã login → không cho vào trang auth nữa
      if (isLoggedIn && _isAuthPage(currentPath)) {
        return RouteNames.home;
      }

      // 4. Chưa login → không được vào trang cần login
      if (!isLoggedIn && _isProtectedPage(currentPath)) {
        return RouteNames.signin;
      }

      return null;
    },

    // ==================== ROUTES ====================
    routes: [
      GoRoute(
        path: RouteNames.getStarted,
        name: 'intro',
        builder: (context, state) => const IntroScreen(),
      ),

      GoRoute(
        path: RouteNames.signin,
        name: 'signin',
        builder: (context, state) => const SignInPage(),
      ),

      GoRoute(
        path: RouteNames.signup,
        name: 'signup',
        builder: (context, state) => const SignupPage(),
      ),

      // GoRoute(
      //   path: RouteNames.otp,
      //   name: 'otp',
      //   builder: (context, state) => const OtpPage(),
      // ),

      GoRoute(
        path: RouteNames.forgot,
        name: 'forgot',
        builder: (context, state) => const ForgotpassPage(),
      ),

      GoRoute(
        path: RouteNames.newPass,
        name: 'newpass',
        builder: (context, state) => const NewpassPage(),
      ),

      GoRoute(
        path: RouteNames.succes,
        name: 'succes',
        builder: (context, state) => const SuccesPage(),
      ),

      GoRoute(
        path: RouteNames.acnes,
        name: 'acne',
        builder: (context, state) => ChangeNotifierProvider(
          create: (_) => AcneViewModel(),
          child: const AcneCameraView(),
        ),
      ),

      GoRoute(
        path: RouteNames.detail,
        name: 'detail',
        builder: (context, state) {
          final id = state.pathParameters['id'] ?? "";
          return DetailShopPage(id: id);
        },
      ),
      GoRoute(
        path: RouteNames.personal,
        name: 'personal',
        builder: (context, state) => ChangeNotifierProvider(
          create: (_) => AuthViewModel(),
          child: const PersonalInfoPage(),
        ),
      ),
      GoRoute(
        path: RouteNames.changePass,
        name: 'changePass',
        builder: (context, state) => const ChangePasswordPage(),
      ),
      shellRoutes,
    ],

    errorBuilder: (context, state) => const NotFoundPage(),
  );

  // ==================== HELPERS ====================

  static bool _isAuthPage(String path) {
    return path == RouteNames.signin ||
        path == RouteNames.signup ||
        path == RouteNames.otp ||
        path == RouteNames.forgot ||
        path == RouteNames.newPass ||
        path == RouteNames.getStarted;
  }

  static bool _isProtectedPage(String path) {
    return path == RouteNames.home ||
        path == RouteNames.acnes ||
        path.startsWith('/detail/');
  }
}
