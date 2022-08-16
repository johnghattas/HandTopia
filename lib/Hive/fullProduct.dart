import '../components/product.dart';

class FullProduct extends Product{
  Seller? seller;
  Craft? craft;
  List<String>? materials;

  FullProduct.fromMap(Map map): super.fromMap(map){

    if(map.containsKey('materials')) {
      List materials = map['materials'];
      this.materials = List.from(materials.map((value) => value['material']));
    }
    if(map.containsKey('craft'))
    craft = Craft.fromMap(map['craft']);
    if(map.containsKey('saller'))
    seller = Seller.fromMap(map['saller']);

  }
}

class Craft {
  int? id;
  String? name;
  String? image;


  Craft.fromMap(Map map){
    id = map['id'];
    name = map['name'];
    image = map['image'];
  }
}

class Seller {
  int? id;
  String? name;

  Seller.fromMap(Map map){
    id = map['id'];
    name = map['name'];
  }
}