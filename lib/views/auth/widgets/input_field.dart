import 'package:flutter/material.dart';

class InputField extends StatelessWidget {
  final TextEditingController controller;
  final String? errorText;
  final bool obscureText;
  final String? hint;
  final bool enabled;
  final TextInputType keyboardType;

  const InputField({super.key, required this.controller,required this.hint, this.errorText, this.obscureText = false, this.enabled = true, this.keyboardType = TextInputType.text});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          obscureText: obscureText,
          enabled: enabled,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            errorText: errorText,
            hintText: hint,
            hintStyle: const TextStyle(
              color: Colors.grey, // màu chữ mờ
              fontSize: 14,       // kích thước chữ mờ (tuỳ chọn)
            ),
            border: const OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(12)),
            ),
          )
        ),
        const SizedBox(height: 12)
      ]
    );
  }
}
