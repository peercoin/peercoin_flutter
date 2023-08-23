import 'package:flutter/material.dart';

class PeerServiceTitle extends StatelessWidget {
  final String title;
  const PeerServiceTitle({Key? key, required this.title}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 0, 8),
      child: Column(
        children: [
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.black,
                letterSpacing: 1.4,
              ),
            ),
          ),
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: SizedBox(
              width: MediaQuery.of(context).size.width / 10,
              child: Divider(
                color: Theme.of(context).primaryColor,
                thickness: 3,
              ),
            ),
          )
        ],
      ),
    );
  }
}

class PeerContainer extends StatelessWidget {
  final Widget child;
  final bool isTransparent;
  final bool noSpacers;

  const PeerContainer({
    Key? key,
    required this.child,
    this.isTransparent = false,
    this.noSpacers = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width > 1200
          ? MediaQuery.of(context).size.width / 2
          : MediaQuery.of(context).size.width,
      margin:
          noSpacers == true ? null : const EdgeInsets.fromLTRB(16, 0, 16, 16),
      padding: noSpacers == true ? null : const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isTransparent
            ? Colors.transparent
            : Theme.of(context).colorScheme.background,
        borderRadius: BorderRadius.circular(20),
      ),
      child: child,
    );
  }
}

class ModalBottomSheetContainer extends StatelessWidget {
  final Widget child;

  const ModalBottomSheetContainer({
    Key? key,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.background,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),
      padding: const EdgeInsets.all(20),
      child: child,
    );
  }
}

class GradientContainer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 30,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            BottomAppBarTheme.of(context).color!,
            Theme.of(context).primaryColor,
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
    );
  }
}
