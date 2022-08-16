class Confirm{
  String? name = '';
  String? phone = '';
  String? address = '';
  String? notes = '';
  int? orderCode;

  Confirm({this.name, this.phone, this.address, this.notes, this.orderCode});

  List<String> get listName => name!.split(' ');


}