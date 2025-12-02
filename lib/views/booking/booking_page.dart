import 'package:barbergofe/views/booking/widgets/step1_booking.dart';
import 'package:barbergofe/views/detail_shop/widgets/next_button.dart';
import 'package:flutter/material.dart';

class BookingPage extends StatelessWidget {
  const BookingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:Column(
        children: [
          const SizedBox(height: 50,),
          Step1Booking(nameStep: '1. Chọn tiệm tóc',hint: 'xem tất cả cửa tiệm', content: null,),
          const SizedBox(height: 50,),
          Step1Booking(nameStep: '2. Chọn dịch vụ', hint: 'Xem tát cả các dịch vụ hấp dẫn', content: null,),
          const SizedBox(height: 50,),
          Step1Booking(nameStep: '3. Chọn thời gian', hint: 'Hôm nay,....',content: null),
        ],
      ) ,
    );
  }
}
