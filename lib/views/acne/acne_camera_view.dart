import 'dart:io';

import 'package:barbergofe/viewmodels/acne_viewmodel.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

class AcneCameraView extends StatefulWidget {
  const AcneCameraView({Key? key}) : super(key: key);

  @override
  State<AcneCameraView> createState() => _AcneCameraViewState();
}

class _AcneCameraViewState extends State<AcneCameraView> {
  CameraController? _controller;
  List<CameraDescription>? _cameras;
  bool _isPermissionGranted = false;
  bool _isLoading = true;
  String? _permissionError;

  @override
  void initState() {
    super.initState();
    _requestPermissionAndInitCamera();
  }

  // XIN QUYỀN VÀ KHỞI TẠO CAMERA
  Future<void> _requestPermissionAndInitCamera() async {
    setState(() {
      _isLoading = true;
      _permissionError = null;
    });

    final status = await Permission.camera.request();

    if (status.isGranted) {
      setState(() {
        _isPermissionGranted = true;
      });
      await initCamera();
    } else if (status.isPermanentlyDenied) {
      setState(() {
        _isPermissionGranted = false;
        _isLoading = false;
        _permissionError = 'Quyền camera bị từ chối vĩnh viễn. Vui lòng mở Cài đặt để cấp quyền.';
      });
    } else {
      setState(() {
        _isPermissionGranted = false;
        _isLoading = false;
        _permissionError = 'Cần quyền truy cập camera để tiếp tục.';
      });
    }
  }

  Future<void> initCamera() async {
    try {
      _cameras = await availableCameras();
      if (_cameras != null && _cameras!.isNotEmpty) {
        CameraDescription frontCamera = _cameras!.firstWhere(
              (camera) => camera.lensDirection == CameraLensDirection.front,
          orElse: () => _cameras!.first,
        );

        _controller = CameraController(
          frontCamera,
          ResolutionPreset.high, // ✅ Tăng chất lượng
          enableAudio: false,
        );

        await _controller!.initialize();
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      } else {
        setState(() {
          _isLoading = false;
          _permissionError = 'Không tìm thấy camera trên thiết bị.';
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _permissionError = 'Lỗi khởi tạo camera: $e';
      });
    }
  }

  Future<File?> takePicture() async {
    if (_controller == null || !_controller!.value.isInitialized) return null;

    try {
      final XFile file = await _controller!.takePicture();

      final dir = await getApplicationDocumentsDirectory();
      final String newPath =
      path.join(dir.path, '${DateTime.now().millisecondsSinceEpoch}.jpg');

      final newFile = await File(file.path).copy(newPath);
      return newFile;
    } catch (e) {
      print('Lỗi khi chụp ảnh: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi chụp ảnh: $e'), backgroundColor: Colors.red),
      );
      return null;
    }
  }

  String getStepLabel(int step) {
    switch (step) {
      case 0:
        return "Mặt trái";
      case 1:
        return "Chính diện";
      case 2:
        return "Mặt phải";
      default:
        return "Hoàn tất";
    }
  }

  void _showPermissionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cần quyền truy cập'),
        content: const Text(
          'Ứng dụng cần quyền camera để chụp ảnh phát hiện mụn. Vui lòng mở Cài đặt để cấp quyền.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              openAppSettings();
            },
            child: const Text('Mở Cài đặt'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<AcneViewModel>(context);

    // TRẠNG THÁI ĐANG LOADING
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          // title: const Text("Phát hiện mụn"),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context),
          ),
        ),

        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 20),
              Text('Đang khởi tạo camera...'),
            ],
          ),
        ),
      );
    }

    // TRẠNG THÁI KHÔNG CÓ QUYỀN
    if (!_isPermissionGranted || _permissionError != null) {
      return Scaffold(
        appBar: AppBar(title: const Text("Phát hiện mụn")),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.camera_alt, size: 80, color: Colors.grey),
                const SizedBox(height: 20),
                Text(
                  _permissionError ?? 'Cần quyền truy cập camera',
                  style: const TextStyle(fontSize: 16),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 30),
                ElevatedButton.icon(
                  onPressed: _requestPermissionAndInitCamera,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Thử lại'),
                ),
                const SizedBox(height: 10),
                TextButton(
                  onPressed: _showPermissionDialog,
                  child: const Text('Mở Cài đặt'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // TRẠNG THÁI CAMERA KHÔNG KHẢ DỤNG
    if (_controller == null || !_controller!.value.isInitialized) {
      return Scaffold(
        appBar: AppBar(title: const Text("Phát hiện mụn")),
        body: const Center(
          child: Text('Camera không khả dụng'),
        ),
      );
    }

    // ✅ UI MỚI - CAMERA LỚN, CHI TIẾT NHỎ
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text("Phát hiện mụn", style: TextStyle(fontSize: 16)),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          // ✅ CAMERA PREVIEW - CHIẾM PHẦN LỚN MÀN HÌNH
          Expanded(
            flex: 7, // 70% màn hình
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Camera
                CameraPreview(_controller!),

                // Overlay hướng dẫn góc chụp (nếu muốn)
                Positioned(
                  top: 10,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.6),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.camera_alt, color: Colors.white, size: 16),
                          const SizedBox(width: 6),
                          Text(
                            vm.captureStep >= 3
                                ? "✓ Hoàn tất"
                                : "Chụp: ${getStepLabel(vm.captureStep)}",
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // Nút chụp ảnh nổi
                Positioned(
                  bottom: 20,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: GestureDetector(
                      onTap: vm.captureStep >= 3
                          ? null
                          : () async {
                        final file = await takePicture();
                        if (file != null) {
                          vm.setImage(file);
                        }
                      },
                      child: Container(
                        width: 70,
                        height: 70,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: vm.captureStep >= 3
                              ? Colors.grey
                              : Colors.white,
                          border: Border.all(
                            color: Colors.white,
                            width: 4,
                          ),
                        ),
                        child: Icon(
                          Icons.camera_alt,
                          color: vm.captureStep >= 3
                              ? Colors.white54
                              : Colors.black,
                          size: 32,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ✅ PHẦN ĐIỀU KHIỂN - CHIẾM 30% MÀN HÌNH
          Expanded(
            flex: 3,
            child: Container(
              color: Colors.grey.shade900,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Column(
                children: [
                  // Thumbnail ảnh đã chụp - nhỏ gọn
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildSmallThumbnail("Trái", vm.leftImage),
                      const SizedBox(width: 8),
                      _buildSmallThumbnail("Giữa", vm.frontImage),
                      const SizedBox(width: 8),
                      _buildSmallThumbnail("Phải", vm.rightImage),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // Nút phát hiện mụn
                  SizedBox(
                    width: double.infinity,
                    height: 45,
                    child: ElevatedButton.icon(
                      onPressed: vm.isCaptureDone && !vm.isLoading
                          ? () async {
                        await vm.detect();

                        if (vm.error != null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text("Lỗi: ${vm.error}"),
                              backgroundColor: Colors.red,
                            ),
                          );
                        } else if (vm.response != null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                "Phát hiện thành công! Tổng mụn: ${vm.response!.data.totalAcne}",
                              ),
                              backgroundColor: Colors.green,
                            ),
                          );
                        }
                      }
                          : null,
                      icon: vm.isLoading
                          ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                          : const Icon(Icons.search, size: 20),
                      label: Text(
                        vm.isLoading ? "Đang phân tích..." : "Phát hiện mụn",
                        style: const TextStyle(fontSize: 15),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Nút chụp lại
                  TextButton.icon(
                    onPressed: () {
                      vm.reset();
                    },
                    icon: const Icon(Icons.refresh, size: 18),
                    label: const Text("Chụp lại", style: TextStyle(fontSize: 13)),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ✅ Thumbnail nhỏ gọn
  Widget _buildSmallThumbnail(String label, File? image) {
    return Column(
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            border: Border.all(
              color: image != null ? Colors.green : Colors.grey.shade600,
              width: 2,
            ),
            borderRadius: BorderRadius.circular(8),
            color: Colors.grey.shade800,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: image != null
                ? Image.file(
              image,
              fit: BoxFit.cover,
            )
                : Icon(
              Icons.add_a_photo,
              size: 24,
              color: Colors.grey.shade600,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: image != null ? Colors.green : Colors.grey.shade500,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}