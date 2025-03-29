import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';

import '../tools/app_themes.dart';

class PeerButton extends StatelessWidget {
  final Function() action;
  final String text;
  final bool small;
  final bool active;
  final bool disabled;
  const PeerButton({
    super.key,
    required this.text,
    required this.action,
    this.small = false,
    this.active = true,
    this.disabled = false,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        foregroundColor: Theme.of(context).colorScheme.secondary,
        backgroundColor: Theme.of(context).primaryColor,
        fixedSize: Size(
          MediaQuery.of(context).size.width > 768
              ? MediaQuery.of(context).size.width / 4
              : MediaQuery.of(context).size.width / 1.5,
          40,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        elevation: 0,
      ),
      onPressed: disabled ? null : action,
      child: AutoSizeText(
        text,
        minFontSize: 10,
        maxFontSize: 16,
        textAlign: TextAlign.center,
        style: TextStyle(
          letterSpacing: 1.4,
          color: active ? LightColors.white : LightColors.grey,
        ),
      ),
    );
  }
}

class PeerButtonBorder extends StatelessWidget {
  final Function() action;
  final String text;
  const PeerButtonBorder({super.key, required this.text, required this.action});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        foregroundColor: Theme.of(context).colorScheme.surface,
        backgroundColor: Theme.of(context).colorScheme.surface,
        fixedSize: Size(
          MediaQuery.of(context).size.width > 768
              ? MediaQuery.of(context).size.width / 4
              : MediaQuery.of(context).size.width / 1.5,
          40,
        ),
        shape: RoundedRectangleBorder(
          //to set border radius to button
          borderRadius: BorderRadius.circular(30),
          side: BorderSide(width: 2, color: Theme.of(context).primaryColor),
        ),
        elevation: 0,
      ),
      onPressed: action,
      child: FittedBox(
        child: Text(
          text,
          style: TextStyle(
            letterSpacing: 1.4,
            fontSize: 16,
            color: Theme.of(context).primaryColor,
          ),
        ),
      ),
    );
  }
}

class PeerButtonSetup extends StatelessWidget {
  final Function() action;
  final String text;
  final bool active;

  const PeerButtonSetup({
    super.key,
    required this.text,
    required this.action,
    this.active = true,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        foregroundColor: Theme.of(context).primaryColor,
        backgroundColor:
            active ? Theme.of(context).colorScheme.surface : Colors.grey,
        fixedSize: Size(
          MediaQuery.of(context).size.width > 768
              ? MediaQuery.of(context).size.width / 4
              : MediaQuery.of(context).size.width / 1.5,
          40,
        ),
        shape: RoundedRectangleBorder(
          //to set border radius to button
          borderRadius: BorderRadius.circular(30),
        ),
      ),
      onPressed: action,
      child: FittedBox(
        child: Text(
          text,
          style: TextStyle(
            letterSpacing: 1.2,
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: Theme.of(context).colorScheme.primaryContainer,
          ),
        ),
      ),
    );
  }
}

class PeerButtonSetupLoading extends StatelessWidget {
  final Function() action;
  final String text;
  final bool loading;

  const PeerButtonSetupLoading({
    super.key,
    required this.text,
    required this.action,
    this.loading = false,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        foregroundColor: Theme.of(context).primaryColor,
        backgroundColor: Theme.of(context).colorScheme.surface,
        fixedSize: Size(
          MediaQuery.of(context).size.width > 768
              ? MediaQuery.of(context).size.width / 4
              : MediaQuery.of(context).size.width / 1.5,
          40,
        ),
        shape: RoundedRectangleBorder(
          //to set border radius to button
          borderRadius: BorderRadius.circular(30),
        ),
      ),
      onPressed: onPressed,
      child: FittedBox(
        child: loading
            ? SizedBox(
                height: 18,
                width: 18,
                child: CircularProgressIndicator(
                  color: Theme.of(context).colorScheme.secondary,
                  strokeWidth: 3,
                ),
              )
            : Text(
                text,
                style: TextStyle(
                  letterSpacing: 1.2,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: Theme.of(context).colorScheme.primaryContainer,
                ),
              ),
      ),
    );
  }

  void onPressed() {
    Future.delayed(const Duration(milliseconds: 300), () {
      action();
    });
  }
}

class PeerButtonSetupBack extends StatelessWidget {
  const PeerButtonSetupBack({super.key});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () {
        Navigator.pop(context);
      },
      icon: const Icon(
        Icons.arrow_back_ios,
        color: Colors.white,
      ),
    );
  }
}
