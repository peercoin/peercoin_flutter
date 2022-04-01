import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../tools/app_localizations.dart';

class DoubleTabToClipboard extends StatelessWidget {
  final Widget child;
  final String clipBoardData;
  DoubleTabToClipboard({
    required this.clipBoardData,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onDoubleTap: () {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
            AppLocalizations.instance.translate('snack_copied'),
            textAlign: TextAlign.center,
          ),
          duration: Duration(seconds: 1),
        ));
        Clipboard.setData(
          ClipboardData(text: clipBoardData),
        );
      },
      child: child,
    );
  }
}
