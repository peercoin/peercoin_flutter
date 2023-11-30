import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../tools/app_localizations.dart';

class DoubleTabToClipboard extends StatelessWidget {
  final Widget child;
  final String clipBoardData;

  const DoubleTabToClipboard({
    super.key,
    required this.clipBoardData,
    required this.child,
  });

  static void tapEvent(BuildContext context, String clipBoardData) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          AppLocalizations.instance.translate('snack_copied'),
          textAlign: TextAlign.center,
        ),
        duration: const Duration(seconds: 1),
      ),
    );
    Clipboard.setData(
      ClipboardData(text: clipBoardData),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onDoubleTap: () => tapEvent(context, clipBoardData),
      child: child,
    );
  }
}
