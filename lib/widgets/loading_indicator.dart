import 'package:flutter/material.dart';

class LoadingIndicator extends StatelessWidget {
  final Color background;
  final Color color;

  LoadingIndicator(
      {this.color = const Color(0xFF2C4251),
      this.background = const Color(0xff3cb054)});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: LinearProgressIndicator(
        color: color,
        backgroundColor: background,
      ),
    );
  }
}
