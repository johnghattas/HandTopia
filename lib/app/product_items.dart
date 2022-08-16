import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../Hive/fullProduct.dart';
import '../app/product_page.dart';
import '../widgets/app_bar.dart';
import '../widgets/cart_item.dart';
import '../widgets/custom_drawer.dart';
import '../widgets/product_icard_item.dart';
import '../components/product.dart';
import '../constants.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import 'package:pagination_view/pagination_view.dart';


class ProductItems extends StatefulWidget {
  final int? craftId;
  final String? token;
  final String? link;
  final List<FullProduct>? fullProducts;

  const ProductItems({Key? key, this.craftId, this.token, this.link, this.fullProducts}) : super(key: key);
  @override
  _ProductItemsState createState() => _ProductItemsState();
}

class _ProductItemsState extends State<ProductItems> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  int page= -1;
  late PaginationViewType paginationViewType;
  GlobalKey<PaginationViewState>? key;
  ScrollController scroll = ScrollController();

  Box? cartBox;
  late Box userBox;
  int? _lastPage;

  String? _link;

  bool _isFirst = true;


  Future<List<Product>> getProductsOfCrafts(int offset) async {

    page++;
   //

    if(widget.fullProducts != null && page == 0 && _isFirst) {
      _isFirst = false;
     //
      return widget.fullProducts!.cast<Product>();

    }

   //




    if (_lastPage != null && page >= _lastPage! || (widget.fullProducts != null && widget.link != null && widget.fullProducts!.length < 20)) {
      return [];
    }

    http.Response response = await http.get(Uri.parse('${_link}page=${page+1}'),
        headers: {'Accept': "application/json"}).catchError((e) => 'error');


    Map map = jsonDecode(response.body);
    List<Product> productList = [];
    if (map.containsKey('data')) {

      var data = widget.link == null ?map['data'] : map['data']['product'];

      _lastPage = data['last_page'];
      List list = data['data'];


      productList = List<Product>.from(list.map((m) => Product.fromMap(m)));

    }

    return productList;
  }

  @override
  void initState() {
    page = -1;
    paginationViewType = PaginationViewType.gridView;
    key = GlobalKey<PaginationViewState>();

    super.initState();
    _link = widget.link ?? '$kUrl/guest/products/${widget.craftId}?';
    cartBox = Hive.box<CartItem>('carts');
    userBox = Hive.box('user');
    userBox.put('app_location', '/productItems');
  }

  @override
  Widget build(BuildContext context) {
    Size _size = MediaQuery.of(context).size;
    var orientation = MediaQuery.of(context).orientation;
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: kBackground,
      body: SafeArea(
        child: Column(
          children: <Widget>[
            CustomAppBar(
              scaffoldKey: _scaffoldKey,
            ),

            Expanded(
              child: PaginationView<Product>(

                onError: (dynamic error) => Center(
                  child: Text('Some error occured', style: kTextStyle,),
                ),
                onEmpty: Center(
                  child: Text('Sorry! This is empty', style: kTextStyle,),
                ),
                bottomLoader: Center(
                  child: CircularProgressIndicator(),
                ),
                initialLoader: Center(
                  child: CircularProgressIndicator(),
                ),
                key: key,
                pageFetch: getProductsOfCrafts,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount:
                        (orientation == Orientation.portrait) ? 2 : 3,
                    childAspectRatio: (orientation == Orientation.portrait)
                        ? (_size.width / 2 - 20) / 240
                        : (_size.width / 3 - 30) / 240),
                itemBuilder: (context, product, index) => InkWell(
                  borderRadius: BorderRadius.circular(30),
                  splashColor: Colors.orangeAccent.withOpacity(.26),
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ProductPage(product: product),
                        )
                    );
                  },
                  child: ProductCardItem(
                    width: (orientation == Orientation.portrait)
                        ? (_size.width / 2 - 20)
                        : (_size.width / 3 - 20),
                    product: product,
                    cartsBox: cartBox,
                    context: context,
                    scaffoldState: _scaffoldKey,
                  ),
                ),
                // pageRefresh: pageRefresh,
                pullToRefresh: true,
                shrinkWrap: true,
                paginationViewType: paginationViewType,
              ),
            )

          ],
        ),
      ),
      drawer: CustomDrawer(path: '/products',),
    );
  }

  Future<List<Product>> pageRefresh(int currentListSize) {
    page = -1;
    return getProductsOfCrafts(currentListSize);
  }

}
