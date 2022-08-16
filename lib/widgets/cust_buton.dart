import 'package:flutter/material.dart';

import '../app_localization.dart';

class CustomButton extends StatelessWidget {
  const CustomButton({
    Key? key,
    required this.hintKey,
    this.function, this.icon, this.width = 150,

  }) : super(key: key);

  final String hintKey;
  final Function? function;
  final IconData? icon;
  final double width;

  @override
  Widget build(BuildContext context) {
    return RaisedButton(
      onPressed: function == null ? () {} : function as void Function()?,
      elevation: 10,
      child: Container(
          width: width,
          height: 50,
          child: Align(
            alignment: Alignment.center,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                icon != null? Icon(icon, color: Colors.white,): Container(),

                SizedBox(width: 16,),
                Text(AppLocalizations.of(context)!.translate(hintKey)!,
                    style: TextStyle(color: Colors.white, fontSize: 18)),
              ],
            ),
          )),
      color: Theme.of(context).primaryColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    );
  }
}