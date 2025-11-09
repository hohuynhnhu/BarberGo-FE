import 'dart:ui';
import 'package:barbergofe/core/theme/AppImages.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:barbergofe/viewmodels/auth/signup_viewmodel.dart';
import 'package:barbergofe/views/auth/widgets/input_field.dart';
import 'package:barbergofe/views/auth/widgets/password_field.dart';
import 'package:barbergofe/views/auth/widgets/auth_button.dart';
import 'package:barbergofe/core/theme/text_styles.dart';

class SignupPage extends StatelessWidget {
  const SignupPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => SignUpViewModel(),
      child: Consumer<SignUpViewModel>(
        builder: (context, viewModel, _) {
          return Scaffold(
            extendBodyBehindAppBar: true, // nền xuyên suốt
            body: Container(
              width: double.infinity,
              height: double.infinity,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFFD9D9D9), Color(0xFFEAEAEA)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: Stack(
                children: [
                  Positioned(
                    left: -229,
                    top: -58,
                    child: Container(
                      width: 580,
                      height: 580,
                      decoration: const BoxDecoration(
                        color: Color(0xFF67539D), // màu 67539D
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),

                  Positioned(
                    left: 150,
                    top: -37,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Hình tròn
                        Container(
                          width: 276,
                          height: 285,
                          decoration: const BoxDecoration(
                            color: Color(0xFF590798),
                            shape: BoxShape.circle,
                          ),
                        ),

                        // Nội dung text + ảnh nằm trên hình tròn
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // Text 2 dòng
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: const [
                                Text(
                                  "Barber Go",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  "Style Hair",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(width: 8), // khoảng cách giữa text và ảnh

                            // Hình ảnh
                            Image.asset(AppImages.logo,
                              width: 98,
                              height: 83,
                              fit: BoxFit.contain,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  // Tiêu đề "ĐĂNG KÝ"
                  Positioned(
                    top: 242, // khoảng cách từ trên màn hình
                    left: 16,
                    child: const Text(
                      "ĐĂNG KÝ",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        decoration: TextDecoration.underline,
                        decorationColor: Colors.white,
                        decorationThickness: 2,
                      ),
                    ),
                  ),

                  // Container chính
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(44),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: const Color(0x4DD9D9D9),
                              borderRadius: BorderRadius.circular(44),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                              border: Border.all(
                                color: Colors.white.withOpacity(0.3),
                                width: 1.2,
                              ),
                            ),
                            child: SingleChildScrollView(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("Họ và Tên"),
                                  InputField(
                                    controller: viewModel.fullNameController,
                                    errorText: viewModel.fullNameError,
                                    hint: "Nhập họ và tên của bạn",
                                  ),
                                  Text("Email"),
                                  InputField(
                                    controller: viewModel.emailController,
                                    errorText: viewModel.emailError,
                                    hint: "Nhập email của bạn",

                                  ),
                                  Text("Mật khẩu"),
                                  PasswordField(
                                    controller: viewModel.passwordController,
                                    textError: viewModel.passwordError,
                                  ),
                                  Text("Nhập lại mật khẩu"),
                                  PasswordField(
                                    controller: viewModel.confirmPasswordController,
                                    textError: viewModel.confirmPasswordError,

                                  ),
                                  const SizedBox(height: 24),
                                  Align(
                                    alignment: Alignment.center,
                                    child: AppButton(
                                      onPressed: viewModel.signUp,
                                      isLoading: viewModel.isLoading,
                                      text: 'ĐĂNG KÝ',
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Text("Đã có tài khoản?"),
                                      TextButton(
                                        onPressed: () {},
                                        child: const Text(
                                          "Đăng nhập ngay",
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black,
                                            decoration: TextDecoration.underline,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
