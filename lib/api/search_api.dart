import 'dart:convert';

import '../Hive/fullProduct.dart';
import '../constants.dart';
import 'package:http/http.dart' as http;
class SearchApi{

  static Future<ProductsSearch?> getSuggestion(String query) async{

    query = query.replaceAll(' ‏', '%');

    http.Response response = await http.get(Uri.parse('$kUrl/guest/searchMainProduct?search=$query'), headers: {
      'Accept': 'application/json',
    });
    Map map = json.decode(response.body);


    if(map.containsKey('data')) {

      return ProductsSearch.fromMap(map['data']);
    }

    return null;
  }
  
}

class ProductsSearch{
  List<FullProduct>? products;
  late List<CraftProduct> craftList;

  ProductsSearch.fromMap(Map map){
    products = List.from(map['product']['data'].map((v) => FullProduct.fromMap(v)));
    craftList = List.from(map['count_crafts'].map((v) => CraftProduct.fromMap(v)));
  }

}

class CraftProduct{
  int? count;
  String? craftName;
  int? id;

  CraftProduct.fromMap(Map map){
    count = map['count'];
    craftName = map['name'];
    id = map['id'];

  }
}