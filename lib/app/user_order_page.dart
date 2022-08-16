import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../blocs/list_order_block.dart';
import '../responses/response.dart';
import '../widgets/app_bar.dart';
import '../widgets/custom_drawer.dart';
import '../widgets/order_item_widget.dart';
import '../components/Order.dart';
import '../Hive/user_model.dart';
import '../api/order_request.dart';
import '../app_localization.dart';
import '../constants.dart';

class UserOrderPage extends StatefulWidget {
  @override
  _UserOrderPageState createState() => _UserOrderPageState();
}

class _UserOrderPageState extends State<UserOrderPage> {
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  OrderApi? _orderApi;
  UserP? user;
  late Box _userBox;

  late ListOrderBlock _block;

  bool _isPressOk = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _userBox = Hive.box('user');
    user = _userBox.get('userData');
    _orderApi = OrderApi();

    _block = ListOrderBlock(_orderApi, user!.token);
  }

  @override
  Widget build(BuildContext context) {
    var local = AppLocalizations.of(context);
    return Scaffold(
        key: _scaffoldKey,
        backgroundColor: kBackground,
        body: SafeArea(
          child: Container(
            child: Column(
              children: [
                CustomAppBar(
                  scaffoldKey: _scaffoldKey,
                ),
                Expanded(
                  child: (user!.tokenAvailable != null && user!.tokenAvailable!)
                      ? RefreshIndicator(

                          onRefresh: () => _block.fetchListOrder(),
                          child: StreamBuilder<Response<List<Order>>>(
                              stream: _block.chuckListStream,
                              builder: (context, snapshot) {
                                if (snapshot.hasError) {

                                  return Container(
                                    width: double.infinity,
                                    height: 200,
                                    child: Center(
                                        child: Text(
                                      local!.translate('error_data')!,
                                      style: kTextStyle,
                                    )),
                                  );
                                }

                                if (snapshot.hasData) {
                                  List<Order>? list = snapshot.data!.data;
                                  ValueListenableBuilder(
                                    valueListenable: _userBox.listenable(),
                                    builder: (context, dynamic value, child) {

                                      if (list!.length == 0 &&
                                          !value
                                              .get('userData')
                                              .tokenAvailable) {
                                        return Container(
                                          width: double.infinity,
                                          height: 200,
                                          child: Center(
                                              child: Text(
                                            local!.translate('no_data')!,
                                            style: kTextStyle,
                                          )),
                                        );
                                      }
                                      return Container();
                                    },
                                  );

                                  switch (snapshot.data!.status) {
                                    case Status.COMPLETED:
                                      return buildSingleChildScrollView(list!);
                                    case Status.LOADING:
                                      return Loading(
                                        loadingMessageKey: "loading2",
                                      );
                                    case Status.ERROR:
                                      return Error(
                                        errorMessage: snapshot.data!.message,
                                        onRetryPressed: () =>
                                            _block.fetchListOrder(),
                                      );

                                    default:
                                      return Container();
                                  }
                                } else {
                                  return Center(
                                      child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ));
                                }
                              }),
                        )
                      : Center(
                          child: Container(
                              width: double.infinity,
                              height: 500,
                              child: Center(
                                  child: Text(
                                local!.translate('sign_to_handy')!,
                                style: TextStyle(color: Colors.white),
                              ))),
                        ),
                )
              ],
            ),
          ),
        ),
        drawer: CustomDrawer(path: '/orders'));
  }

  SingleChildScrollView buildSingleChildScrollView(List<Order> list) {
    return SingleChildScrollView(
      child: Column(
        children: List.generate(
          list.length,
          (index) {
            return Column(
              children: [
                OrderItem(
                  token: user!.token,
                  order: list[index],
                  index: index,
                  removeItemFunction: (int? value) {
                    if (value != null) {


                      // _block.fetchListOrder();
                      _deleteOrder(
                          list[value].code, value, list);
                    }
                  },
                ),
                SizedBox(height: 16),
                index != list.length - 1
                    ? Divider(
                        height: 2,
                        color: Color(0xff707070),
                      )
                    : Container()
              ],
            );
          },
        ),
      ),
    );
  }

  void _deleteOrder(int? code, int index, List<Order> list) async {
    await AwesomeDialog(
            context: this.context,
            dialogType: DialogType.WARNING,
            desc: AppLocalizations.of(context)!.translate("warning_to_delete") ??
                '',
            animType: AnimType.BOTTOMSLIDE,
            title: AppLocalizations.of(context)!.translate("warning"),
            dismissOnTouchOutside: false,
            btnOk: RaisedButton(
              color: Colors.blueAccent,
              child: _isPressOk
                  ? Text(AppLocalizations.of(context)!.translate("loading")!,
                      style: TextStyle(color: Colors.white))
                  : Text(AppLocalizations.of(context)!.translate("ok")!,
                      style: TextStyle(color: Colors.white)),
              onPressed: () async {
                setState(() {
                  _isPressOk = true;
                });
                try {
                  _block.chuckListSink.add(Response.loading("loading after remove"));

                  await _orderApi!.removeOrder(user!.token, code);
                  _isPressOk = false;
                  // setState(() {
                    list.removeAt(index);
                    _block.chuckListSink.add(Response.completed(list));
                  // });
                  // _block.fetchListOrder();
                  Navigator.pop(context);
                } catch (e) {
                  print(e);
                  Navigator.pop(context);
                  _isPressOk = false;
                }
              },
            ),
            btnCancel: RaisedButton(
              color: Colors.red,
              child: Text(
                AppLocalizations.of(context)!.translate("cancel")!,
                style: TextStyle(color: Colors.white),
              ),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            btnOkColor: Colors.black)
        .show();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _block.dispose();
  }
}

class Loading extends StatelessWidget {
  final String? loadingMessageKey;

  const Loading({Key? key, this.loadingMessageKey}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            AppLocalizations.of(context)!.translate(loadingMessageKey)!,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
            ),
          ),
          SizedBox(height: 24),
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          ),
        ],
      ),
    );
  }
}

class Error extends StatelessWidget {
  final String? errorMessage;

  final Function? onRetryPressed;

  const Error({Key? key, this.errorMessage, this.onRetryPressed})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            errorMessage!,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
            ),
          ),
          SizedBox(height: 8),
          RaisedButton(
            color: Colors.white,
            child: Text(AppLocalizations.of(context)!.translate('retry')!, style: TextStyle(color: Colors.black)),
            onPressed: onRetryPressed as void Function()?,
          )
        ],
      ),
    );
  }
}
