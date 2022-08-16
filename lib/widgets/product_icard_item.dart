import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fluttertestproject/widgets/custom_animation_button.dart';
import 'cart_item.dart';
import '../components/product.dart';
import 'package:hive/hive.dart';

import '../app_localization.dart';

class ProductCardItem extends StatelessWidget {
  const ProductCardItem({
    Key? key,
    required this.product,
    required this.width,
    required this.cartsBox,
    required this.scaffoldState,
    required this.context,
  }) : super(key: key);

  final Product product;
  final double width;
  final Box? cartsBox;
  final GlobalKey<ScaffoldState> scaffoldState;
  final BuildContext context;

  @override
  Widget build(BuildContext context) {

    return Card(
      color: Colors.transparent,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SizedBox(
          width: width,
          child: Column(
            children: <Widget>[
              SizedBox(
                width: width,
                height: 130.0,
                child: Stack(
                  children: <Widget>[
                    Positioned.fill(
                      child: Hero(
                        tag: product.images![0]!,
                        child: Container(
                          decoration: BoxDecoration(

                            borderRadius: BorderRadius.circular(20.0),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(20.0),
                            child: CachedNetworkImage(

                              imageUrl: product.images![0]!,
                              progressIndicatorBuilder: (context, url, downloadProgress) =>
                                  Center(child: SizedBox(width: 25, height: 25,child: CircularProgressIndicator(value: downloadProgress.progress, strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),))),
                              errorWidget: (context, url, error) => Center(child: Icon(Icons.error)),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20.0),
                        color: const Color(0x4a000000),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 5,
              ),
              Text(
                product.title!,
                style: TextStyle(
                  fontFamily: 'HS Dream',
                  fontSize: 15,
                  color: const Color(0xffffffff),
                  fontWeight: FontWeight.w700,
                  height: 1.75,
                ),
                textAlign: TextAlign.right,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(
                height: 12,
              ),
              SizedBox(
//                height: 50,
                width: width,
                child: Row(
                  children: <Widget>[
                    Flexible(
                      flex: 2,
                      child: CustomAnimationButton(onPressed: addToCart, color: const Color(0xffffac41), icon: Icon(Icons.shopping_cart, color: Colors.white), height: 32,)
                      // child: InkWell(
                      //   onTap: addToCart,
                      //
                      //   child: Container(
                      //     padding:
                      //         EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                      //     width: width,
                      //     decoration: BoxDecoration(
                      //       borderRadius: BorderRadius.circular(10.0),
                      //       color: const Color(0xffffac41),
                      //     ),
                      //     child: SvgPicture.string(
                      //       '<svg viewBox="111.0 217.0 20.0 20.0" ><path transform="translate(110.0, 215.0)" d="M 7 18 C 5.900000095367432 18 5.010000228881836 18.89999961853027 5.010000228881836 20 C 5.010000228881836 21.10000038146973 5.900000095367432 22 7 22 C 8.100000381469727 22 9 21.10000038146973 9 20 C 9 18.89999961853027 8.100000381469727 18 7 18 Z M 1 2 L 1 4 L 3 4 L 6.599999904632568 11.59000015258789 L 5.25 14.03999996185303 C 5.090000152587891 14.31999969482422 5 14.64999961853027 5 15 C 5 16.10000038146973 5.900000095367432 17 7 17 L 19 17 L 19 15 L 7.420000076293945 15 C 7.28000020980835 15 7.170000076293945 14.89000034332275 7.170000076293945 14.75 L 7.200000286102295 14.63000011444092 L 8.100000381469727 13 L 15.55000019073486 13 C 16.29999923706055 13 16.96000099182129 12.59000015258789 17.29999923706055 11.97000026702881 L 20.8799991607666 5.480000495910645 C 20.95999908447266 5.340000629425049 21 5.170000553131104 21 5.000000476837158 C 21 4.450000286102295 20.54999923706055 4.000000476837158 20 4.000000476837158 L 5.210000038146973 4.000000476837158 L 4.269999980926514 2.000000476837158 L 1 2.000000476837158 Z M 17 18 C 15.89999961853027 18 15.01000022888184 18.89999961853027 15.01000022888184 20 C 15.01000022888184 21.10000038146973 15.90000057220459 22 17 22 C 18.09999847412109 22 19 21.10000038146973 19 20 C 19 18.89999961853027 18.10000038146973 18 17 18 Z" fill="#ffffff" stroke="none" stroke-width="1" stroke-miterlimit="4" stroke-linecap="butt" /></svg>',
                      //       allowDrawingOutsideViewBox: true,
                      //     ),
                      //   ),
                      // ),
                    ),
                    SizedBox(width: 10),
                    Flexible(
                      flex: 3,
                      child: Container(
                        width: width,
                        padding:
                            EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10.0),
                          color: const Color(0x66ff1e56),
                        ),
                        child: Text(
                          '${product.price} ${AppLocalizations.of(context)!.translate('eg_currency')}',
                          style: TextStyle(
                            fontFamily: 'HS Dream',
                            fontSize: width < 185 ? 12 : 14,
                            color: const Color(0xffffffff),
                            fontWeight: FontWeight.w700,
                            height: 1.75,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  void addToCart() async {
////    List<CartItem> list = userBox.get('card.items')?? [];

    if (cartsBox!.keys.contains('${product.id}')) {
      CartItem card = cartsBox!.get('${product.id}');
      card.count++;
      card.save();

      _showScaffold();
      return;
    }
    cartsBox!.put("${product.id}", CartItem(product: product));
    _showScaffold();
  }

  void _showScaffold() {
    scaffoldState.currentState!.hideCurrentSnackBar();
    scaffoldState.currentState!.showSnackBar(SnackBar(
      content: Text(AppLocalizations.of(context)!.translate('added_to_cart')!),
      backgroundColor: Theme.of(context).primaryColor,
      duration: Duration(seconds: 2),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    ));
  }
}
