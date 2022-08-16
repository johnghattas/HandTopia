import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fluttertestproject/widgets/search_bar.dart';
import 'package:fluttertestproject/constants.dart';
import '../app/craft_page.dart';
import '../components/error_dialog.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';

class CustomAppBar extends StatelessWidget {
  const CustomAppBar({
    Key? key,
    this.scaffoldKey,
  }) : super(key: key);

  final GlobalKey<ScaffoldState>? scaffoldKey;

  @override
  Widget build(BuildContext context) {
    return Container(

      child: Column(
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Row(
                children: [

                  SizedBox(width: 8),
                  InkWell(
                    onTap: () {
                      scaffoldKey!.currentState!.openDrawer();
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                      child: Icon(
                        Icons.menu,
                        color: Theme.of(context).primaryColor,
                        size: 30,
                      ),
                    ),
                  ),

                  IconButton(
                    tooltip: 'search',
                    icon: Icon(Icons.search, color: kPrimaryColor),
                    onPressed: () {
                      showSearch(
                          context: context, delegate: CustomSearchDelegate());
                    },
                  ),

                ],
              ),
              Row(

                children: [
                  InkWell(
                    onTap: () {
                      Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(builder: (context) => CraftPage()),
                          (r) => !r.navigator!.canPop());
                    },
                    child: SvgPicture.asset(
                      'assets/logo.svg',
                      height: 30,
                      width: 30,
                    ),
                  ),
                  SizedBox(width: 16),

                ],
              ),
            ],
          ),
          ValueListenableBuilder(
              valueListenable: Hive.box('user').listenable(),
              builder: (context, dynamic value, child) {
                if ((value.get('app_location') != null && ['/craft', '/productItems'].contains(value.get('app_location'))) &&
                    (value.get('error_in_login') != null &&
                        value.get('error_in_login'))) {
                  Future.delayed(Duration(seconds: 2), () {
                    value.put('error_in_login', false);
                  });
                  return Center(
                      child: ErrorDialogs.errorContainer(
                          context, 'error in login'));
                }
                return Container();
              }),
        ],
      ),
    );
  }
}
