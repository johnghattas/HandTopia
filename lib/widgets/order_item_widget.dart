import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import '../api/order_request.dart';
import '../app_localization.dart';
import '../components/custom_button.dart';
import '../components/interact.dart';

import '../components/Order.dart';
import '../constants.dart';

typedef void Type(int? value);


class OrderItem extends StatefulWidget {
  final Order? order;
  final String? token;
  final Type? removeItemFunction;
  final int? index;


  const OrderItem({Key? key, this.order, this.token, this.removeItemFunction, this.index}) : super(key: key);

  @override
  _OrderItemState createState() => _OrderItemState();
}

class _OrderItemState extends State<OrderItem> {

  int? _currentIndex ;
  Order? order;
  late Interact _interact;
  late OrderApi _orderApi;

  bool _isPressOk = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _interact = Interact();
    _orderApi = OrderApi();
    order = widget.order;
    _currentIndex = 0;

  }
  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    var local = AppLocalizations.of(context)!;


    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            child: Column(
              children: [
               Container(
                 width: double.infinity,
                 child: Row(
                   mainAxisAlignment: MainAxisAlignment.spaceAround,
                   children: [
                     Center(
                       child: Padding(
                         padding: const EdgeInsets.all(16),
                         child: Container(
                           width: 150,
                           height: 100,

                           child: Container(
                             decoration: BoxDecoration(
                               image: DecorationImage(
                                 image: CachedNetworkImageProvider(order!.products![_currentIndex!].images![0]!),
                                 fit: BoxFit.fill,
                               ),
                               borderRadius: BorderRadius.circular(20.0),
                             ),
                           ),
                         ),
                       ),
                     ),


                     if((order!.ratings[_currentIndex!] == null || order!.ratings[_currentIndex!] == false) && order!.products![_currentIndex!].isRate != true && order!.state == 'done_status')
                       RatingBar.builder(

                         itemBuilder: (context, index) => Icon(Icons.star, color: kButtonColor,),
                         onRatingUpdate: (v) {

                           _interact.productId = order!.products![_currentIndex!].id;
                           _interact.orderId = order!.code;
                           _interact.rating = v.toInt();
                           dialogComment(local, _currentIndex);
                         },
                         itemCount: 5,
                         minRating: 1,
                         tapOnlyMode: false,
                         itemSize: 30,
                       )

                   ],
                 ),
               ),
                Text(
                  order!.products![_currentIndex!].title ?? '',
                  style: TextStyle(
                    fontFamily: 'HS Dream',
                    fontSize: 28,
                    color: const Color(0xffffffff),
                    fontWeight: FontWeight.w500,

                  ),
                  textAlign: TextAlign.right,
                ),
              ],
            ),
          ),

          Container(
            height: order!.products!.length - 1 == 0? 0:60,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              shrinkWrap: true,
              padding: EdgeInsets.symmetric(horizontal: 16),
              itemCount: order!.products!.length ,
              itemBuilder: (context, index) => GestureDetector(
                onTap: () {
                  setState(() {
                    _currentIndex = index ;
                  });
                },
                child: Container(
                  width: 60,
                  height: 59.0,
                  margin: EdgeInsets.only(left: 10),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(13.0),
                      color: const Color(0xff323232),
                      image: DecorationImage(
                          image: CachedNetworkImageProvider(order!.products![index].images![0]!),
                          fit: BoxFit.cover),
                      border: (index == _currentIndex)
                          ? Border.all(color: kButtonColor, width: 2)
                          : null),
                ),
              ),
            ),
          ),
          SizedBox(height: 10),

          _titleAndContent(local.translate('code')!, order!.code.toString(), width * .88),
          SizedBox(height: 10),
          _titleAndContent(local.translate('date_buying')!, order!.dateBuy!.toLocal().toString().trimRight(), width * 0.9),
          SizedBox(height: 10),
          _titleAndContent(local.translate('status')!, local.translate(order!.state) ?? '', width * .9),
          
          (order!.state == 'waiting_status')?
          Align(alignment: local.locale.languageCode == 'ar'? Alignment.bottomLeft: Alignment.bottomRight,child: RaisedButton(onPressed: () => widget.removeItemFunction!(widget.index), child: Text(local.translate('remove_order')??'', style: TextStyle(color: Colors.white70),), color: kButtonColor, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),)):Container()
        ],
      )
    );
  }

  Widget _titleAndContent(String title, String data, double width) {
    return Row(
      children: [

        Text(
          title,
          style: TextStyle(
            fontFamily: 'HS Dream',
            fontSize: 20,
            color: const Color(0xffffffff),
            fontWeight: FontWeight.w700,
          ),
        ),
        SizedBox(
          width: 16,
        ),
        Expanded(
          child: Text(
            data??'',
            style: TextStyle(color: Colors.white, fontSize: 16, height: 1.2),
            softWrap: true,
          ),
        ),
      ],
    );
  }
  
  dialogComment(AppLocalizations local, int? index) {
    showDialog(
      context: context, builder: (context) {
      return AlertDialog(
        shape:
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: kFillColor,
        title: Text(local.translate('comment_title')!, style: kTextStyle),
        content: SingleChildScrollView(
          child: Container(
            height: 200,
            width: double.infinity,
            child: Column(
              children: [

                FieldCustom(
                  height: 200,

                  maxLine: 6,
                  inputType: TextInputType.multiline,
                  onchange: (v) => _interact.comment = v,
                )
              ],
            ),
          ),
        ),
        actions: [
          RaisedButton(onPressed: () => _makeInteract(context, index), child: Text(local.translate('done')!, style: kTextStyle,), color: kButtonColor, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),)
        ],
      ); 
    },);
  }

  void _makeInteract(BuildContext context, int? index) async{
    Navigator.pop(context);

    var map =  await _orderApi.makeUserProductInteract(widget.token, _interact);

    setState(() {
      _interact = Interact();
      order!.ratings[index!] = true;
    });


  }


}
