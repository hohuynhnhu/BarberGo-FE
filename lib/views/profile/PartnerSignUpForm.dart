// lib/screens/partner/partner_sign_up_screen.dart
import 'package:barbergofe/core/utils/auth_storage.dart';
import 'package:barbergofe/viewmodels/appointment/appointment_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';


class PartnerSignUpFormScreenV2 extends StatefulWidget {
  const PartnerSignUpFormScreenV2({super.key});

  @override
  State<PartnerSignUpFormScreenV2> createState() =>
      _PartnerSignUpFormScreenV2State();
}

class _PartnerSignUpFormScreenV2State extends State<PartnerSignUpFormScreenV2> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _shopNameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _openTimeController = TextEditingController();
  final TextEditingController _closeTimeController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _detailAddressController = TextEditingController();

  late AppointmentViewModel _appointmentVM;
  bool _isCheckingAppointment = false;
  bool _hasPendingAppointment = false;

  @override
  void initState() {
    super.initState();
    _openTimeController.text = '09:00';
    _closeTimeController.text = '21:00';
    _checkExistingAppointment();
    _prefillUserInfo();
  }

  // Prefill thông tin user nếu đã đăng nhập
  Future<void> _prefillUserInfo() async {
    // Lấy thông tin user từ AuthStorage
    final userId = await AuthStorage.getUserId();
    final email = await AuthStorage.getUserEmail();
    final phone = "0000000000000";

    setState(() {
      _emailController.text = email ?? '';
      _phoneController.text = phone ?? '';
    });
  }

  // Kiểm tra xem user đã có appointment đang chờ chưa
  Future<void> _checkExistingAppointment() async {
    setState(() {
      _isCheckingAppointment = true;
    });

    final appointmentVM = context.read<AppointmentViewModel>();
    final hasPending = await appointmentVM.hasPendingAppointment();

    setState(() {
      _hasPendingAppointment = hasPending;
      _isCheckingAppointment = false;
    });

    if (_hasPendingAppointment) {
      _showExistingAppointmentDialog();
    }
  }

  void _showExistingAppointmentDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Yêu cầu đang chờ xử lý'),
        content: const Text(
          'Bạn đã có một yêu cầu đăng ký đối tác đang chờ xử lý. '
              'Vui lòng đợi đội ngũ Barber GO liên hệ với bạn trước khi gửi yêu cầu mới.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.push('/appointments'); // Điều hướng đến màn hình xem appointments
            },
            child: const Text('Xem yêu cầu'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    _appointmentVM = context.watch<AppointmentViewModel>();

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 20,),
                Row(children:
                [
                  IconButton(
                    onPressed: () => context.pop(),
                    icon: const Icon(Icons.chevron_left),
                  ),
                  const Expanded(
                    child: Text(
                      'Thông tin cửa tiệm của bạn',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ]),
                const SizedBox(height: 40),

                // Hiển thị thông báo nếu đang kiểm tra
                if (_isCheckingAppointment)
                  const Padding(
                    padding: EdgeInsets.only(bottom: 16),
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                  ),

                // Hiển thị lỗi nếu có
                if (_appointmentVM.errorMessage != null)
                  Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.red),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.error, color: Colors.red),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _appointmentVM.errorMessage!,
                            style: const TextStyle(color: Colors.red),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, size: 16),
                          onPressed: () => _appointmentVM.clearError(),
                        ),
                      ],
                    ),
                  ),

                // Tên cửa tiệm
                _buildLabelAndField(
                  label: 'Tên cửa tiệm:',
                  controller: _shopNameController,
                  hint: 'Nhập tên cửa tiệm',
                  validator: (value) =>
                  value == null || value.isEmpty ? 'Vui lòng nhập tên tiệm' : null,
                ),
                const Divider(color: Colors.grey, height: 40),

                // Số điện thoại
                _buildLabelAndField(
                  label: 'Số điện thoại:',
                  controller: _phoneController,
                  hint: 'Nhập số điện thoại',
                  keyboardType: TextInputType.phone,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Vui lòng nhập số điện thoại';
                    }
                    if (!RegExp(r'^[0-9]{10,11}$').hasMatch(value)) {
                      return 'Số điện thoại không hợp lệ';
                    }
                    return null;
                  },
                ),
                const Divider(color: Colors.grey, height: 40),

                // Email
                _buildLabelAndField(
                  label: 'Email:',
                  controller: _emailController,
                  hint: 'Nhập email',
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Vui lòng nhập email';
                    }
                    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                        .hasMatch(value)) {
                      return 'Email không hợp lệ';
                    }
                    return null;
                  },
                ),
                const Divider(color: Colors.grey, height: 40),

                // Giờ mở cửa - đóng cửa
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 140,
                      child: Padding(
                        padding: const EdgeInsets.only(top: 14),
                        child: Text(
                          'Giờ mở cửa - đóng cửa:',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[800],
                            height: 1.4,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _openTimeController,
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.black,
                              ),
                              decoration: const InputDecoration(
                                isDense: true,
                                contentPadding: EdgeInsets.symmetric(vertical: 12),
                                border: InputBorder.none,
                              ),
                              onTap: () =>
                                  _selectTime(context, _openTimeController, true),
                            ),
                          ),
                          const SizedBox(width: 20),
                          Container(
                            width: 24,
                            height: 2,
                            color: Colors.grey,
                          ),
                          const SizedBox(width: 20),
                          Expanded(
                            child: TextFormField(
                              controller: _closeTimeController,
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.black,
                              ),
                              decoration: const InputDecoration(
                                isDense: true,
                                contentPadding: EdgeInsets.symmetric(vertical: 12),
                                border: InputBorder.none,
                              ),
                              onTap: () =>
                                  _selectTime(context, _closeTimeController, false),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const Divider(color: Colors.grey, height: 40),

                // Địa chỉ
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 140,
                      child: Padding(
                        padding: const EdgeInsets.only(top: 14),
                        child: Text(
                          'Địa chỉ:',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[800],
                            height: 1.4,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextFormField(
                        controller: _addressController,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.black,
                        ),
                        decoration: const InputDecoration(
                          isDense: true,
                          contentPadding: EdgeInsets.symmetric(vertical: 12),
                          border: InputBorder.none,
                          hintText: 'Phường Trung Mỹ Tây, Tp...',
                          hintStyle: TextStyle(
                            fontSize: 16,
                            color: Colors.grey,
                          ),
                        ),
                        maxLines: 1,
                        validator: (value) =>
                        value == null || value.isEmpty
                            ? 'Vui lòng nhập địa chỉ'
                            : null,
                      ),
                    ),
                  ],
                ),
                const Divider(color: Colors.grey, height: 40),

                // Địa chỉ cụ thể
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 140,
                      child: Padding(
                        padding: const EdgeInsets.only(top: 14),
                        child: Text(
                          'Địa chỉ cụ thể:',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[800],
                            height: 1.4,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Container(
                        height: 100,
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey[300]!),
                        ),
                        child: TextFormField(
                          controller: _detailAddressController,
                          maxLines: null,
                          expands: true,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.black,
                          ),
                          decoration: const InputDecoration(
                            contentPadding: EdgeInsets.all(12),
                            border: InputBorder.none,
                            hintText: 'Nhập địa chỉ cụ thể của tiệm...',
                            hintStyle: TextStyle(
                              fontSize: 16,
                              color: Colors.grey,
                            ),
                          ),
                          validator: (value) =>
                          value == null || value.isEmpty
                              ? 'Vui lòng nhập địa chỉ cụ thể'
                              : null,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 60),

                // Nộp hồ sơ button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _hasPendingAppointment || _appointmentVM.isLoading
                        ? null
                        : _submitForm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF5B4B8A),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _appointmentVM.isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                      'NỘP HỒ SƠ ĐĂNG KÝ',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLabelAndField({
    required String label,
    required TextEditingController controller,
    String? hint,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 140,
          child: Padding(
            padding: const EdgeInsets.only(top: 14),
            child: Text(
              label,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[800],
                height: 1.4,
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.black,
            ),
            decoration: InputDecoration(
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(vertical: 12),
              border: InputBorder.none,
              hintText: hint,
              hintStyle: const TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
            maxLines: 1,
            validator: validator,
          ),
        ),
      ],
    );
  }

  Future<void> _selectTime(
      BuildContext context, TextEditingController controller, bool isOpenTime) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) => Theme(
        data: ThemeData.light().copyWith(
          colorScheme: const ColorScheme.light(
            primary: Color(0xFF5B4B8A),
            onPrimary: Colors.white,
          ),
        ),
        child: child!,
      ),
    );

    if (picked != null) {
      setState(() {
        controller.text =
        '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
      });
    }
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      // Gửi yêu cầu appointment thay vì hiển thị dialog thành công
      _createAppointmentRequest();
    }
  }

  Future<void> _createAppointmentRequest() async {
    final success = await _appointmentVM.createAppointment(
      nameBarber: _shopNameController.text,
      phone: _phoneController.text,
      email: _emailController.text,
    );

    if (success != null) {
      _showSuccessDialog();
    } else {
      // Lỗi đã được hiển thị trong AppointmentViewModel
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.check_circle,
                color: Colors.green,
                size: 64,
              ),
              const SizedBox(height: 20),
              const Text(
                'Đã gửi yêu cầu thành công!',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Yêu cầu đăng ký đối tác của bạn đã được ghi nhận. '
                    'Đội ngũ Barber GO sẽ liên hệ tư vấn trong 24-48 giờ.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.grey,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        side: const BorderSide(color: Color(0xFF5B4B8A)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Xem yêu cầu',
                        style: TextStyle(
                          color: Color(0xFF5B4B8A),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF5B4B8A),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Hoàn tất',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}