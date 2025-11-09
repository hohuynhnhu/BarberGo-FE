import 'package:barbergofe/core/constants/color.dart';
import 'package:barbergofe/core/theme/text_styles.dart';
import 'package:barbergofe/models/intro/intro_model.dart';
import 'package:flutter/material.dart';

class IntroContent extends StatelessWidget {
  final IntroModel model;
  const IntroContent({super.key, required this.model});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              // Hình tròn nền
              Container(
                width: 300, // kích thước vòng tròn
                height: 314,
                decoration: const BoxDecoration(
                  color:AppColors.primary, // tím nhạt
                  shape: BoxShape.circle,
                ),
              ),

              // Hình ảnh nằm giữa
              Image.asset(
                model.imageUrl,
                width: 280, // điều chỉnh theo logo bạn
                height: 250,
                fit: BoxFit.contain,
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Tiêu đề
          Text(
            model.title,
            textAlign: TextAlign.center,
            style: AppTextStyles.heading,
          ),
        ],
      ),
    );
  }
}
