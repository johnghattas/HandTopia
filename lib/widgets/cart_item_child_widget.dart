import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../app_localization.dart';
import 'cart_item.dart';

class CartItemChildWidget extends StatelessWidget {
  const CartItemChildWidget({
    Key? key,
    required this.cartItem,
    this.context,
  }) : super(key: key);

  final CartItem cartItem;
  final BuildContext? context;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Stack(
          children: <Widget>[
            Column(
              children: <Widget>[

                SizedBox(height: 16),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      FadeInImage.assetNetwork(
                        placeholder: "assets/group.png",
                        image: cartItem!.product!.images![0]!,
                        height: 100,
                        width: 100,
                      ),
                      SizedBox(width: 16),

                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [

                          Text(cartItem!.product!.title!, style: TextStyle(
                            fontFamily: 'HS Dream',
                            fontSize: 18,
                            color: const Color(0xff000000),
                            fontWeight: FontWeight.w500,
                          ),softWrap: true, maxLines: 2, overflow: TextOverflow.ellipsis,),
                          SizedBox(height: 16),
                          Row(
                            children: <Widget>[
                              InkWell(
                                borderRadius: BorderRadius.circular(15),
                                child: Container(
                                  width: 26,
                                  height: 26,
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(13),
                                    child: Center(
                                        child: Icon(
                                          Icons.add,
                                          color: Colors.white,
                                        )),
                                  ),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(20),
                                    color: Theme.of(context).primaryColor,
                                  ),
                                ),
                                onTap: increment,
                              ),
                              SizedBox(width: 10),
                              Center(
                                child: Container(
                                  child: Text(
                                    cartItem!.count.toString(),
                                    style: TextStyle(
                                        fontSize: 26,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xffD6D6D6)),
                                  ),
                                ),
                              ),
                              SizedBox(width: 10),
                              InkWell(
                                borderRadius: BorderRadius.circular(15),
                                onTap: decrement,
                                child: Container(
                                  width: 26,
                                  height: 26,
                                  child: Icon(Icons.remove, color: Colors.white,),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(13),
                                    color: Theme.of(context).primaryColor,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],),
                      )
                    ],
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(
                        '${AppLocalizations.of(context)!.translate("total_price")} : ${cartItem!.itemTotalPrice().round()} ${AppLocalizations.of(context)!.translate('eg_currency')}',
                        style: TextStyle(color: Theme.of(context).primaryColor, fontWeight: FontWeight.bold),
                    )
                  ],
                ),
                SizedBox(height: 16),
              ],
            ),
            Positioned(
              bottom: 16,
              right: 16,
              child: InkWell(
                onTap: deleteItem,
                child: Icon(
                  CupertinoIcons.delete_simple,
                  color: Colors.red,
                  size: 40,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  void increment() {
    if(this.cartItem!.count == 10){
      return;
    }
    this.cartItem!.count++;
    this.cartItem!.save();
  }

  void decrement() {
    if(this.cartItem!.count == 1){
      return;
    }
    this.cartItem.count--;
    this.cartItem.save();
  }

  void deleteItem() async {
    AwesomeDialog(
        context: this.context!,
        dialogType: DialogType.WARNING,
        desc: AppLocalizations.of(context!)!.translate("warning_to_delete") ?? '',
        animType: AnimType.BOTTOMSLIDE,
        title: AppLocalizations.of(context!)!.translate("warning"),
        dismissOnTouchOutside: false,
        btnOk: RaisedButton(
          color: Colors.blueAccent,
          child: Text(AppLocalizations.of(context!)!.translate("ok")!, style: TextStyle(color: Colors.white)),
          onPressed: () {
            Navigator.pop(context!);
            this.cartItem!.delete();

          },
        ),
        btnCancel: RaisedButton(
          color: Colors.red,
          child: Text(AppLocalizations.of(context!)!.translate("cancel")!, style: TextStyle(color: Colors.white),),
          onPressed: () {
            Navigator.pop(context!);
          },
        ),
        btnOkColor: Colors.black)
      ..show();
  }
}