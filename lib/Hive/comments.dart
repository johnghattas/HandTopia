class Comment{
  String? _firstName;
  String? _lastName;
  String? comment;
  String? imageUrl;
  String? email;
  int? review;


  Comment.fromMap(Map map){
    _firstName = map['first_name'];
    _lastName = map['last_name'];
    comment = map['comment'];
    email = map['email'];
    imageUrl = map['photo'];
    review = map['review'];
  }

  String get name => '$_firstName $_lastName';


}