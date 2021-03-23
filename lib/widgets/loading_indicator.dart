import "package:flutter/material.dart";

class LoadingIndicator extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return LinearProgressIndicator(
      backgroundColor: Theme.of(context).accentColor,
    );
  }
}
