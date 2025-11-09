import 'package:flutter/material.dart';

class PasswordField extends StatefulWidget {
  final TextEditingController controller;
  final String? textError;
  const PasswordField({super.key, required this.controller, this.textError});

  @override
  State<PasswordField> createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<PasswordField> {
  bool _obscureText = true;
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: widget.controller,
          obscureText: _obscureText,
        decoration: InputDecoration(
          errorText: widget.textError,
          filled: true,
          fillColor: Colors.white,
          border: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(12)),
          ),
          suffixIcon: IconButton(onPressed: () => setState(() => _obscureText = !_obscureText
          ), icon: Icon(_obscureText ? Icons.visibility : Icons.visibility_off))
        ),
        ),
        const SizedBox(height: 12)
      ],
    );
  }
}
