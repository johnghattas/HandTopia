class Interact{
  int? productId;
  int? orderId;
  int? rating;
  String? comment;


  Map<String, dynamic> toMap(){
    return {
      "product_id": productId.toString(),
      "order_id": orderId.toString(),
      'rating': rating.toString(),
      'comment': comment??''
    };
  }
}
