import 'package:flutter/material.dart';
import 'package:peercoin/tools/app_localizations.dart';

class SendTabNavigator extends StatefulWidget {
  const SendTabNavigator({
    Key? key,
    required this.currentIndex,
    required this.numberOfRecipients,
    required this.raiseNewindex,
  }) : super(key: key);
  final int currentIndex;
  final int numberOfRecipients;
  final Function raiseNewindex;

  @override
  State<SendTabNavigator> createState() => _SendTabNavigatorState();
}

class _SendTabNavigatorState extends State<SendTabNavigator> {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        widget.currentIndex - 1 > 0
            ? IconButton(
                onPressed: () => widget.raiseNewindex(widget.currentIndex - 1),
                icon: const Icon(Icons.arrow_left_rounded),
              )
            : const SizedBox(),
        Text(
          AppLocalizations.instance.translate('send_navigator', {
            "index": widget.currentIndex.toString(),
            "maximum": widget.numberOfRecipients.toString()
          }),
          style: TextStyle(
            fontSize: 12,
            color: Theme.of(context).colorScheme.secondary,
          ),
        ),
        widget.currentIndex + 1 <= widget.numberOfRecipients
            ? IconButton(
                onPressed: () => widget.raiseNewindex(widget.currentIndex + 1),
                icon: const Icon(Icons.arrow_right_rounded),
              )
            : const SizedBox(
                width: 48,
              )
      ],
    );
  }
}
