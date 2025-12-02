import 'package:barbergofe/core/theme/text_styles.dart';
import 'package:barbergofe/views/home/widgets/Card_shop.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;

class Featuredbarberssection extends StatefulWidget {
  const Featuredbarberssection({super.key});

  @override
  State<Featuredbarberssection> createState() => _FeaturedbarberssectionState();
}

class _FeaturedbarberssectionState extends State<Featuredbarberssection> {
  List<dynamic> barbers=[];
  @override
  void initState() {
    super.initState();
    loadBarbers();
  }
  Future<void> loadBarbers() async {
    final String jsonString = await rootBundle.loadString('assets/data/barbers.json');
    final List<dynamic> jsonData = json.decode(jsonString);

    // chỉ lấy 3 barber nổi bật đầu tiên
    setState(() {
      barbers = jsonData.take(2).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text("Barber nổi bật", style: AppTextStyles.heading,),
        const SizedBox(height: 12,),
        barbers.isEmpty ? const Center(child: CircularProgressIndicator(),): Column(
          children: barbers.map((barber){
            return Column(
              children: [
                const SizedBox(height: 50,),
                CardShop(id: barber['id'],imagePath: barber['imagePath'], name: barber['name'], location: barber['location'], rank: barber['rank']),
              ],
            );
          }
          ).toList(),
        ),

      ],
    );
  }
}
