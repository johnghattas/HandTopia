import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertestproject/app/product_items.dart';
import 'package:fluttertestproject/app_localization.dart';
import '../app/product_page.dart';
import '../Hive/fullProduct.dart';
import '../api/search_api.dart';
import '../constants.dart';
import 'package:hive/hive.dart';

class CustomSearchDelegate extends SearchDelegate {
  late Box _userBox;
  List? _searchHistory;
  static const String SEARCH_HISTORY = 'searchHistory';

  ProductsSearch? _productsSearch;
  CustomSearchDelegate() : super(searchFieldStyle: TextStyle(color: kButtonColor.withOpacity(0.5))){
    this._userBox = Hive.box('user');

    if(!_userBox.containsKey(SEARCH_HISTORY)) {
      _userBox.put(SEARCH_HISTORY, []);
    }
     _searchHistory = _userBox.get(SEARCH_HISTORY);
  }


  @override
  ThemeData appBarTheme(BuildContext context) {
    // TODO: implement appBarTheme
    return ThemeData.dark();
  }


  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }


  @override
  Widget buildResults(BuildContext context) {
    if (query.length < 3) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Center(
            child: Text(
              "Search term must be longer than two letters.",
              style:  kTextStyle,
            ),
          )
        ],
      );
    }


    Future.delayed(Duration(milliseconds: 100), (){
      close(context, 'result');
      addToSearch();
      String nQuery = query.replaceAll(' ‏', '%');
      navigateToAllSearch(context, nQuery);
    });

    return Container();
  }

  void navigateToAllSearch(BuildContext context, String nQuery) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => ProductItems(fullProducts: _productsSearch?.products, link: '$kUrl/guest/searchMainProduct?search=$nQuery&',),));
  }

  void addToSearch() {
    if(_searchHistory!.contains(query.trim())) {
      _searchHistory!.remove(query.trim());
    }
      _searchHistory!.add(query.trim());
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    // This method is called everytime the search term changes.
    // If you want to add search suggestions as the user enters their search term, this is the place to do that.
    return Container(
      child: Column(
        children: [
          query.length < 3
              ? Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: InkWell(
                              onTap: () {
                                _searchHistory!.clear();
                                this.query = '';
                              },
                              child: Text(
                                AppLocalizations.of(context)!
                                    .translate('clear_history')!,
                                style: TextStyle(color: kPrimaryColor),
                              )),
                        ),
                        SizedBox(
                          width: 16,
                        ),
                      ],
                    ),
                    _historyBuildListView(),
                  ],
                )
              : Expanded(
                  child: FutureBuilder<ProductsSearch?>(
                    future: SearchApi.getSuggestion(query),
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        return Text(
                          snapshot.error.toString(),
                          style: kTextStyle,
                        );
                      }
                      if (snapshot.hasData) {
                        var data = snapshot.data!;
                        _productsSearch = data;
                        return Column(
                          children: [
                            Column(
                                children: List.generate(
                                    data.craftList.length,
                                    (index) => InkWell(
                                          onTap: () {
                                            String nQuery =
                                                query.replaceAll(' ‏', '%');

                                            Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      ProductItems(
                                                    fullProducts:
                                                        _productsSearch!
                                                            .products,
                                                    link:
                                                        '$kUrl/guest/searchMainProduct?search=$nQuery&craftId=${data.craftList[index].id}&',
                                                  ),
                                                ));
                                          },
                                          child: Padding(
                                            padding:
                                                const EdgeInsets.symmetric(
                                                    horizontal: 16.0,
                                                    vertical: 8),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                data.craftList[index]
                                                            .craftName !=
                                                        null
                                                    ? Text(
                                                        data.craftList[index]
                                                                .craftName! +
                                                            ' ( ${data.craftList[index].count} )',
                                                        style: kTextStyle
                                                            .copyWith(
                                                                fontSize: 16,
                                                                color:
                                                                    kButtonColor),
                                                      )
                                                    : Container(),
                                              ],
                                            ),
                                          ),
                                        ))),
                            Expanded(

                              child: ListView.builder(
                                  shrinkWrap: true,
                                  primary: false,
                                  scrollDirection: Axis.vertical,
                                  itemCount: data.products!.length,
                                  itemBuilder: (context, index) {
                                    FullProduct product = data.products![index];
                                    return Hero(
                                      tag: product.images![0]!,
                                      child: ListTile(
                                        onTap: () {
                                          close(context, null);
                                          Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    ProductPage(
                                                        product: product),
                                              ));
                                        },
                                        leading: Container(
                                          height: 80,
                                          width: 80,
                                          decoration: BoxDecoration(
                                              image: DecorationImage(
                                                  image:
                                                      CachedNetworkImageProvider(
                                                          product.images![0]!))),
                                        ),
                                        title: Text(
                                          product.title!,
                                          style: kTextStyle,
                                        ),
                                        subtitle: Text(
                                          product.price!.toStringAsFixed(2),
                                          style: kTextStyle,
                                        ),
                                      ),
                                    );
                                  }),
                            ),
                          ],
                        );
                      } else
                        return Container();
                    },
                  ),
                ),
        ],
      ),
    );
  }

  Widget _historyBuildListView() {

    if (_searchHistory!.length > 0)
      return ListView.builder(
        shrinkWrap: true,
        reverse: true,
        itemBuilder: (context, index) {
          return ListTile(
            onTap: () {
              navigateToAllSearch(context, _searchHistory![index]);
            },
              leading: Text(
            _searchHistory![index],
            style: kTextStyle.copyWith(fontSize: 16),
          ),
            trailing: IconButton(icon: Icon(Icons.arrow_upward, color: Colors.grey, size: 20,), onPressed: (){
              query = _searchHistory![index];
            },splashRadius: 16.0,),
          );
        },
        itemCount: _searchHistory!.length,
      );
    else
      return Container();
  }
}