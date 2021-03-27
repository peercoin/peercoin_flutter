import "package:flutter/material.dart";
import 'package:flutter/services.dart';
import 'package:peercoin/tools/app_localizations.dart';
import 'package:peercoin/models/availablecoins.dart';
import 'package:peercoin/models/coin.dart';
import 'package:peercoin/models/coinwallet.dart';
import 'package:qr_flutter/qr_flutter.dart';

class ReceiveTab extends StatefulWidget {
  final _unusedAddress;
  ReceiveTab(this._unusedAddress);

  @override
  _ReceiveTabState createState() => _ReceiveTabState();
}

class _ReceiveTabState extends State<ReceiveTab> {
  bool _initial = true;
  final amountController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final _amountKey = GlobalKey<FormFieldState>();
  CoinWallet _wallet;
  Coin _availableCoin;
  String _qrString;

  @override
  void didChangeDependencies() {
    if (_initial == true) {
      _wallet = ModalRoute.of(context).settings.arguments as CoinWallet;
      _availableCoin = AvailableCoins().getSpecificCoin(_wallet.name);
      setState(() {
        _initial = false;
      });
    }
    super.didChangeDependencies();
  }

  void stringBuilder(double amount) {
    setState(() {
      _qrString = amount == 0
          ? widget._unusedAddress
          : "${_availableCoin.uriCode}:${widget._unusedAddress}?amount=$amount";
    });
  }


  RegExp getValidator(int fractions){
    String expression = r'^([1-9]{1}[0-9]{0,' + fractions.toString() +
        r'}(,[0-9]{3})*(.[0-9]{0,'+ fractions.toString() +
        r'})?|[1-9]{1}[0-9]{0,}(.[0-9]{0,'+ fractions.toString() +
        r'})?|0(.[0-9]{0,'+ fractions.toString() +
        r'})?|(.[0-9]{1,'+ fractions.toString() +
        r'})?)$';

    return new RegExp(expression);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              InkWell(
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return SimpleDialog(children: [
                        Center(
                          child: SizedBox(

                            height: MediaQuery.of(context).size.height * 0.33,
                            width: MediaQuery.of(context).size.width * 1,
                            child: Center(
                              child: QrImage(
                                backgroundColor: Colors.white,
                                foregroundColor: Colors.black,
                                data: _qrString ?? widget._unusedAddress,
                              ),
                            ),
                          ),
                        )
                      ]);
                    },
                  );
                },
                child: QrImage(
                  data: _qrString ?? widget._unusedAddress,
                  size: MediaQuery.of(context).size.width * 0.3,
                  padding: EdgeInsets.all(1),
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                ),
              ),
              SizedBox(height: 20),
              Container(
                decoration: BoxDecoration(
                    color: Theme.of(context).accentColor,
                    borderRadius: BorderRadius.all(Radius.circular(4))),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: FittedBox(
                    child: SelectableText(
                      widget._unusedAddress,
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 10),
              TextFormField(
                  textInputAction: TextInputAction.done,
                  key: _amountKey,
                  controller: amountController,
                  onChanged: (String newString) {
                    double parsed =
                        newString != "" ? double.parse(newString) : 0;
                    if (parsed > 0) {
                      stringBuilder(parsed);
                    } else {
                      stringBuilder(0);
                    }
                  },
                  autocorrect: false,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(
                        getValidator(_availableCoin.fractions)
                    ),
                  ],
                  keyboardType: TextInputType.numberWithOptions(signed: true),
                  decoration: InputDecoration(
                    icon: Icon(Icons.money),
                    labelText: AppLocalizations.instance
                        .translate('receive_requested_amount'),
                    suffix: Text(_wallet.letterCode),
                  ),
                  validator: (value) {
                    if (value.isEmpty) {
                      return AppLocalizations.instance
                          .translate('receive_enter_amount');
                    }
                    return null;
                  }),
              SizedBox(height: 30),
              Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: []),
            ],
          ),
        ),
      ),
    );
  }
}
