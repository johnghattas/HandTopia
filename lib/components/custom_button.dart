import 'package:flutter/material.dart';

import '../app_localization.dart';

typedef String? ValidateType(String? value);
class FieldCustom extends StatelessWidget {
  final ValidateType? onValidate;

  const FieldCustom({
    Key? key,
    this.hintKey,
    this.onchange,
    this.obscurity = false, this.height, this.maxLine = 1, this.minLine, this.isNumber, this.onSave, this.readOnly = false, this.initialValue, this.validate = true, this.isSecondName = false, this.inputType = TextInputType.text, this.onValidate,
  }) : super(key: key);

  final String? hintKey;
  final ValueChanged? onchange;
  final ValueChanged? onSave;
  final bool obscurity;
  final bool? isNumber;
  final bool isSecondName;
  final double? height;
  final int maxLine;
  final int? minLine;
  final bool readOnly;
  final String? initialValue;
  final bool validate;
  final TextInputType inputType;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Container(
          height: height ?? 50,
          child: Container(),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: Colors.white,
              ),
        ),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: TextFormField(
            initialValue: initialValue,
            readOnly: readOnly,
            onChanged: onchange,
            decoration: InputDecoration(
              hintText: hintKey == null ? '': AppLocalizations.of(context)!.translate(hintKey),
              focusedBorder: InputBorder.none,
              enabledBorder: InputBorder.none,
            ),

            obscureText: obscurity,
            validator: onValidate != null? onValidate:validate? (String value) {
              if (value.trim().isEmpty) {
                return hintKey != null? 'please enter $hintKey' : AppLocalizations.of(context)!.translate('please_etf');
              }else if (hintKey == 'email' && !isEmail(value)){
                return "wrong format";
              }else if(hintKey == 'password'){
                return value.length < 6? 'password should be grater than 6': null;
              }else if(isSecondName && value.split(' ').length < 2){
                return "first & second required";
              }else if(isNumber?? false) {
                return !itNumber(value)?  'write correct phone number':null;
              }
              return null;
            } as String? Function(String?)?: null,
            keyboardType: isNumber?? false? TextInputType.phone : (hintKey == 'email')? TextInputType.emailAddress : inputType,
            maxLines: maxLine,
            minLines: minLine,
            onSaved: onSave,
          ),
        )
      ],
    );
  }

  bool isEmail(String value) {
    String regex =
        r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
    RegExp regExp = new RegExp(regex);

    return value.isNotEmpty && regExp.hasMatch(value);
  }

  bool itNumber(value) {
    if(value == null) {
      return false;
    }
    return double.parse(value, ((e) => null) as double Function(String)?) != null;
  }
}
