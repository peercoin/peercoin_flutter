import 'package:flutter/material.dart';
import 'package:peercoin/tools/app_themes.dart';

class PeerButton extends StatelessWidget {
  final Function() action;
  final String text;
  final bool small;
  final bool active;
  PeerButton(
      {required this.text,
      required this.action,
      this.small = false,
      this.active = true});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        primary: Theme.of(context).primaryColor,
        onPrimary: Theme.of(context).accentColor,
        fixedSize:
            Size(MediaQuery.of(context).size.width / (small ? 2 : 1.5), 40),
        shape: RoundedRectangleBorder(
            //to set border radius to button
            borderRadius: BorderRadius.circular(30)),
        elevation: 0,
      ),
      onPressed: action,
      child: FittedBox(
        child: Text(
          text,
          style: TextStyle(
            letterSpacing: 1.4,
            fontSize: 16,
            color: active ? LightColors.white : LightColors.grey,
          ),
        ),
      ),
    );
  }
}

class PeerButtonBorder extends StatelessWidget {
  final Function() action;
  final String text;
  PeerButtonBorder({required this.text, required this.action});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        primary: Theme.of(context).backgroundColor,
        onPrimary: Theme.of(context).backgroundColor,
        fixedSize: Size(MediaQuery.of(context).size.width / 1.5, 40),
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
              color: Theme.of(context).primaryColor),
        ),
      ),
    );
  }
}
