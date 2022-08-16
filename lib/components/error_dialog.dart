import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../app_localization.dart';

class ErrorDialogs{

  static void failedDialog(BuildContext context, {hint = "unexpected_error", message}) {

    AwesomeDialog(
        context: context,
        dialogType: DialogType.ERROR,
        desc: message != null
            ? message
            : AppLocalizations.of(context)!.translate(hint) ?? '',
        animType: AnimType.TOPSLIDE,
        title: 'Error',
        btnOk: RaisedButton(
          child: Text('ok'),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        btnOkColor: Colors.black)
      ..show();
  }

  static Widget errorContainer(BuildContext context, [String message = 'error']){
    return Center(
      child: Container(
        color: Colors.red,
        width: MediaQuery.of(context).size.width,
        margin: EdgeInsets.only(top: 16, bottom: 16),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(message, style: TextStyle(color: Colors.white), textAlign: TextAlign.center,),
        ),
      ),
    );
  }
}