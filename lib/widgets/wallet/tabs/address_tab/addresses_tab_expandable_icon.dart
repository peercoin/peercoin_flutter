import 'package:flutter/material.dart';

class AddressesTabExpandableIcon extends StatelessWidget {
  final Function action;
  final Icon icon;
  final String caption;
  const AddressesTabExpandableIcon({
    super.key,
    required this.action,
    required this.icon,
    required this.caption,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        IconButton(
          onPressed: () => action(),
          icon: icon,
        ),
        Text(
          caption,
          style: TextStyle(
            color: Theme.of(context).colorScheme.secondary,
          ),
        ),
      ],
    );
  }
}
