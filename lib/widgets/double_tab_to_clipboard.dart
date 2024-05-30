import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../tools/app_localizations.dart';

class DoubleTabToClipboard extends StatelessWidget {
  final Widget child;
  final String clipBoardData;
  final bool withHintText;

  const DoubleTabToClipboard({
    super.key,
    required this.clipBoardData,
    required this.child,
    required this.withHintText,
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
    return Column(
      children: [
        GestureDetector(
          onDoubleTap: () => tapEvent(context, clipBoardData),
          child: child,
        ),
        if (withHintText)
          const SizedBox(
            height: 5,
          ),
        if (withHintText)
          Text(
            AppLocalizations.instance.translate('double_tap_to_copy'),
            style: TextStyle(
              fontSize: 12,
              color: Theme.of(context).colorScheme.secondary,
            ),
          )
      ],
    );
  }
}
