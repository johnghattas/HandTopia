import '../components/product.dart';

class Order{

  int? code;
  List<Product>? products = [];
  List<int?> quantity = [];
  List<bool> ratings = [];
  DateTime? dateBuy;
  String? _state;

  Order({this.code, this.products, this.dateBuy});

  Order.fromMap(int key, List map){
    code = key;
    map.forEach((element) {
      products!.add(Product.fromMap(element['product']));
      quantity.add(element['pivot']['quantity']);

      int? rating = element['pivot']['is_rate'];
      ratings.add(rating == null || rating == 0? false:  true);
    });

    dateBuy = DateTime.parse(map[0]['pivot']['created_at']);
    _state = map[0]['pivot']['state']??'';
  }

  String get state {

    switch(this._state){
      case "done":
        return "done_status";
      case "error_contact":
        return "error_contact_status";
      case "":
        return "waiting_status";

      default:
        return "deliver_waiting_status";
    }
  }
}