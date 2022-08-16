import 'dart:convert';

import 'package:fluttertestproject/Hive/comments.dart';
import 'package:fluttertestproject/constants.dart';
import 'package:http/http.dart' as http;

class ProductApi{

  static Future<CommentProduct> getComments(int? productId, [pageCount = 1]) async {



    http.Response response = await http.get(Uri.parse('$kUrl/guest/product/comments/$productId?page=$pageCount'), headers: {
      'accept': 'application/json'
    });

    Map map = json.decode(response.body);


    if(map.containsKey('data')) {
      return CommentProduct.fromMap(map);
    }
    else throw Exception("error ecure");


  }


}

class CommentProduct{
  late List<Comment> comments;
  int? lastPage;

  CommentProduct.fromMap(Map map){
    comments = List.from(map['data']['data'].map((m) => Comment.fromMap(m)));
    lastPage = map['data']['last_page'];
  }

}