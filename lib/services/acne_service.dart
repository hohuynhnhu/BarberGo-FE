// import 'dart:convert';
// import 'dart:io';
// import '../api/acne_api.dart';
// import '../models/acne/acne_response.dart';
//
// class AcneService {
//
//   final AcneApi api = AcneApi();
//
//   Future<AcneResponse> detectAcne(
//       File left, File front, File right) async {
//     final jsonString =
//     await api.detectAcne(left: left, front: front, right: right);
//
//     final data = jsonDecode(jsonString);
//     print('🔵 Bắt đầu gửi ảnh...');
//     print('Left: ${left.path}');
//     print('Front: ${front.path}');
//     print('Right: ${right.path}');
//     return AcneResponse.fromJson(data);
//   }
// }
import 'dart:convert';
import 'dart:io';
import '../api/acne_api.dart';
import '../models/acne/acne_response.dart';

class AcneService {
  final AcneApi api = AcneApi();

  Future<AcneResponse> detectAcne(
      File left, File front, File right) async {

    // ✅ ĐẶT LOG Ở ĐẦU - TRƯỚC KHI GỌI API
    print('🔵 [SERVICE] Bắt đầu gửi ảnh...');
    print('📂 Left: ${left.path}');
    print('📂 Front: ${front.path}');
    print('📂 Right: ${right.path}');

    try {
      // Gọi API
      final jsonString = await api.detectAcne(
          left: left,
          front: front,
          right: right
      );

      print('✅ [SERVICE] Nhận được response: $jsonString');

      // Parse JSON
      final data = jsonDecode(jsonString);
      print('📦 [SERVICE] Data đã parse: $data');

      return AcneResponse.fromJson(data);

    } catch (e) {
      print('❌ [SERVICE] Lỗi khi gọi API: $e');
      rethrow; // Ném lỗi lên ViewModel
    }
  }
}