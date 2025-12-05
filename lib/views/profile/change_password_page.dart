import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:barbergofe/viewmodels/auth/auth_viewmodel.dart';
import 'widgets/password_input_field.dart';

class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({Key? key}) : super(key: key);

  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  // Validation errors
  String? _currentPasswordError;
  String? _newPasswordError;
  String? _confirmPasswordError;

  bool _isLoading = false;

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  // ==================== VALIDATION ====================

  bool _validateInputs() {
    setState(() {
      _currentPasswordError = null;
      _newPasswordError = null;
      _confirmPasswordError = null;
    });

    bool isValid = true;

    // Validate current password
    if (_currentPasswordController.text.isEmpty) {
      setState(() {
        _currentPasswordError = 'Vui lòng nhập mật khẩu hiện tại';
      });
      isValid = false;
    }

    // Validate new password
    if (_newPasswordController.text.isEmpty) {
      setState(() {
        _newPasswordError = 'Vui lòng nhập mật khẩu mới';
      });
      isValid = false;
    } else if (_newPasswordController.text.length < 6) {
      setState(() {
        _newPasswordError = 'Mật khẩu phải có ít nhất 6 ký tự';
      });
      isValid = false;
    } else if (_newPasswordController.text == _currentPasswordController.text) {
      setState(() {
        _newPasswordError = 'Mật khẩu mới phải khác mật khẩu hiện tại';
      });
      isValid = false;
    }

    // Validate confirm password
    if (_confirmPasswordController.text.isEmpty) {
      setState(() {
        _confirmPasswordError = 'Vui lòng xác nhận mật khẩu mới';
      });
      isValid = false;
    } else if (_confirmPasswordController.text != _newPasswordController.text) {
      setState(() {
        _confirmPasswordError = 'Mật khẩu xác nhận không khớp';
      });
      isValid = false;
    }

    return isValid;
  }

  // ==================== HANDLE CHANGE PASSWORD ====================

  Future<void> _handleChangePassword() async {
    // Validate
    if (!_validateInputs()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // TODO: Call API to change password
      // final authVM = context.read<AuthViewModel>();
      // final success = await authVM.changePassword(
      //   currentPassword: _currentPasswordController.text,
      //   newPassword: _newPasswordController.text,
      // );

      // Simulate API call
      await Future.delayed(Duration(seconds: 2));

      setState(() {
        _isLoading = false;
      });

      // Show success dialog
      _showSuccessDialog();

    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lỗi: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // ==================== SUCCESS DIALOG ====================

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green, size: 28),
            SizedBox(width: 12),
            Text('Thành công'),
          ],
        ),
        content: Text(
          'Mật khẩu của bạn đã được thay đổi thành công.',
          style: TextStyle(fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              context.pop(); // Go back to profile
            },
            child: Text(
              'OK',
              style: TextStyle(
                color: Color(0xFF5B4B8A),
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==================== BUILD ====================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF5B4B8A),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'ĐỔI MẬT KHẨU',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                // ==================== MAIN CONTAINER ====================

                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // ==================== CURRENT PASSWORD ====================

                      PasswordInputField(
                        controller: _currentPasswordController,
                        label: 'Nhập mật khẩu hiện tại',
                        errorText: _currentPasswordError,
                      ),

                      const SizedBox(height: 24),

                      // ==================== NEW PASSWORD ====================

                      PasswordInputField(
                        controller: _newPasswordController,
                        label: 'Nhập mật khẩu mới',
                        errorText: _newPasswordError,
                      ),

                      const SizedBox(height: 24),

                      // ==================== CONFIRM PASSWORD ====================

                      PasswordInputField(
                        controller: _confirmPasswordController,
                        label: 'Nhập mật khẩu lại mật khẩu mới',
                        errorText: _confirmPasswordError,
                      ),

                      const SizedBox(height: 40),

                      // ==================== SUBMIT BUTTON ====================

                      ElevatedButton(
                        onPressed: _isLoading ? null : _handleChangePassword,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFB8A4E8),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          elevation: 0,
                        ),
                        child: _isLoading
                            ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                            : const Text(
                          'XÁC NHẬN',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}