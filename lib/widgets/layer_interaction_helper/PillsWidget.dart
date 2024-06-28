import 'package:flutter/material.dart';

class Pill extends StatelessWidget {
  const Pill({
    super.key,
    required this.width,
    required this.height,
    this.onPanStart,
    this.onPanUpdate,
    this.onPanEnd,
  });
  final double width;
  final double height;
  final Function(DragStartDetails)? onPanStart;
  final Function(DragUpdateDetails)? onPanUpdate;
  final Function(DragEndDetails)? onPanEnd;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanEnd: onPanEnd,
      onPanStart: onPanStart,
      onPanUpdate: onPanUpdate,
      child: Center(
        child: Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            boxShadow: const [
              BoxShadow(blurRadius: 5, color: Colors.black26),
            ],
          ),
        ),
      ),
    );
  }
}