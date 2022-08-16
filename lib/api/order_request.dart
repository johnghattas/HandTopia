import 'dart:async';
import 'dart:convert';

import 'package:flutter/cupertino.dart';

import '../Hive/user_model.dart';
import '../components/Order.dart';
import '../components/interact.dart';
import '../constants.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
class OrderApi {

  Future requestUserOrder(token) async {
    http.Response response = await http.get(Uri.parse('$kUrl/user/userOrder'), headers: {
      'Accept' : "application/json",
      'Authorization' : "Bearer $token"
    });

    return json.decode(response.body);
  }

  Future<List<Order>> getUserOrder(token) async{

    Map map = await (requestUserOrder(token) as FutureOr<Map<dynamic, dynamic>>);


    if(map.containsKey('data')){

      Map list = map['data'];
      return List.from(list.keys.map((e) {

        return Order.fromMap(int.parse(e), list[e]);
      }));


    }else if (map.containsKey('message') && map['message'].toString().contains('Unauthenticated')){
      Hive.box('user').put('userData', UserP()..tokenAvailable = false);
    }

    return [];

  }

  makeUserProductInteract(String? token, Interact interact) async{





    http.Response response = await http.put(Uri.parse('$kUrl/user/makeInteract'), body: interact.toMap(), headers: {
      'accept': 'application/json',
      'Authorization': 'Bearer $token'
    });
    return  json.decode(response.body);
  }

  removeOrder(String? token, int? orderId) async{
    http.Response response = await http.delete(Uri.parse('$kUrl/user/order/remove/$orderId'), headers: {
      'accept': 'application/json',
      'Authorization': 'Bearer $token'
    });
    Map map = json.decode(response.body);



    if(response.statusCode == 400){
      throw Expanded(child: map['error']);
    }

    if(map.containsKey('data')) {
      return 'done';
    }
    else
      throw Exception('fail');
  }
}