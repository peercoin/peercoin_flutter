import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:peercoin/tools/app_localizations.dart';

class ChangeLogScreen extends StatelessWidget {
  const ChangeLogScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight
    ]); //TODO remove when setup layout issue is fixed
    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppLocalizations.instance.translate('changelog_appbar'),
        ),
      ),
      body: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 30),
        child: FutureBuilder(
          future: DefaultAssetBundle.of(context).loadString('CHANGELOG.md'),
          builder: (context, snapshot) {
            var _changeLogData =
                snapshot.hasData ? snapshot.data.toString() : '';

            return SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 10),
                      child: Text(
                        AppLocalizations.instance
                            .translate('changelog_headline'),
                        style: Theme.of(context).textTheme.headline6,
                      ),
                    ),
                    Divider(),
                    MarkdownBody(
                      data: _changeLogData,
                      styleSheet:
                          MarkdownStyleSheet.fromTheme(Theme.of(context))
                              .copyWith(
                        textScaleFactor: 1.1,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
