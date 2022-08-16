import 'package:flutter/material.dart';
import 'package:fluttertestproject/widgets/cart_item.dart';
import 'package:fluttertestproject/components/product.dart';
import 'package:hive/hive.dart';

import '../app_localization.dart';

class Methods{

  static late Box cartsBox;



  static void addToCart({required scaffoldState,required context,required Product product}) async {
////    List<CartItem> list = userBox.get('card.items')?? [];



    if (cartsBox.keys.contains('${product.id}')) {

      CartItem card = cartsBox.get('${product.id}');
      card.count++;
      card.save();


      _showScaffold(scaffoldState, context);
      return;
    }
    cartsBox.put("${product.id}", CartItem(product: product));
    _showScaffold(scaffoldState, context);
  }

  static void _showScaffold(GlobalKey<ScaffoldState> scaffoldState, context) {
    scaffoldState.currentState!.hideCurrentSnackBar();
    scaffoldState.currentState!.showSnackBar(SnackBar(
      content: Text(AppLocalizations.of(context)!.translate('added_to_cart')!),
      backgroundColor: Theme.of(context).primaryColor,
      duration: Duration(seconds: 2),
    ));
  }


}