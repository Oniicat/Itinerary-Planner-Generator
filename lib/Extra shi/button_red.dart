import 'package:flutter/material.dart';


class RedButton extends StatelessWidget {
  final void Function()? onTap;
  final String text;
  const RedButton({
    super.key, 
    required this.onTap,
    required this.text,
    });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.red.shade900,
          borderRadius: BorderRadius.circular(9)
        ),
        child: Center(
          child: Text(
          text, 
          style: const TextStyle(color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 16,
          ),),
        ),
      ),
    );
  }
}