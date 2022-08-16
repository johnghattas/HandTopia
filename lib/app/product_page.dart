import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fluttertestproject/app/product_image_zoom.dart';
import 'package:fluttertestproject/Hive/comments.dart';
import 'package:fluttertestproject/Hive/fullProduct.dart';
import 'package:fluttertestproject/api/product_api.dart';
import '../widgets/cart_item.dart';
import '../widgets/cust_buton.dart';
import '../../app_localization.dart';
import '../../components/product.dart';
import '../../components/static_metholds.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;

import '../../constants.dart';
import '../../app/craft_page.dart';

class ProductPage extends StatefulWidget {
  final Product? product;
  final FullProduct? fullProduct;

  const ProductPage({Key? key, this.product, this.fullProduct}) : super(key: key);

  @override
  _ProductPageState createState() => _ProductPageState();
}

class _ProductPageState extends State<ProductPage> {
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  GlobalKey _sizeKey = GlobalKey();
  ScrollController? _scrollController;
  String? _currentImage;

  var _productFuture;

  Future<CommentProduct>? _commentsFuture;
  bool _isFirst = false;
  late int _currentPage;

  List<Comment> _commentsList = [];

  bool _isShow = false;


  @override
  void initState() {
    // TODO: implement initState
    _scrollController = ScrollController();
    _scrollController!.addListener(() {
      if(_isViewed){
        setState(() {

        });
      }
    });
    super.initState();
    _currentPage = 1;
    _productFuture = getProduct();
    Methods.cartsBox = Hive.box<CartItem>('carts');
    _currentImage = widget.product!.images![0];
  }

  @override
  void dispose() {
    super.dispose();
    _scrollController!.dispose();

  }


  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    Orientation orientation = MediaQuery.of(context).orientation;
    if(_isViewed && !_isFirst){
      try{
        _commentsFuture = ProductApi.getComments(widget.product!.id).whenComplete(() {
        });
      }catch(e) {
       // print.*
      }
      _isFirst = true;
    }

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: kBackground,
      appBar: AppBar(
        backgroundColor: kBackground,
        actions: [
          InkWell(
              onTap: goToCraft,
              child: SvgPicture.asset(
                'assets/logo.svg',
                height: 30,
                width: 30,
              )),
          SizedBox(
            width: 16,
          )
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          controller: _scrollController,
          child: Column(
            children: <Widget>[
              orientation == Orientation.landscape
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Spacer(),
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Container(
                            height: height * 0.5,
                            child: GestureDetector(
                              onTap: _tapDialogImage,
                              child: Hero(
                                tag: _currentImage!,
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(20.0),
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(20.0),
                                    child: CachedNetworkImage(
                                      useOldImageOnUrlChange: true,
                                      progressIndicatorBuilder:
                                          (context, url, downloadProgress) =>
                                              Center(
                                        child: SizedBox(
                                          height: 20,
                                          width: 20,
                                          child: CircularProgressIndicator(
                                              strokeWidth: 1.5,
                                              value: downloadProgress.progress),
                                        ),
                                      ),
                                      errorWidget: (context, url, error) =>
                                          Icon(Icons.error),
                                      imageUrl: _currentImage!,
                                      fit: BoxFit.fitHeight,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        Spacer(),
                        Container(
                          height: height * 0.5,
                          width: width * 0.2,
                          child: ListView.builder(
                            primary: false,
                            scrollDirection: Axis.vertical,
                            shrinkWrap: true,
                            padding: EdgeInsets.symmetric(horizontal: 16),
                            itemCount: widget.product!.images!.length,
                            itemBuilder: (context, index) => GestureDetector(
                              onTap: () {
                                setState(() {
                                  _currentImage = widget.product!.images![index];
                                });
                              },
                              child: Container(
                                width: height * 0.25,
                                height: height * 0.2,
                                margin: EdgeInsets.only(bottom: 10),
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(13.0),
                                    color: const Color(0xff323232),
                                    image: DecorationImage(
                                        image: NetworkImage(
                                            widget.product!.images![index]!),
                                        fit: BoxFit.cover),
                                    border: (widget.product!.images![index] ==
                                            _currentImage)
                                        ? Border.all(
                                            color: kButtonColor, width: 2)
                                        : null),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(13.0),
                                  child: CachedNetworkImage(
                                    useOldImageOnUrlChange: true,
                                    progressIndicatorBuilder:
                                        (context, url, downloadProgress) =>
                                            Center(
                                      child: SizedBox(
                                        height: 15,
                                        width: 15,
                                        child: CircularProgressIndicator(
                                            strokeWidth: 1.5,
                                            value: downloadProgress.progress),
                                      ),
                                    ),
                                    errorWidget: (context, url, error) =>
                                        Icon(Icons.error),
                                    imageUrl: widget.product!.images![index]!,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    )
                  : Column(
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Container(
                            height: height * .30,
                            child: GestureDetector(
                              onTap: _tapDialogImage,
                              child: Hero(
                                tag: _currentImage!,
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(20.0),
//                            color: Colors.white,
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(20.0),
                                    child: CachedNetworkImage(
                                      useOldImageOnUrlChange: true,
                                      progressIndicatorBuilder:
                                          (context, url, downloadProgress) =>
                                              Center(
                                        child: CircularProgressIndicator(
                                            value: downloadProgress.progress),
                                      ),
                                      errorWidget: (context, url, error) =>
                                          Icon(Icons.error),
                                      imageUrl: _currentImage!,
                                      fit: BoxFit.fitHeight,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        Container(
                          height: height * 0.12,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            shrinkWrap: true,
                            padding: EdgeInsets.symmetric(horizontal: 16),
                            itemCount: widget.product!.images!.length,
                            itemBuilder: (context, index) => GestureDetector(
                              onTap: () {
                                setState(() {
                                  _currentImage = widget.product!.images![index];
                                });
                              },
                              child: Container(
                                width: height * 0.12,
                                height: 59.0,
                                margin: EdgeInsets.only(left: 10),
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(13.0),
                                    color: const Color(0xff323232),
                                    border: (widget.product!.images![index] ==
                                            _currentImage)
                                        ? Border.all(
                                            color: kButtonColor, width: 2)
                                        : null),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(13.0),
                                  child: CachedNetworkImage(
                                    useOldImageOnUrlChange: true,
                                    progressIndicatorBuilder:
                                        (context, url, downloadProgress) =>
                                            Center(
                                      child: SizedBox(
                                        height: 10,
                                        width: 10,
                                        child: CircularProgressIndicator(
                                            strokeWidth: 1,
                                            value: downloadProgress.progress),
                                      ),
                                    ),
                                    errorWidget: (context, url, error) =>
                                        Icon(Icons.error),
                                    imageUrl: widget.product!.images![index]!,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
              FutureBuilder(
                  future: _productFuture,
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      var data = snapshot.data;

                      return _buildItemFuture(height, data, width, orientation);
                    } else {
                      return Padding(
                        padding: const EdgeInsets.only(top: 16.0),
                        child: Center(child: CupertinoActivityIndicator()),
                      );
                    }
                  }),

              Container(key: _sizeKey, height: 10),
              _isFirst ||_isViewed? _commentsArea(AppLocalizations.of(context))
                  : Container(

                    ),
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Column _buildItemFuture(
      double height, data, double width, Orientation orientation) {
    double rating = _calculateRating(data['review_of_five'], data['users_review']);

    return Column(
      children: <Widget>[

        SizedBox(height: 40),
        RatingBarIndicator(
          itemBuilder: (context, index) =>
              Icon(Icons.star, color: kButtonColor),
          itemCount: 5,
          rating: rating,
        ),
        Text(rating.toStringAsFixed(2), style: kTextStyle,),

        SizedBox(height: 20),
        itemTitle(context, width, 'product_title', data['title']),
        SizedBox(height: 10),
        itemTitle(context, width, 'price_title', data['price']),
        SizedBox(height: 10),
        itemTitle(context, width, 'seller_title', data['saller']['name']),
        SizedBox(height: 10),
        itemTitle(context, width, 'material_title',
            _materialString(data['materials'])),
        SizedBox(height: 10),
        itemTitle(context, width, 'story_title', data['history_of_product']),
        SizedBox(height: 20),
        CustomButton(
          width: 200,
          hintKey: 'add_to_cart',
          icon: Icons.shopping_cart,
          function: () {
            Methods.addToCart(
              scaffoldState: _scaffoldKey,
              context: context,
              product: widget.product!,
            );
          },
        ),
        SizedBox(height: 20,),

        Text(
          AppLocalizations.of(context)!.translate('comments_title')!,
          style: TextStyle(
            fontFamily: 'HS Dream',
            fontSize: 20,
            color: const Color(0xffffffff),
            fontWeight: FontWeight.w300,
            decoration: TextDecoration.underline,
          ),
          textAlign: TextAlign.right,
        ),

      ],
    );
  }

  _calculateRating(int? reviews, int? userCount) {
    return (reviews == 0? 5:reviews)!/
            (userCount == 0 ? 1 : userCount!  );
  }

  Widget _commentsArea(local) {
    return FutureBuilder<CommentProduct>(
      future: _commentsFuture,
      builder: (context, snapshot) {

        return _commentBody(snapshot, local);
      },
    );
  }

  Widget itemTitle(BuildContext context, double width, hint, data) {
    String title = AppLocalizations.of(context)!.translate(hint)! + ':';

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            title,
            style: TextStyle(
              fontFamily: 'HS Dream',
              fontSize: 20,
              height: 1.2,
              color: const Color(0xffffffff),
            ),
          ),
          SizedBox(
            width: 16,
          ),
          Expanded(
            child: Text(
              data,
              style: TextStyle(color: hint == 'price_title' ? kButtonColor :Colors.white, fontSize: 16),
              softWrap: true,
              
              maxLines: 9,
            ),
          ),
        ],
      ),
    );
  }

  Future getProduct() async {
    http.Response request = await http.get(Uri.parse('$kUrl/guest/product/${widget.product!.id}'),
        headers: {'Accept': 'application/json'});

    Map map = jsonDecode(request.body);

    if (request.statusCode != 200) {

    }

    if (map.containsKey('data')) {

      return map['data'];

    } else {

      return null;
    }
  }

  String _materialString(List list) {
    String materials = '';
    list.forEach((e) => materials += e['material'] + ' , ');
    return materials.substring(0, materials.length - 2);
  }


  double getRenderSize(String title, double fontSize) {
    RenderParagraph renderParagraph = RenderParagraph(
      TextSpan(
        text: title,
        style: TextStyle(
          fontSize: fontSize,

        ),
      ),

      maxLines: 1, textDirection: AppLocalizations
        .of(context)!
        .locale
        .languageCode == "Ar" ? TextDirection.rtl : TextDirection.ltr,
    );

    return renderParagraph.getMinIntrinsicWidth(fontSize).ceilToDouble();
  }

  void goToCraft() {
    Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => CraftPage()),
            (r) => !r.navigator!.canPop());
  }

  void _tapDialogImage() {
    List<String?>? images = widget.product!.images;
   Navigator.push(context, MaterialPageRoute(builder: (context) => ImageZoom(images: images, currentIndex: images!.indexOf( _currentImage),),));
  }

   double? _getPosition(){
    RenderBox?  r=  _sizeKey.currentContext?.findRenderObject() as RenderBox?;
    Offset? position = r?.localToGlobal(Offset.zero);
    return position?.dy;
  }

  bool get _isViewed =>   (_scrollController != null &&  _getPosition() != null )&& _scrollController!.offset <= _getPosition()!;

  Widget _commentBody(AsyncSnapshot<CommentProduct> snapshot, AppLocalizations? local) {
    if(snapshot.hasError){
      return Container(height: 100, width: double.infinity,child: Center(child: Text('error', style: kTextStyle)));
    }

    if(snapshot.hasData) {

      if(!_isShow)
        _commentsList.addAll(snapshot.data!.comments);

      _isShow = true;
      var data = _commentsList;
      if(data.length == 0){
        return Container(
          width: double.infinity,
          height: 200,
          margin: EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: kFillColor,

          ),
          child: Center(
              child: Text(
                local!.translate('no_comments')!,
                style: kTextStyle,
              )),
        );

      }
      return Container(
        margin: EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: kFillColor,

        ),
        child: ListView.builder(primary: false,itemBuilder: (context, index) =>  Column(
          children: [
            ListTile(
              leading: ClipRRect(borderRadius: BorderRadius.circular(25),child: data[index].imageUrl == null? Image.asset('assets/default_profile.png', width: 50, height: 50, fit: BoxFit.cover,):Image.network(data[index].imageUrl!, width: 50, height: 50, fit: BoxFit.cover,)),
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    data[index].name,
                    style: TextStyle(
                      fontFamily: 'HS Dream',
                      fontSize: 16,
                      color: const Color(0xffc40018),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  RatingBarIndicator(itemBuilder: (context, index) => Icon(Icons.star, color: kButtonColor,),itemCount: 5, itemSize: 10, rating:  data[index].review?.toDouble() ?? 4.0,)
                ],
              ),
              subtitle: Text(data[index].comment!, softWrap: true, style: kTextStyle,),
            ),
              Divider(color: Colors.white60,),
              (index == data.length - 1 && snapshot.data!.lastPage! > _currentPage)
                  ? RaisedButton(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                      onPressed: _showMoreComments,
                      color: kPrimaryColor,
                      child: Container(
                        width: 85,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(local!.translate('see_more')!, style: kTextStyle),
                            Icon(Icons.arrow_drop_down)
                          ],
                        ),
                      ),
                    )
                  : Container(),

            ],
        ), itemCount: data.length, shrinkWrap: true, ),
      );
    }
    else
      return Container(
        width: double.infinity,
        height: 200,
        margin: EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: kFillColor,

        ),

      );
  }

  void _showMoreComments() {
     ProductApi.getComments(widget.product!.id,  ++_currentPage).then((value) {
       _commentsList.addAll(value.comments);
       setState(() {

       });
     });
  }
}
