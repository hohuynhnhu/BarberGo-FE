import 'package:barbergofe/models/auth/user_model.dart';
import 'package:flutter/cupertino.dart';

class SignUpViewModel extends ChangeNotifier {
  final fullNameController=TextEditingController();
  final emailController=TextEditingController();
  final passwordController=TextEditingController();
  final confirmPasswordController=TextEditingController();
  bool isLoading =false;
  String? fullNameError;
  String? emailError;
  String? passwordError;
  String? confirmPasswordError;
  //hàm kiểm tra dữ liệu nhập vào
  bool validateInputs(){
    bool isValid=true;
    fullNameError=fullNameController.text.isNotEmpty?null:"Họ và tên không được để trống";
    emailError=emailController.text.isNotEmpty?null:"Email không hợp lệ";
    passwordError=passwordController.text.isNotEmpty?null:"Mật khẩu không hợp lệ";
    confirmPasswordError=confirmPasswordController.text == passwordController.text
    ?null
        :"Xác nhận mật khẩu không khớp";
    if(fullNameError !=null || emailError !=null || passwordError !=null || confirmPasswordError != null){
      isValid=false;
    }
    notifyListeners();
    return isValid;
    }
    //hàm đăng ký tài khoản mới
    Future<bool> signUp() async{
    if(!validateInputs()) return false;
    isLoading=true;
    notifyListeners();

    final user =User(fullName: fullNameController.text, email: emailController.text, password: passwordController.text);
    await Future.delayed(const Duration(seconds: 1));// mô phỏng gọi API
    isLoading =false;
    notifyListeners();
    return true;
    }
    //hàm hủy controller
    void disposeController(){
    fullNameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    }
  }
