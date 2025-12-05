import 'package:flutter/material.dart';

class SignUpViewModel extends ChangeNotifier {
  // Controllers
  final fullNameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController(); // ⭐ Thêm phone (optional)
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  // Loading state (chỉ cho validation)
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  // Validation errors
  String? fullNameError;
  String? emailError;
  String? phoneError;
  String? passwordError;
  String? confirmPasswordError;

  // ==================== VALIDATION ====================

  bool _validateFullName() {
    final fullName = fullNameController.text.trim();

    if (fullName.isEmpty) {
      fullNameError = 'Vui lòng nhập họ và tên';
      notifyListeners();
      return false;
    }

    if (fullName.length < 2) {
      fullNameError = 'Họ tên phải có ít nhất 2 ký tự';
      notifyListeners();
      return false;
    }

    fullNameError = null;
    notifyListeners();
    return true;
  }

  bool _validateEmail() {
    final email = emailController.text.trim();

    if (email.isEmpty) {
      emailError = 'Vui lòng nhập email';
      notifyListeners();
      return false;
    }

    // Simple email validation
    if (!email.contains('@') || !email.contains('.')) {
      emailError = 'Email không hợp lệ';
      notifyListeners();
      return false;
    }

    // More strict validation (optional)
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(email)) {
      emailError = 'Email không đúng định dạng';
      notifyListeners();
      return false;
    }

    emailError = null;
    notifyListeners();
    return true;
  }

  bool _validatePhone() {
    final phone = phoneController.text.trim();

    // Phone is optional
    if (phone.isEmpty) {
      phoneError = null;
      notifyListeners();
      return true;
    }

    // Validate Vietnamese phone number
    if (phone.length < 10 || phone.length > 11) {
      phoneError = 'Số điện thoại không hợp lệ';
      notifyListeners();
      return false;
    }

    // Check if all characters are digits
    if (!RegExp(r'^\d+$').hasMatch(phone)) {
      phoneError = 'Số điện thoại chỉ chứa số';
      notifyListeners();
      return false;
    }

    phoneError = null;
    notifyListeners();
    return true;
  }

  bool _validatePassword() {
    final password = passwordController.text;

    if (password.isEmpty) {
      passwordError = 'Vui lòng nhập mật khẩu';
      notifyListeners();
      return false;
    }

    if (password.length < 6) {
      passwordError = 'Mật khẩu phải có ít nhất 6 ký tự';
      notifyListeners();
      return false;
    }

    // Optional: Check for password strength
    // if (!RegExp(r'^(?=.*[A-Za-z])(?=.*\d)[A-Za-z\d]{6,}$').hasMatch(password)) {
    //   passwordError = 'Mật khẩu phải có cả chữ và số';
    //   notifyListeners();
    //   return false;
    // }

    passwordError = null;
    notifyListeners();
    return true;
  }

  bool _validateConfirmPassword() {
    final password = passwordController.text;
    final confirmPassword = confirmPasswordController.text;

    if (confirmPassword.isEmpty) {
      confirmPasswordError = 'Vui lòng xác nhận mật khẩu';
      notifyListeners();
      return false;
    }

    if (confirmPassword != password) {
      confirmPasswordError = 'Mật khẩu xác nhận không khớp';
      notifyListeners();
      return false;
    }

    confirmPasswordError = null;
    notifyListeners();
    return true;
  }

  // ==================== VALIDATE ALL ====================

  bool validateInputs() {
    print('🔵 [SIGNUP VIEWMODEL] Validating all fields...');

    final fullNameValid = _validateFullName();
    final emailValid = _validateEmail();
    final phoneValid = _validatePhone();
    final passwordValid = _validatePassword();
    final confirmPasswordValid = _validateConfirmPassword();

    final isValid = fullNameValid &&
        emailValid &&
        phoneValid &&
        passwordValid &&
        confirmPasswordValid;

    if (isValid) {
      print('✅ [SIGNUP VIEWMODEL] All fields valid');
    } else {
      print('❌ [SIGNUP VIEWMODEL] Validation failed');
      if (fullNameError != null) print('   - Full Name: $fullNameError');
      if (emailError != null) print('   - Email: $emailError');
      if (phoneError != null) print('   - Phone: $phoneError');
      if (passwordError != null) print('   - Password: $passwordError');
      if (confirmPasswordError != null) print('   - Confirm: $confirmPasswordError');
    }

    return isValid;
  }

  // ==================== SIGN UP ====================

  /// Sign up method - Returns true if validation passed
  /// Actual registration will be handled by AuthViewModel
  Future<bool> signUp() async {
    print('🔵 [SIGNUP VIEWMODEL] Sign up called');

    // Validate all fields
    if (!validateInputs()) {
      print('❌ [SIGNUP VIEWMODEL] Validation failed');
      return false;
    }

    _isLoading = true;
    notifyListeners();

    // Simulate a small delay for UX
    await Future.delayed(Duration(milliseconds: 300));

    _isLoading = false;
    notifyListeners();

    print('✅ [SIGNUP VIEWMODEL] Validation passed');
    return true;
  }

  // ==================== CLEAR ERRORS ====================

  void clearErrors() {
    fullNameError = null;
    emailError = null;
    phoneError = null;
    passwordError = null;
    confirmPasswordError = null;
    notifyListeners();
  }

  void clearError(String field) {
    switch (field) {
      case 'fullName':
        fullNameError = null;
        break;
      case 'email':
        emailError = null;
        break;
      case 'phone':
        phoneError = null;
        break;
      case 'password':
        passwordError = null;
        break;
      case 'confirmPassword':
        confirmPasswordError = null;
        break;
    }
    notifyListeners();
  }

  // ==================== HELPERS ====================

  /// Check if passwords match
  bool get passwordsMatch {
    return passwordController.text == confirmPasswordController.text;
  }

  /// Check if form is filled
  bool get isFormFilled {
    return fullNameController.text.isNotEmpty &&
        emailController.text.isNotEmpty &&
        passwordController.text.isNotEmpty &&
        confirmPasswordController.text.isNotEmpty;
  }

  // ==================== DISPOSE ====================

  @override
  void dispose() {
    fullNameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }
}