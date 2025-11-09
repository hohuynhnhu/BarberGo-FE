import 'package:barbergofe/core/constants/app_strings.dart';
import 'package:barbergofe/core/theme/AppImages.dart';
import 'package:barbergofe/core/utils/intro_service.dart';
import 'package:barbergofe/models/intro/intro_model.dart';
import 'package:flutter/cupertino.dart';
// sử dụng changenotifier với mục đích cập nhật giao diện khi có sự thay đổi trong dữ liệu.
class IntroViewModel extends ChangeNotifier{
  final List<IntroModel> introList = [
    IntroModel(title: IntroStrings.welcome, textbtn:IntroStrings.btnbegin, imageUrl: AppImages.logo),
    IntroModel(title: IntroStrings.intro1, textbtn: IntroStrings.btnnext, imageUrl: AppImages.logo),
    IntroModel(title: IntroStrings.intro2, textbtn: IntroStrings.btnexp, imageUrl: AppImages.logo),
  ];
  /// Lưu trạng thái đã xem intro
  Future<void> onGet() async {
    await IntroService.setIntroSeen();
  }
}