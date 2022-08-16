import 'package:hive/hive.dart';

part 'user_model.g.dart';

@HiveType(typeId: 2)
class UserP extends HiveObject{

  @HiveField(0)
  String? name;
  @HiveField(1)
  String? email;
  @HiveField(2)
  String? image;
  @HiveField(3)
  String? token;
  @HiveField(4)
  bool? tokenAvailable;
  @HiveField(5)
  String? address;
  @HiveField(6)
  String? phone;


  UserP({this.name, this.email, this.image, this.token
      ,this.address, this.phone});


  UserP.fromMap(Map map){
    name = map['first_name'] + ' ' + map['last_name'];
    email = map['email'];
    image = map['photo'];
    address = map['address'];
    phone = map['phone'];
  }
}