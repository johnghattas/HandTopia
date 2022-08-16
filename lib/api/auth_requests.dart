import 'dart:convert';

import '../Hive/user_model.dart';
import '../constants.dart';
import '../models/confirm_model.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
class UserApi{

  Future changeUser(String? token, UserP user) async{
    http.Response response = await http.put(Uri.parse('$kUrl/user/auth/change'), headers: {
      'Accept' : 'application/json',
      'Authorization': 'Bearer $token'
    }, body: {
      'photo': user.image,
      'phone' : user.phone,
      'address': user.address
    });

    Map map = json.decode(response.body);

    if(map.containsKey('data')){
//      print('this is data + ${map['data']}');

    }else{
//      print('an error occure');
    }
  }

  Future modifyUserNotes(String? token, Confirm confirm) async{


    http.Response response = await http.put(Uri.parse('$kUrl/user/modifyAddNote'), headers: {
      'Accept' : 'application/json',
      'Authorization': 'Bearer $token'
    }, body: {
      'phone' : confirm.phone!.trim(),
      'address': confirm.address!.trim(),
      'first_name': confirm.listName[0].trim(),
      'last_name': (confirm.listName.length > 1)? confirm.listName[1].trim() : '',
      'order_id': confirm.orderCode.toString().trim(),
      'note': confirm.notes!.trim() == ''? "!": confirm.notes!.trim()
    });

    Map map = json.decode(response.body);


    if(map.containsKey('data')){
      UserP user = Hive.box('user').get('userData');
      var listName = confirm.name!.split(' ');

      user..name = '${listName[0]} ${listName[1]??''}'..address = confirm.address..phone=confirm.phone..save();
      return true;
    }else{
      return false;
    }
  }

}