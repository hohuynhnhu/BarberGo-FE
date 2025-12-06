import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'widgets/profile_avatar.dart';
import '../../core/utils/image_picker_helper.dart';
import '../../viewmodels/profile/profile_viewmodel.dart';

class PersonalInfoPage extends StatelessWidget {
  const PersonalInfoPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Sử dụng Consumer để wrap toàn bộ page
    return Consumer<ProfileViewModel>(
      builder: (context, profileVM, child) {
        // Load profile khi build lần đầu
        // Load profile nếu chưa có data
        if (profileVM.currentUser == null && !profileVM.isLoading) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            profileVM.loadProfile();
          });
        }

        return Scaffold(
          backgroundColor: const Color(0xFFF5F5F5),
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.black),
              onPressed: () => context.pop(),
            ),
            title: const Text(
              'Thông tin cá nhân',
              style: TextStyle(
                color: Colors.black,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          body: _buildBody(context, profileVM),
        );
      },
    );
  }

  Widget _buildBody(BuildContext context, ProfileViewModel profileVM) {
    // Show loading indicator
    if (profileVM.isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    // Show error if any
    if (profileVM.errorMessage != null && profileVM.currentUser == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                profileVM.errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.red),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => profileVM.loadProfile(),
              child: const Text('Thử lại'),
            ),
          ],
        ),
      );
    }

    final user = profileVM.currentUser;

    return Stack(
      children: [
        SingleChildScrollView(
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // ==================== AVATAR SECTION ====================
                    _buildSection(
                      context,
                      title: 'Ảnh đại diện',
                      trailing: TextButton(
                        onPressed: profileVM.isUpdating
                            ? null
                            : () => _showEditAvatarDialog(context),
                        child: const Text(
                          'Chỉnh sửa',
                          style: TextStyle(
                            color: Color(0xFF5B4B8A),
                            fontSize: 14,
                          ),
                        ),
                      ),
                      child: Center(
                        child: ProfileAvatar(
                          avatarUrl: user?.avatarUrl,
                          size: 100,
                        ),
                      ),
                    ),

                    const Divider(height: 32),

                    // ==================== NAME SECTION ====================
                    _buildSection(
                      context,
                      title: 'Tên tài khoản',
                      trailing: TextButton(
                        onPressed: profileVM.isUpdating
                            ? null
                            : () {
                          _showEditDialog(
                            context,
                            title: 'Chỉnh sửa tên',
                            currentValue: user?.fullName ?? '',
                            onSave: (newValue) async {
                              final success = await profileVM.updateName(newValue);
                              if (context.mounted) {
                                if (success) {
                                  _showSuccessSnackBar(context, 'Cập nhật tên thành công');
                                } else {
                                  _showErrorSnackBar(
                                    context,
                                    profileVM.errorMessage ?? 'Cập nhật thất bại',
                                  );
                                }
                              }
                            },
                          );
                        },
                        child: const Text(
                          'Chỉnh sửa',
                          style: TextStyle(
                            color: Color(0xFF5B4B8A),
                            fontSize: 14,
                          ),
                        ),
                      ),
                      child: Text(
                        user?.fullName ?? 'Chưa cập nhật',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.black87,
                        ),
                      ),
                    ),

                    const Divider(height: 32),

                    // ==================== PHONE SECTION ====================
                    _buildSection(
                      context,
                      title: 'Số điện thoại',
                      trailing: TextButton(
                        onPressed: profileVM.isUpdating
                            ? null
                            : () {
                          _showEditDialog(
                            context,
                            title: 'Chỉnh sửa số điện thoại',
                            currentValue: user?.phone ?? '',
                            keyboardType: TextInputType.phone,
                            onSave: (newValue) async {
                              final success = await profileVM.updatePhone(newValue);
                              if (context.mounted) {
                                if (success) {
                                  _showSuccessSnackBar(
                                    context,
                                    'Cập nhật số điện thoại thành công',
                                  );
                                } else {
                                  _showErrorSnackBar(
                                    context,
                                    profileVM.errorMessage ?? 'Cập nhật thất bại',
                                  );
                                }
                              }
                            },
                          );
                        },
                        child: const Text(
                          'Chỉnh sửa',
                          style: TextStyle(
                            color: Color(0xFF5B4B8A),
                            fontSize: 14,
                          ),
                        ),
                      ),
                      child: Text(
                        user?.phone ?? 'Chưa cập nhật',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.black87,
                        ),
                      ),
                    ),

                    const Divider(height: 32),

                    // ==================== EMAIL SECTION ====================
                    _buildSection(
                      context,
                      title: 'Email',
                      child: Text(
                        user?.email ?? 'Chưa cập nhật',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),

        // ==================== LOADING OVERLAY ====================
        if (profileVM.isUpdating)
          Container(
            color: Colors.black.withOpacity(0.3),
            child: const Center(
              child: Card(
                child: Padding(
                  padding: EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 16),
                      Text('Đang cập nhật...'),
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  // ==================== BUILD SECTION ====================
  Widget _buildSection(
      BuildContext context, {
        required String title,
        required Widget child,
        Widget? trailing,
      }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black54,
                fontWeight: FontWeight.w400,
              ),
            ),
            if (trailing != null) trailing,
          ],
        ),
        const SizedBox(height: 12),
        child,
      ],
    );
  }

  // ==================== EDIT DIALOG ====================
  void _showEditDialog(
      BuildContext context, {
        required String title,
        required String currentValue,
        required Future<void> Function(String) onSave,
        TextInputType? keyboardType,
      }) {
    final controller = TextEditingController(text: currentValue);

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(title, style: const TextStyle(fontSize: 18)),
        content: TextField(
          controller: controller,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: 'Nhập $title',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Hủy', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () async {
              final newValue = controller.text.trim();
              if (newValue.isNotEmpty) {
                Navigator.pop(dialogContext);
                await onSave(newValue);
              }
            },
            child: const Text(
              'Lưu',
              style: TextStyle(
                color: Color(0xFF5B4B8A),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==================== EDIT AVATAR DIALOG ====================
  void _showEditAvatarDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Chọn ảnh đại diện',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF5B4B8A).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.photo_library,
                  color: Color(0xFF5B4B8A),
                ),
              ),
              title: const Text('Chọn từ thư viện'),
              onTap: () {
                Navigator.pop(sheetContext);
                _handlePickImage(context);
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  // ==================== HANDLE PICK IMAGE ====================
  Future<void> _handlePickImage(BuildContext context) async {
    print('🔵 [PERSONAL INFO] Pick image requested');

    try {
      final File? imageFile = await ImagePickerHelper.pickFromGallery(context);

      if (imageFile == null) {
        print('ℹ️ [PERSONAL INFO] No image selected');
        return;
      }

      print('✅ [PERSONAL INFO] Image selected: ${imageFile.path}');

      if (!context.mounted) return;

      // Upload avatar using ProfileViewModel - sử dụng Consumer để lấy viewmodel
      final profileVM = context.read<ProfileViewModel>();
      final success = await profileVM.updateAvatar(imageFile);

      if (!context.mounted) return;

      if (success) {
        _showSuccessSnackBar(context, 'Cập nhật ảnh đại diện thành công');
      } else {
        _showErrorSnackBar(
          context,
          profileVM.errorMessage ?? 'Cập nhật ảnh đại diện thất bại',
        );
      }
    } catch (e) {
      print('❌ [PERSONAL INFO] Error: $e');

      if (context.mounted) {
        _showErrorSnackBar(context, 'Lỗi: ${e.toString()}');
      }
    }
  }

  // ==================== SHOW SUCCESS SNACKBAR ====================
  void _showSuccessSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // ==================== SHOW ERROR SNACKBAR ====================
  void _showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}