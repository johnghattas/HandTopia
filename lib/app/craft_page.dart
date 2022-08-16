import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../widgets/craft_widget.dart';
import 'product_items.dart';

import '../widgets/custom_drawer.dart';
import '../constants.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import 'package:page_transition/page_transition.dart';
import '../widgets/app_bar.dart';


class CraftPage extends StatefulWidget {
  const CraftPage({Key? key, this.token}) : super(key: key);

  final String? token;

  @override
  _CraftPageState createState() => _CraftPageState();
}

class _CraftPageState extends State<CraftPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  late Box userBox;

  var _craftsFuture;

  getCrafts() async {
    http.Response response = await http
        .get(Uri.parse('$kUrl/guest/crafts'), headers: {'Accept': 'application/json'});

    Map map = jsonDecode(response.body);

    if (map.containsKey('data')) return map['data'];

    return 'error';
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _craftsFuture = getCrafts();
    userBox = Hive.box('user');
    userBox.put('app_location', '/craft');

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackground,
      key: _scaffoldKey,
      body: NestedScrollView(
        floatHeaderSlivers: true,
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
                SliverList(
                  delegate: SliverChildListDelegate([

                    SafeArea(child: CustomAppBar(scaffoldKey: _scaffoldKey,)),
                  ], ),
                ),
          ];
        },
        body:  Container(

          child: FutureBuilder(
            future: _craftsFuture,
            builder: (context, snapshot) {
              if(snapshot.hasError){
               //

              }
              if (snapshot.hasData) {
                var data = snapshot.data;
                if (data == 'error') {
                 //
                  return Text(
                    'no data founded',
                    style: TextStyle(color: Colors.white),
                  );
                }

                if(data is List<Map>)
                return Container(
                  child: ListView(
                    children: List.generate(data.length , (index) {
                      return Container(
                        margin:
                            EdgeInsets.only(bottom: index != data.length -1? 14 : 0.0),
                        padding: EdgeInsets.symmetric(horizontal: 16.0),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(40),
                          onHover: (value) => print('hover'),
                          onTap: () {
                            Navigator.push(
                                context,
                                PageTransition(
                                    child: ProductItems(
                                      craftId: data[index]['id'],
                                      token: widget.token,
                                    ),
                                    type: PageTransitionType.rightToLeft));
                          },
                          child: CraftWidget(
                            text: data[index]['name'],
                            imageUrl: data[index]['image'],
                          ),
                        ),
                      );
                    }),
                  ),
                );
              }
              return Center(child: CircularProgressIndicator());
            },
          ),
        ),
      ),
      drawer: CustomDrawer(path: '/craft',),
    );
  }


}

