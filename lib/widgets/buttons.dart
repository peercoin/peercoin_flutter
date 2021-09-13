import 'package:flutter/cupertino.dart';
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
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

class PeerButtonSetup extends StatelessWidget {
  final Function() action;
  final String text;
  final bool small;

  PeerButtonSetup(
      {required this.text, required this.action, this.small = false});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        primary: Theme.of(context).backgroundColor,
        onPrimary: Theme.of(context).primaryColor,
        fixedSize: Size(MediaQuery.of(context).size.width / (small ? 1.8 : 1.5), 40),
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
              color: Color(0xFF2A7A3A)),
        ),
      ),
    );
  }
}

class PeerButtonSetupLoading extends StatelessWidget {
  final Function() action;
  final String text;
  final bool loading;
  final bool small;

  PeerButtonSetupLoading(
      {required this.text, required this.action, this.loading = false, this.small = false});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        primary: Theme.of(context).backgroundColor,
        onPrimary: Theme.of(context).primaryColor,
        fixedSize: Size(MediaQuery.of(context).size.width / (small ? 1.8 : 1.5), 40),
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
                  strokeWidth: 3,
                ),
              )
            : Text(
                text,
                style: TextStyle(
                    letterSpacing: 1.2,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Color(0xFF2A7A3A)),
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
  const PeerButtonSetupBack({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ClipOval(
      child: Material(
        color: Colors.white,
        child: InkWell(
          splashColor: Theme.of(context).primaryColor,
          onTap: () {
            Navigator.pop(context);
          },
          child: SizedBox(
              width: 40,
              height: 40,
              child: Center(
                child: Icon(
                  CupertinoIcons.back,
                  color: Color(0xFF2A7A3A),
                  size: 26,
                ),
              )),
        ),
      ),
    );
  }
}

