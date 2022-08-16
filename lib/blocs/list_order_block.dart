import 'dart:async';

import '../api/order_request.dart';
import '../components/Order.dart';
import '../responses/response.dart';

class ListOrderBlock{
  String? _token;
  OrderApi? _orderApi;
  StreamController? _listOrderController;

  StreamSink<Response<List<Order>>> get chuckListSink =>
      _listOrderController!.sink as StreamSink<Response<List<Order>>>;

  Stream<Response<List<Order>>> get chuckListStream =>
      _listOrderController!.stream as Stream<Response<List<Order>>>;

  ListOrderBlock(this._orderApi, this._token) {
    _listOrderController = StreamController<Response<List<Order>>>();
    fetchListOrder();
  }

  fetchListOrder() async{
    chuckListSink.add(Response.loading('loading the data'));

     try {
       List<Order> orderList =
       await _orderApi!.getUserOrder(_token);
       chuckListSink.add(Response.completed(orderList));
     } catch (e) {
       print(e);
     }
   }
  dispose() {
    chuckListSink.add(Response.error('this error'));

    _listOrderController?.close();
  }
}