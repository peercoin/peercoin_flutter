import 'package:flutter/material.dart';

import '../../../tools/app_localizations.dart';

class SendTabAddressManagement extends StatelessWidget {
  const SendTabAddressManagement({
    super.key,
    required this.onAdd,
    required this.onDelete,
    required this.numberOfRecipients,
  });
  final Function onAdd;
  final Function onDelete;
  final int numberOfRecipients;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        numberOfRecipients - 1 >= 1
            ? IconButton(
                onPressed: () => onDelete(),
                icon: Icon(
                  Icons.delete,
                  color: Theme.of(context).colorScheme.error,
                ),
              )
            : const SizedBox(
                width: 10,
              ),
        TextButton.icon(
          onPressed: () => onAdd(),
          label: Text(
            AppLocalizations.instance.translate('send_add_address'),
          ),
          icon: const Icon(Icons.add),
        ),
      ],
    );
  }
}
