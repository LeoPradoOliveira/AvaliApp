import 'package:flutter/material.dart';

class DimensionButton extends StatelessWidget {
  final void Function()? onTap;
  final String imagePath;
  const DimensionButton({super.key, required this.onTap, required this.imagePath});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
      ),
      child: Image.asset(imagePath,fit: BoxFit.contain,),
    )
    );
  }
}