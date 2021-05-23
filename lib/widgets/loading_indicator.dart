import 'package:flutter/material.dart';

class LoadingIndicator extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return LinearProgressIndicator(
      color: Theme.of(context).accentColor,
      backgroundColor: Theme.of(context).primaryColor,
    );
  }
}
