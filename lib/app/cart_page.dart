import 'dart:async';
import 'dart:convert';

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import '../auth/loign_page.dart';
import '../widgets/app_bar.dart';
import '../widgets/cart_item.dart';
import '../widgets/cart_item_child_widget.dart';
import '../widgets/custom_drawer.dart';
import '../Hive/user_model.dart';
import '../api/auth_requests.dart';
import '../components/custom_button.dart';
import '../components/error_dialog.dart';
import '../constants.dart';
import '../models/confirm_model.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:page_transition/page_transition.dart';

import '../app_localization.dart';

class CartPage extends StatefulWidget {
  @override
  _CartPageState createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  late  Box cartBox, userBox;
  double _width = 400.0;

  bool _isLoading = false;

  int _index = 0;

  bool? _isAvailableToken;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    cartBox = Hive.box<CartItem>('carts');
    userBox = Hive.box('user');
  }

  @override
  Widget build(BuildContext context) {
    Orientation orientation = MediaQuery.of(context).orientation;

    if (orientation == Orientation.portrait)
      _width = MediaQuery.of(context).size.width;

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: kBackground,
      body: SingleChildScrollView(
        primary: true,
        child: SafeArea(
          child: Column(
            children: <Widget>[
              CustomAppBar(scaffoldKey: _scaffoldKey,),
              Container(
                child: ValueListenableBuilder(
                  valueListenable: cartBox.listenable(),
                  builder: (context, dynamic value, child) {
                    if (value.isEmpty) {
                      return Container(
                        width: double.infinity,
                        height: 200,
                        color: Colors.red.withOpacity(0.1),
                        child: Center(child: Text('the Cart is Empty', style: kTextStyle,)),
                      );
                    }


                    _isAvailableToken = value.get('userData') != null ? value.get('userData').tokenAvailable : false;

                    return Column(
                      children: <Widget>[
                    (value.get('error_in_login') != null &&
                        value.get('error_in_login'))
                    ? ErrorDialogs.errorContainer(
                    context, 'error when sign in')
                        : Container(),

                        ListView.builder(
                          primary: false,
                          shrinkWrap: true,
                          itemBuilder: (context, index) {
                            CartItem? cartItem = value.getAt(index);
                            if(cartItem == null)
                              return Container();
                            return CartItemChildWidget(
                              cartItem: cartItem,
                              context: context,
                            );
                          },
                          itemCount: value.keys.length,
                        ),
                      ],
                    );
                  },
                ),
              ),
              SizedBox(height: 40),
              RaisedButton(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                color: Theme.of(context).primaryColor,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 3),
                    child: Text(
                        AppLocalizations.of(context)!.translate('apply_order')!,
                        style: TextStyle(color: Colors.white)),
                  ),
                  onPressed:
                    (cartBox.keys.length == 0) ? null : () =>applyOrder(context, _width),
                      ),
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
      drawer: CustomDrawer(path: '/cart'),
    );
  }

  showDialogBtn(context, width) {
    showDialog(
      context: context,
      builder: (c) {
        return StatefulBuilder(
          builder: (context, setState) => AlertDialog(
            elevation: 50.0,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            buttonPadding: EdgeInsets.zero,
            scrollable: false,
            backgroundColor: kFillColor,
            title: Center(
                child: _makeThreeDot()),
            content: Container(
              height: 552,
              width: double.infinity,
              child: Container(
                width: width,
                child: PageView(
                  scrollDirection: Axis.horizontal,
                  onPageChanged: (v) {
                    return;
                  },
                  pageSnapping: true,
                  allowImplicitScrolling: true,
                  children: [
                    confirmWidgets(width * 0.7, setState, context)[_index]
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  applyOrder(BuildContext context, width) async {
    if(cartBox.length == 0){
      return;
    }
    UserP user = userBox.get('userData');
    if (!(user.tokenAvailable ?? false)) {
      _dialogLoginFail();
      return;
    }
    else if (cartBox.length == 0) {

      return;
    }
    showDialogBtn(context, width);
  }


  Future _addProduct(UserP user, CartItem item, int? orderCode) async {
    http.Response response =
        await http.post(Uri.parse('$kUrl/user/buy/product'), headers: {
      'Accept': "application/json",
      'Authorization': 'Bearer ${user.token}'
    }, body: {
      'product_id': item.product!.id.toString(),
      'quantity': item.count.toString(),
      if (orderCode != null) "order_code": orderCode.toString()
    });

    return response.body;
  }

  void _dialogLoginFail() {
    AwesomeDialog(
      context: context,
      dialogType: DialogType.NO_HEADER,
      desc: AppLocalizations.of(context)!.translate("alert_to_sign_in") ?? '',
      animType: AnimType.TOPSLIDE,
      title: AppLocalizations.of(context)!.translate('warning'),
      dismissOnTouchOutside: false,
      btnOk: RaisedButton(
        color: Colors.blueAccent,
        child: Text(AppLocalizations.of(context)!.translate('sign_in')!,
            style: TextStyle(color: Colors.white)),
        onPressed: () async {
          Navigator.pop(context);
          var message = await Navigator.push(
            context,
            PageTransition(
                child: LoginPage(path: '/cart'),
                type: PageTransitionType.bottomToTop,
                curve: Curves.ease,
                duration: Duration(seconds: 1)),
          );

          if (message == 'done'){
            //waiting
              await Future.delayed(Duration(seconds: 1));

              //stop waiting
              showDialogBtn(context, _width);

          }
        },
      ),
      btnCancel: RaisedButton(
        color: Colors.redAccent,
        child: Text(AppLocalizations.of(context)!.translate('cancel')!,
            style: TextStyle(color: Colors.white)),
        onPressed: () {
          Navigator.pop(context);
        },
      ),
    )..show();
  }


  customDialog() {
    showDialog(
      context: context,
      builder:(context) =>  Scaffold(
        body: Container(
          height: 200,
          width: 200,
          child: Text('hello'),
        ),
      ),
    );
  }

  List<Widget> confirmWidgets(
      double? width, var setState, BuildContext context) {
    var title = 'الاسم ثلاثي:';
    return [
      firstPage(context, setState),
      secondPage(context, setState, title, width),
      thirdPage(),
    ];
  }

  Center thirdPage() {
    
    return Center(
      child: Column(
        children: [
          Expanded(
            flex: 4,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset('assets/group.png'),
                Text(
                  AppLocalizations.of(context)!.translate('confirm_order_dialog')??"",
                  style: TextStyle(
                    fontFamily: 'HS Dream',
                    fontSize: 20,
                    color: const Color(0xffffffff),
                    fontWeight: FontWeight.w700,
                    height: 2.1,
                  ),

                ),

              ],
              )
            ),
          ),

          RaisedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Text(
                AppLocalizations.of(context)!.translate('done')??'',
                style: TextStyle(
                  fontFamily: 'HS Dream',
                  fontSize: 20,
                  color: const Color(0xffffffff),
                  fontWeight: FontWeight.w300,
                ),
              ),
            ),
            color: kButtonColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),

        ],
      ),
    );
  }

  Container secondPage(BuildContext context, setState, String title, double? width) {
    var local = AppLocalizations.of(context)!;
    return Container(
      child: Column(
        children: [
          Expanded(
            flex: 6,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  _titleAndContent(local.translate('name_2')!+':', _confirm.name, width),
                  SizedBox(height: 40),
                  _titleAndContent(local.translate('phone')!+':', _confirm.phone , width),
                  SizedBox(height: 40),
                  _titleAndContent(
                      (local.translate('address_title') ??'') + ":", _confirm.address, width),
                  SizedBox(height: 40),
                  Container(
                    child: Column(
                      children: [
                        Container(
                          width: double.infinity,
                          child: Text(
                            local.translate('notes')!,
                            style: TextStyle(
                              fontFamily: 'HS Dream',
                              fontSize: 17,
                              color: const Color(0xffff6107),
                            ),
                            textAlign: TextAlign.right,
                          ),
                        ),
                        FieldCustom(
                          initialValue: _confirm.notes,
                          height: 8 * 25.0,
                          minLine: 6,
                          maxLine: 6,
                          readOnly: true,
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          Expanded(
            flex: 1,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                RaisedButton(
                  onPressed: () => _pressDone(setState),
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    child: Text(
                      _isLoading? local.translate('loading')! : local.translate('done')??'',
                      style: TextStyle(
                        fontFamily: 'HS Dream',
                        fontSize: 20,
                        color: const Color(0xffffffff),
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                  ),
                  color: Theme.of(context).primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                RaisedButton(
                  onPressed: () {
                      setState(() {
                        _index = 0;
                      });
                  },
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    child: Text(
                      local.translate('back')??'',
                      style: TextStyle(
                        fontFamily: 'HS Dream',
                        fontSize: 20,
                        color: const Color(0xffffffff),
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                  ),
                  color: kButtonColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  ListTile _titleAndContent(String title, String? data, double? width) {

    return ListTile(
      leading:  Text(
          title,
          style: TextStyle(
            fontFamily: 'HS Dream',
            fontSize: 18,
            color: const Color(0xffff6107),
            fontWeight: FontWeight.w500,
          ),
        ),

        title: Text(
          data??'',
          style: TextStyle(color: Colors.white, fontSize: 16, height: 1.2),
          softWrap: true,
        ),

    );
  }

  double getRenderSize(String title, double fontSize) {
    RenderParagraph renderParagraph = RenderParagraph(
      TextSpan(
        text: title,
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.w500,
        ),
      ),
      maxLines: 1,
      textDirection: AppLocalizations.of(context)!.locale.languageCode == "Ar"
          ? TextDirection.rtl
          : TextDirection.ltr,
    );

    return renderParagraph.getMinIntrinsicWidth(fontSize).ceilToDouble();
  }

Confirm _confirm = Confirm();

  Container firstPage(context, setState) {
    GlobalKey<FormState> formKey = GlobalKey<FormState>();
    var local = AppLocalizations.of(context)!;

    return Container(
      child: Form(
        key: formKey,
        child: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                child: Column(
                  children: [
                    Container(
                      width: double.infinity,
                      child: Text(
                        local.translate('name_2')!,
                        style: TextStyle(
                          fontFamily: 'HS Dream',
                          fontSize: 17,
                          color: const Color(0xffff6107),
                        ),
                      ),
                    ),
                    FieldCustom(
                      onSave: (v) => _confirm.name = v,
                      height: 45,
                      initialValue: _confirm.name??'',
                      isSecondName: true
                    )
                  ],
                ),
              ),
              Container(
                child: Column(
                  children: [
                    Container(
                      width: double.infinity,
                      child: Text(
                        local.translate('phone')!,
                        style: TextStyle(
                          fontFamily: 'HS Dream',
                          fontSize: 17,
                          color: const Color(0xffff6107),
                        ),
                      ),
                    ),
                    FieldCustom(
                      onSave: (v) => _confirm.phone = v,
                      height: 45,
                      isNumber: true,
                      initialValue: _confirm.phone??'',
                    )
                  ],
                ),
              ),
              Container(
                child: Column(
                  children: [
                    Container(
                      width: double.infinity,
                      child: Text(
                        local.translate('address')!,
                        style: TextStyle(
                          fontFamily: 'HS Dream',
                          fontSize: 17,
                          color: const Color(0xffff6107),
                        ),
                      ),
                    ),
                    FieldCustom(
                      initialValue: _confirm.address??'',
                      onSave: (v) => _confirm.address = v,
                      height: 3*30.0,
                      minLine: 3,
                      maxLine: 3,
                    )
                  ],
                ),
              ),
              Container(
                child: Column(
                  children: [
                    Container(
                      width: double.infinity,
                      child: Text(
                        local.translate('notes')!,
                        style: TextStyle(
                          fontFamily: 'HS Dream',
                          fontSize: 17,
                          color: const Color(0xffff6107),
                        ),
                      ),
                    ),
                    FieldCustom(
                      initialValue: _confirm.notes??'',
                      onSave: (v) => _confirm.notes = v,
                      validate: false,
                      height: 8 * 20.0,
                      minLine: 8,
                      maxLine: 8,
                    )
                  ],
                ),
              ),

              Align(
                alignment: Alignment.bottomRight,
                child: RaisedButton(
                  onPressed: () {
                    formKey.currentState!.save();
                    if(!formKey.currentState!.validate()){
                      return;
                    }
                    setState(() {
                      _index = 1;
                    });
                  },
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    child: Text(
                      local.translate('confirm') ?? '',
                      style: TextStyle(
                        fontFamily: 'HS Dream',
                        fontSize: 20,
                        color: const Color(0xffffffff),
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                  ),
                  color: Theme.of(context).primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }



  _makeThreeDot() {
    return Row(
      children: List.generate(
        3,
        (index) => AnimatedContainer(
          duration: Duration(milliseconds: 200),
          child: Container(
            margin: EdgeInsets.only(right: 4),
            width: index == _index? 24 : 14,
            height: 14,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(7),
              color: index == _index ? kButtonColor : Colors.transparent,
              border: Border.all(width: 0.5, color: Colors.white)

            ),
          ),
        ),
      ),
    );
  }

  void _pressDone(setState) async {
    setState(() {
      _isLoading = true;
    });

    List<CartItem> list = cartBox.values.toList() as List<CartItem>;


    for (var item in list) {
      Map map = jsonDecode(await (_addProduct(userBox.get('userData'), item, _confirm.orderCode) as FutureOr<String>));

      if (map.containsKey('error')) {
        //todo item not added
//        _scaffoldKey.currentState.showSnackBar(SnackBar(content: Text(),));
      } else if (map.containsKey('message') &&
          map['message'].toString().toLowerCase().contains('unauthenticated')) {
       // print.
        return;
      } else if (map.containsKey('data')) {
        //the item is added
        if (_confirm.orderCode == null) {
          _confirm.orderCode = map['data']['order_code'];
        }
        item.delete();
      }

    }
    //
    setState(() {
      _index = 2;
    });

    await UserApi().modifyUserNotes(userBox.get('userData').token, _confirm);
  }
}
