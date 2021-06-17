import 'package:flutter/material.dart';

class LoadingIndicator extends StatelessWidget {
  final Color backgroundColor;
  final Color color;

  LoadingIndicator(
      {this.color = const Color(0xff3cb054),
      this.backgroundColor = const Color(0xFFFFFFFC)});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: LinearProgressIndicator(
        backgroundColor: backgroundColor,
        color: color,
        //valueColor: AlwaysStoppedAnimation<Color>(color),
      ),
    );
  }
}
