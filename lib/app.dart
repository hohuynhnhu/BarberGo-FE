import 'package:barbergofe/core/theme/app_theme.dart';
import 'package:barbergofe/routes/app_router.dart';
import 'package:barbergofe/viewmodels/auth/auth_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:barbergofe/core/constants/app_strings.dart';
import 'package:provider/provider.dart';
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(providers: [
      ChangeNotifierProvider(create: (_) => AuthViewModel()..init()),
    ],
      child:
      MaterialApp.router(
      title: CommonStrings.appName,
      debugShowCheckedModeBanner: false,
      routerConfig: AppRouter.router,
      theme: AppTheme.lightTheme,
    )
    );
  }
}


