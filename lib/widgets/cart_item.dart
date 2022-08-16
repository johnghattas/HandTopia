import 'package:flutter/cupertino.dart';
import '../components/product.dart';
import 'package:hive/hive.dart';

part 'cart_item.g.dart';

@HiveType(typeId: 0)
class CartItem extends HiveObject{

  @HiveField(0)
  Product? product;
  @HiveField(1)
  int count;

  CartItem({required this.product, this.count = 1});

  double itemTotalPrice() {
    return this.product!.price! * this.count;
  }


}