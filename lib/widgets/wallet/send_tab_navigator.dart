import 'package:flutter/material.dart';
import 'package:peercoin/tools/app_localizations.dart';

class SendTabNavigator extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        currentIndex - 1 > 0
            ? IconButton(
                onPressed: () => raiseNewindex(currentIndex - 1),
                icon: const Icon(Icons.arrow_left_rounded),
              )
            : const SizedBox(),
        Text(
          AppLocalizations.instance.translate('send_navigator', {
            "index": currentIndex.toString(),
            "maximum": numberOfRecipients.toString()
          }),
          style: TextStyle(
            fontSize: 12,
            color: Theme.of(context).colorScheme.secondary,
          ),
        ),
        currentIndex + 1 <= numberOfRecipients
            ? IconButton(
                onPressed: () => raiseNewindex(currentIndex + 1),
                icon: const Icon(Icons.arrow_right_rounded),
              )
            : const SizedBox(
                width: 48,
              )
      ],
      //TODO add jump to end and jump to front
    );
  }
}
