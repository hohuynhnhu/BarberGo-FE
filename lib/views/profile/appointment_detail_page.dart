// lib/screens/appointment/appointment_detail_screen.dart
import 'package:barbergofe/core/constants/color.dart';
import 'package:barbergofe/models/profile/appointment_model.dart';
import 'package:barbergofe/viewmodels/appointment/appointment_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class AppointmentDetailScreen extends StatefulWidget {
  const AppointmentDetailScreen({super.key});

  @override
  State<AppointmentDetailScreen> createState() => _AppointmentDetailScreenState();
}

class _AppointmentDetailScreenState extends State<AppointmentDetailScreen> {
  late AppointmentViewModel _appointmentVM;

  @override
  void initState() {
    super.initState();
    _appointmentVM = context.read<AppointmentViewModel>();
    _loadAppointment();
  }

  Future<void> _loadAppointment() async {
    await _appointmentVM.loadAppointments();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => context.pop(),
        ),
        backgroundColor: Colors.white,
        elevation: 1,
        title: const Text(
          'Trạng thái hồ sơ',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Consumer<AppointmentViewModel>(
        builder: (context, appointmentVM, child) {
          return _buildBody(appointmentVM);
        },
      ),
    );
  }

  Widget _buildBody(AppointmentViewModel appointmentVM) {
    if (appointmentVM.isLoading && appointmentVM.appointments.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (appointmentVM.errorMessage != null && appointmentVM.appointments.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                appointmentVM.errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.red),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadAppointment,
              child: const Text('Thử lại'),
            ),
          ],
        ),
      );
    }

    if (appointmentVM.appointments.isEmpty) {
      return _buildEmptyState();
    }

    // Lấy appointment đầu tiên của user
    final appointment = appointmentVM.appointments.first;
    return _buildAppointmentDetail(appointment);
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.folder_open, size: 80, color: Colors.grey),
          const SizedBox(height: 20),
          const Text(
            'Chưa có yêu cầu đăng ký',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 12),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              'Bạn chưa gửi yêu cầu đăng ký đối tác nào. Hãy tạo yêu cầu để bắt đầu hợp tác với Barber GO.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              context.push('/PartnerSignUpForm');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF5B4B8A),
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
            ),
            child: const Text(
              'ĐĂNG KÝ NGAY',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppointmentDetail(AppointmentModel appointment) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status Card
            _buildStatusCard(appointment),
            const SizedBox(height: 24),

            // Thông tin yêu cầu
            _buildSectionTitle('Thông tin yêu cầu'),
            const SizedBox(height: 16),
            _buildInfoCard(appointment),
            const SizedBox(height: 24),

            // Thông tin liên hệ
            _buildSectionTitle('Thông tin liên hệ'),
            const SizedBox(height: 16),
            _buildContactCard(appointment),
            const SizedBox(height: 24),

            // Timeline
            _buildSectionTitle('Lịch sử trạng thái'),
            const SizedBox(height: 16),
            _buildTimeline(appointment),
            const SizedBox(height: 32),

            // Action Buttons (nếu là pending)
            if (appointment.status == 'pending')
              _buildActionButtons(appointment),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusCard(AppointmentModel appointment) {
    final status = appointment.status;
    final Map<String, Map<String, dynamic>> statusConfig = {
      'pending': {
        'color': Colors.orange,
        'icon': Icons.access_time,
        'title': 'Đang chờ xử lý',
        'subtitle': 'Yêu cầu của bạn đang chờ đội ngũ Barber GO xem xét',
      },
      'confirmed': {
        'color': Colors.green,
        'icon': Icons.check_circle,
        'title': 'Đã xác nhận',
        'subtitle': 'Yêu cầu đã được xác nhận, chúng tôi sẽ liên hệ với bạn',
      },
      'completed': {
        'color': Colors.blue,
        'icon': Icons.done_all,
        'title': 'Đã hoàn thành',
        'subtitle': 'Yêu cầu đã được xử lý thành công',
      },
      'cancelled': {
        'color': Colors.red,
        'icon': Icons.cancel,
        'title': 'Đã hủy',
        'subtitle': 'Yêu cầu đã bị hủy',
      },
    };

    final config = statusConfig[status] ?? statusConfig['pending']!;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: config['color'].withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: config['color'].withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: config['color'],
              shape: BoxShape.circle,
            ),
            child: Icon(config['icon'], color: Colors.white, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  config['title'],
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: config['color'],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  config['subtitle'],
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[700],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Colors.black87,
      ),
    );
  }

  Widget _buildInfoCard(AppointmentModel appointment) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoRow(
            icon: Icons.store,
            label: 'Tên tiệm',
            value: appointment.nameBarber,
          ),
          const Divider(height: 20),
          _buildInfoRow(
            icon: Icons.calendar_today,
            label: 'Ngày gửi',
            value: _formatDateTime(appointment.createdAt),
          ),
          const Divider(height: 20),
          _buildInfoRow(
            icon: Icons.update,
            label: 'Cập nhật lần cuối',
            value: _formatDateTime(appointment.updatedAt),
          ),
        ],
      ),
    );
  }

  Widget _buildContactCard(AppointmentModel appointment) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildContactRow(
            icon: Icons.phone,
            label: 'Số điện thoại',
            value: appointment.phone,
            canCopy: true,
          ),
          const Divider(height: 20),
          _buildContactRow(
            icon: Icons.email,
            label: 'Email',
            value: appointment.email,
            canCopy: true,
          ),
        ],
      ),
    );
  }

  Widget _buildTimeline(AppointmentModel appointment) {
    final statuses = [
      {'status': 'pending', 'label': 'Đã gửi yêu cầu', 'time': appointment.createdAt},
      {'status': 'confirmed', 'label': 'Đã xác nhận', 'time': appointment.updatedAt},
      {'status': 'completed', 'label': 'Đã hoàn thành', 'time': appointment.updatedAt},
      {'status': 'cancelled', 'label': 'Đã hủy', 'time': appointment.updatedAt},
    ];

    final currentStatusIndex = statuses.indexWhere((item) => item['status'] == appointment.status);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          for (int i = 0; i < statuses.length; i++)
            Column(
              children: [
                _buildTimelineItem(
                  isActive: i <= currentStatusIndex,
                  isLast: i == statuses.length - 1,
                  label: statuses[i]['label'] as String,
                  time: appointment.status == statuses[i]['status']
                      ? _formatDateTime(statuses[i]['time'] as DateTime)
                      : null,
                ),
                if (i < statuses.length - 1) const SizedBox(height: 8),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildTimelineItem({
    required bool isActive,
    required bool isLast,
    required String label,
    String? time,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isActive ? AppColors.primary : Colors.grey.shade300,
                border: Border.all(
                  color: isActive ? AppColors.primary : Colors.grey.shade300,
                  width: 2,
                ),
              ),
              child: isActive
                  ? const Icon(Icons.check, size: 12, color: Colors.white)
                  : null,
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 40,
                color: isActive ? AppColors.primary : Colors.grey.shade300,
              ),
          ],
        ),
        const SizedBox(width: 16),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                  color: isActive ? Colors.black87 : Colors.grey.shade600,
                ),
              ),
              if (time != null) ...[
                const SizedBox(height: 4),
                Text(
                  time,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade500,
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(AppointmentModel appointment) {
    return Column(
      children: [

      ],
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: Colors.grey.shade600),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildContactRow({
    required IconData icon,
    required String label,
    required String value,
    bool canCopy = false,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: Colors.grey.shade600),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      value,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  if (canCopy)
                    IconButton(
                      icon: const Icon(Icons.copy, size: 18),
                      onPressed: () {
                        _copyToClipboard(label, value);
                      },
                    ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return DateFormat('HH:mm dd/MM/yyyy').format(dateTime);
  }

  Future<void> _cancelAppointment(AppointmentModel appointment) async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận hủy'),
        content: const Text(
          'Bạn có chắc chắn muốn hủy yêu cầu này không? '
              'Sau khi hủy, bạn sẽ không thể khôi phục lại.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Không'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('Có, hủy yêu cầu'),
          ),
        ],
      ),
    );


  }

  void _contactSupport() {
    // Mở email client
    final email = 'support@barbergo.com';
    final subject = 'Hỗ trợ yêu cầu đăng ký đối tác';
    final body = 'Xin chào Barber GO,\n\nTôi cần hỗ trợ về yêu cầu đăng ký đối tác của mình.\n\n';

    final uri = Uri(
      scheme: 'mailto',
      path: email,
      queryParameters: {
        'subject': subject,
        'body': body,
      },
    ).toString();

    // Hiển thị thông báo tạm thời
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Tính năng liên hệ hỗ trợ đang phát triển'),
      ),
    );
  }

  void _copyToClipboard(String label, String value) {
    // Copy to clipboard

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Đã sao chép $label')),
    );
  }
}