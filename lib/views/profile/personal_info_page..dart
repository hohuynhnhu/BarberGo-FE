import 'dart:io';
import 'package:barbergofe/viewmodels/auth/auth_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'widgets/profile_avatar.dart';
import '../../core/utils/image_picker_helper.dart';

class PersonalInfoPage extends StatelessWidget {
  const PersonalInfoPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
      body: Consumer<AuthViewModel>(
        builder: (context, authVM, child) {
          final user = authVM.currentUser;

          return SingleChildScrollView(
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
                          onPressed: () {
                            _showEditAvatarDialog(context);
                          },
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
                          onPressed: () {
                            _showEditDialog(
                              context,
                              title: 'Chỉnh sửa tên',
                              currentValue: user?.fullName ?? '',
                              onSave: (newValue) {
                                print('New name: $newValue');
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
                          onPressed: () {
                            _showEditDialog(
                              context,
                              title: 'Chỉnh sửa số điện thoại',
                              currentValue: user?.phone ?? '',
                              keyboardType: TextInputType.phone,
                              onSave: (newValue) {
                                print('New phone: $newValue');
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
                        trailing: TextButton(
                          onPressed: () {
                            _showEditDialog(
                              context,
                              title: 'Chỉnh sửa email',
                              currentValue: user?.email ?? '',
                              keyboardType: TextInputType.emailAddress,
                              onSave: (newValue) {
                                print('New email: $newValue');
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
          );
        },
      ),
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
        required Function(String) onSave,
        TextInputType? keyboardType,
      }) {
    final controller = TextEditingController(text: currentValue);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
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
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () {
              final newValue = controller.text.trim();
              if (newValue.isNotEmpty) {
                onSave(newValue);
                Navigator.pop(context);

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Cập nhật thành công'),
                    backgroundColor: Colors.green,
                  ),
                );
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
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            const SizedBox(height: 24),

            // Title
            const Text(
              'Chọn ảnh đại diện',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 24),

            // Gallery option
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
                Navigator.pop(context);
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

    // Show loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    try {
      // Pick image from gallery
      final File? imageFile = await ImagePickerHelper.pickFromGallery(context);

      // Close loading
      Navigator.pop(context);

      if (imageFile == null) {
        print('ℹ️ [PERSONAL INFO] No image selected');
        return;
      }

      print('✅ [PERSONAL INFO] Image selected: ${imageFile.path}');

      // TODO: Upload to server
      // await uploadAvatar(imageFile);

      // Show success
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Đã chọn ảnh thành công'),
          backgroundColor: Colors.green,
        ),
      );

    } catch (e) {
      print('❌ [PERSONAL INFO] Error: $e');

      // Close loading if still open
      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lỗi: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}