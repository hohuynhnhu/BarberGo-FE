import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:barbergofe/views/intro/Screen_intro.dart';

void main() => runApp(const WidgetbookApp());

class WidgetbookApp extends StatelessWidget {
  const WidgetbookApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Widgetbook.material(
      directories: [
        WidgetbookFolder(
          name: 'Intro Screens',
          children: [
            WidgetbookComponent(
              name: 'Get Started Page',
              useCases: [
                WidgetbookUseCase(
                  name: 'Intro 1',
                  builder: (context) => IntroScreen(),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}
