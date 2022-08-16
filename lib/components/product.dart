import 'package:hive/hive.dart';

part 'product.g.dart';

@HiveType(typeId: 1)
class Product{

  @HiveField(0)
  int? id;
  @HiveField(1)
  String? title;
  @HiveField(2)
  double? price;
  @HiveField(3)
  List<String?>? images;
  bool? isRate;


  Product({this.id, this.title, this.price, this.images});

  Product.fromMap(Map map){
    id = map['id'] ?? 0;
    title = map['title'];
    price = double.parse(map['price']);
    images = List.from(map['photos'].map((m) => m['photo']));
    isRate = map.containsKey('is_rate')? map['is_rate'] :null;


  }
}