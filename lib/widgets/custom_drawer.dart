import 'dart:convert';

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertestproject/pathes.dart';
import '../app/cart_page.dart';
import '../app/contact_us_page.dart';
import '../app/craft_page.dart';
import '../app/uesr_profile_page.dart';
import '../app/user_order_page.dart';
import '../auth/loign_page.dart';
import '../Hive/user_model.dart';
import '../components/error_dialog.dart';
import '../components/google_sign_in.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import 'package:page_transition/page_transition.dart';

import '../app_localization.dart';
import '../constants.dart';
import 'package:hive_flutter/hive_flutter.dart';

class CustomDrawer extends StatefulWidget {
  final String path;

  const CustomDrawer({Key? key, this.path = ''}) : super(key: key);

  @override
  _CustomDrawerState createState() => _CustomDrawerState();
}

class _CustomDrawerState extends State<CustomDrawer> {
  late Box userBox;


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    userBox = Hive.box('user');
    Future.delayed(
        Duration(seconds: 1), () => userBox.put("error_in_signup", false));
  }

  @override
  Widget build(BuildContext context) {
    AppLocalizations? _local = AppLocalizations.of(context);
    bool isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;
    double height = MediaQuery.of(context).size.height;
    return Drawer(
      child: ValueListenableBuilder(
        valueListenable: userBox.listenable(),
        builder: (context, dynamic value, child) {

          if (value.get('userData') == null) {
            userBox.put('userData', UserP());
          }
          UserP user = value.get('userData');

          return Stack(
            children: [

              Container(
                color: Colors.black,
                child: ListView(
                  children: <Widget>[
                    (value.get('error_in_signup') != null &&
                            value.get('error_in_signup'))
                        ? ErrorDialogs.errorContainer(context, 'error when sign up')
                        : Container(),
                    Container(
                      padding:
                          EdgeInsets.only(top: 50, left: 8, right: 8, bottom: 8),
//                   color: Color(0xff31343E),
                      color: Colors.black,
                      child: Column(
                        children: <Widget>[
                          ClipRRect(
                            borderRadius: BorderRadius.circular(100.0),
                            child: user.image != null? Image(
                               image: CachedNetworkImageProvider(user.image!),
                              width: 80,
                              height: 80,
                              fit: BoxFit.cover,
                            ): Image.asset("assets/default_profile.png", height: 80, width: 80, fit: BoxFit.cover,),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          (user.tokenAvailable ?? false)
                              ? RichText(
                                  textAlign: TextAlign.center,
                                  text: TextSpan(children: [
                                    TextSpan(
                                      text: "${user.name ?? "NO Name"}\n",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontFamily: 'Montserrat',
                                        color: Colors.white,
                                        fontSize: 16,
                                      ),
                                    ),
                                    TextSpan(
                                      text: "${user.email ?? "NO Email"}",
                                      style: TextStyle(
                                          fontFamily: 'Montserrat',
                                          color: Colors.white,
                                          height: 1.7),
                                    ),
                                  ]),
                                )
                              : Text(
                                  _local!.translate('sign_to_handy')!,
                                  style: kTextStyle.copyWith(fontSize: 16),
                                ),
                        ],
                      ),
                    ),
                    Divider(height: 1, thickness: 1, color: Colors.white),
                    Container(
                      color: Colors.black,
                      height: (isPortrait)? height * 0.5 : null,
                      margin: EdgeInsets.only(top: 20),
                      child: Column(
                        children: <Widget>[
                          ListTile(
                            onTap: () {
                              if(widget.path == "/craft"){
                                Navigator.pop(context);
                                return;
                              }
                              Navigator.pushAndRemoveUntil(
                                  context,
                                  MaterialPageRoute(builder: (context) => CraftPage()),
                                      (r) => !r.navigator!.canPop());
                            },
                            title: Text(
                              _local!.translate('main_page')!,
                              style: TextStyle(
                                fontFamily: 'HS Dream',
                                fontSize: 20,
                                color: const Color(0xffffffff),
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          ListTile(
                            onTap: () {
                              if(widget.path == kProfilePath){
                                Navigator.pop(context);
                              }
                              Navigator.pop(context);
                              Navigator.push(context, PageTransition(child: ProfilePage(), type: PageTransitionType.rightToLeft));
                            },
                            title: Text(
                              _local.translate('my_acc')!,
                              style: TextStyle(
                                fontFamily: 'HS Dream',
                                fontSize: 20,
                                color: const Color(0xffffffff),
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          ListTile(
                            onTap: navigateToCart,
                            title: Text(
                              _local.translate('cart_text')!,
                              style: TextStyle(
                                fontFamily: 'HS Dream',
                                fontSize: 20,
                                color: const Color(0xffffffff),
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          ListTile(
                            onTap: () {


                              if(widget.path == kOrderPath){
                                Navigator.pop(context);
                              }
                              navigate(UserOrderPage());
                            },
                            title: Text(
                              _local.translate('my_orders')!,
                              style: TextStyle(
                                fontFamily: 'HS Dream',
                                fontSize: 20,
                                color: const Color(0xffffffff),
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          user.tokenAvailable ?? false
                              ? ListTile(
                                  onTap: signOut,
                                  title: Text(
                                    _local.translate('sign_out')!,
                                    style: TextStyle(
                                      fontFamily: 'HS Dream',
                                      fontSize: 20,
                                      color: const Color(0xffffffff),
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                )
                              : ListTile(

                                  onTap: _signIn,
                                  title: Text(
                                    _local.translate('sign_in')!,
                                    style: TextStyle(
                                      fontFamily: 'HS Dream',
                                      fontSize: 20,
                                      color: const Color(0xffffffff),
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),

                        ],
                      ),
                    ),
                    Divider(height: 1, thickness: 1, color: Colors.white),

                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4.0),
                      child: ListTile(
                        onTap: (){
                          navigate(ContactUs());
                        },
                          title: Text(
                            _local.translate('contact_us')!,
                            style: TextStyle(
                              fontFamily: 'HS Dream',
                              fontSize: 20,
                              color: const Color(0xffc40018),
                              fontWeight: FontWeight.w700,
                            ),
                          ),

                          trailing: Icon(Icons.phone, color: Colors.red, size: 30,)
                      )
                    ),
                  ],
                ),
              ),
              Positioned(
                top: 32,
                left: 32,
                child: DropdownButton(
                  value: _local.locale.countryCode == 'US'?0: 1,
                  icon: Container(),
                  underline: Container(),
                  selectedItemBuilder: (context) => [
                  Text('🇺🇸', style: TextStyle(fontSize: 40),),
                  Text('🇪🇬', style: TextStyle(fontSize: 40),),
                ],
                  items:
                [
                  DropdownMenuItem(child: Text('English'), value: 0,),
                  DropdownMenuItem(child: Text('Arabic'), value: 1,)
                ]
                  , onChanged: (dynamic v){

//                    setState(() {
//                      _indexFlag = v;
//                    });

                    switch(v) {
                      case 0:
                        userBox.putAll({'language': 'en', 'country': 'US'});
                        _local.load();

                        break;
                      case 1:
                        userBox.putAll({'language': 'ar', 'country': 'EG'});
                        _local.load();
                        break;
                    }
                  },),
              ),
            ],
          );
        },
      ),
    );
  }

  navigateToCart() {
    if(widget.path == kCartPath){
      Navigator.pop(context);
    }
    Navigator.pop(context);
    Navigator.push(
      context,
      PageTransition(
          child: CartPage(),
          type: PageTransitionType.bottomToTop,
          curve: Curves.easeOut),
    );
  }

  signOut() async {
    CGoogleSignIn.signOut();


    String? token = userBox.get('userData').token;
    http.Response response = await http.post(Uri.parse('$kUrl/user/auth/logout'),
        headers: {
          'Authorization': "Bearer $token",
          'Accept': 'application/json'
        });

    Map map = jsonDecode(response.body);

    if (map.containsKey('data')) {
      userBox.putAll(
          {'userData': UserP()..tokenAvailable = false, 'is_login': false});
      AwesomeDialog(
          context: context,
          dialogType: DialogType.NO_HEADER,
          desc: AppLocalizations.of(context)!.translate("logout_message") ?? '',
          animType: AnimType.TOPSLIDE,
          title: AppLocalizations.of(context)!.translate("sign_out"),
          btnOk: RaisedButton(
            color: kButtonColor,
            child: Text(AppLocalizations.of(context)!.translate('ok')!, style: kTextStyle,),
            onPressed: () {
              Navigator.pop(this.context);
              Navigator.pop(this.context);
            },
          ),
          btnOkColor: Colors.black)
        ..show();
    }
  }


  _signIn() async {
//    var user = (await _auth.currentUser());
////    if (user != null) {
////
////      return;
////    }
    Navigator.pop(context);
    Navigator.push(
      context,
      PageTransition(
          child: LoginPage(path: '/craft'), type: PageTransitionType.bottomToTop),
    );
  }

  void navigate( Widget userOrderPage) {
    Navigator.pop(context);

    Navigator.push(
        context,
        PageTransition(
            child: userOrderPage,
            type: PageTransitionType.topToBottom,
            curve: Curves.easeOut));
  }
}
