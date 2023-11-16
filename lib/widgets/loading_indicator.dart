import 'package:flutter/material.dart';

class LoadingIndicator extends StatelessWidget {
  const LoadingIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return LinearProgressIndicator(
      color: Theme.of(context).primaryColor,
      backgroundColor: Theme.of(context).colorScheme.background,
    );
  }
//TODO try to move heavy computation away from Main thread so this animation actually continues
}
