import 'package:flutter/material.dart';

class IntroIndicator extends StatelessWidget {
  final int itemCount;
  final int currentIndex;
  const IntroIndicator({super.key, required this.itemCount, required this.currentIndex});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(itemCount, (index)=>
      AnimatedContainer(duration: const Duration(milliseconds: 300),
        margin:const EdgeInsets.symmetric(horizontal: 4),
          height: 10,
          width: currentIndex==index?20:10,
          decoration: BoxDecoration(
            color: currentIndex==index?Colors.black:Colors.grey,
            borderRadius: BorderRadius.circular(5)
          ),
          )
      ),
    );
  }
}
