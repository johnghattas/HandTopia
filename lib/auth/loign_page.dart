import 'dart:async';
import 'dart:convert';

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../app/craft_page.dart';
import '../app/sign_up_page.dart';
import '../Hive/user_model.dart';
import '../app_localization.dart';
import '../components/custom_button.dart';
import '../components/error_dialog.dart';
import '../components/google_sign_in.dart';
import '../constants.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import 'package:page_transition/page_transition.dart';

class LoginPage extends StatefulWidget {
  final String path;

  const LoginPage({Key? key, this.path = ''}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  String _email = '';
  String _password = '';

  FirebaseAuth _auth = FirebaseAuth.instance;
  late Box userBox;
  bool _isLoading = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    userBox = Hive.box('user');
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Color(0xFF191919),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Container(
              height: height - 29,
              alignment: Alignment.center,
              padding: EdgeInsets.symmetric(horizontal: 20.0),
              child: SingleChildScrollView(
                primary: false,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    //logo area
                    SvgPicture.asset('assets/logo.svg',
                        height: 150, width: 91.17),

                    SizedBox(height: 20),

                    Text(
                      AppLocalizations.of(context)!.translate('sign_in')!,
                      style: TextStyle(
                        fontFamily: 'HS Dream',
                        fontSize: 40,
                        color: const Color(0xffffffff),
                        fontWeight: FontWeight.w700,
                      ),
                      textAlign: TextAlign.left,
                    ),
                    SizedBox(height: 40),
                    FieldCustom(
                      hintKey: 'email',
                      onchange: (v) {
                        _email = v;
                      },
                    ),
                    SizedBox(height: 14),
                    FieldCustom(
                      hintKey: 'password',
                      onchange: (v) {
                        _password = v;
                      },
                      obscurity: true,
                    ),

                    SizedBox(height: 40),
                    RaisedButton(
                      autofocus: true,
                      onPressed: (_isLoading) ? null : login,
                      elevation: 10,
                      child: Container(
                          width: width,
                          height: 50,
                          child: Align(
                            alignment: Alignment.center,
                            child: Text(
                                AppLocalizations.of(context)!
                                    .translate('sign_in')!,
                                style: TextStyle(
                                    color: Colors.white, fontSize: 18)),
                          )),
                      color: Theme.of(context).primaryColor,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20)),
                    ),

                    Padding(
                      padding: const EdgeInsets.only(top: 8.0, bottom: 4),
                      child: Text('or', style: kTextStyle.copyWith(fontSize: 20, fontWeight: FontWeight.bold),),
                    ),
                    SizedBox(width: 170,child: Divider(height: 1, thickness: 2, color: Colors.blueGrey[900])),
                    SizedBox(height: 8,),


                    MaterialButton(
                      onPressed: _googleLogin,
                      color: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      child: SizedBox(
                        width: 200,
                        height: 60,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SvgPicture.asset('assets/google-icon.svg'),
                            SizedBox(width: 6),
                            Text(
                              'Sign in with Google',
                              style: TextStyle(
                                fontFamily: 'Roboto',
                                fontSize: 14,
                                color: const Color(0xff757575),
                                letterSpacing: 0.3142857112884521,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    SizedBox(height: 20),

                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                            context,
                            PageTransition(
                                child: SignUpPage(),
                                type: PageTransitionType.bottomToTop,
                                curve: Curves.easeIn,
                                duration: Duration(milliseconds: 700)));
                      },
                      child: Text.rich(
                        TextSpan(
                          style: TextStyle(
                            fontFamily: 'Amiri',
                            fontSize: 20,
                            color: const Color(0xffffffff),
                          ),
                          children: [
                            TextSpan(
                              text: AppLocalizations.of(context)!
                                  .translate('didnt_have_acc'),
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            TextSpan(
                              text: AppLocalizations.of(context)!
                                  .translate('create_acc'),
                              style: TextStyle(
                                color: const Color(0xffff1e56),
                                fontWeight: FontWeight.w700,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ],
                        ),
                        textAlign: TextAlign.left,
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void login() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    setState(() {
      _isLoading = true;
    });

    User? user = (await _auth
            .signInWithEmailAndPassword(
                email: _email.trim(), password: _password.trim())
            .catchError((e) {
      setState(() {
        _isLoading = false;
      });

      ErrorDialogs.failedDialog(context, message: e.message);
    }))
        .user;


    //    //loading
    if (user != null) {
      navigate("done");

      //end


      http.Response request =
          await _loginRequest(await user.getIdToken());


      Map map = jsonDecode(request.body);
      if (map.containsKey('error')) {
        //close loading
        _auth.signOut();
        userBox.put('error_in_login', true);
        return;
      }

      _getUser(map['access_token']);
    } else {
      _auth.signOut();
      userBox.put('error_in_login', true);
    }
  }

  void navigate(String message) {
    if (widget.path.isNotEmpty) {
      Navigator.pop(context, message);
    } else
      Navigator.pushReplacement(
          context,
          PageTransition(
              child: CraftPage(), type: PageTransitionType.rightToLeft));
  }

  _getUser(token) async {
    http.Response response = await http.get(Uri.parse('$kUrl/use'), headers: {
      'Authorization': "Bearer $token",
      'Accept': 'application/json'
    });
    Map map2 = jsonDecode(response.body);

    if (map2.containsKey('data')) {
      userBox.put(
          'userData',
          UserP.fromMap(map2['data'])
            ..token = token
            ..tokenAvailable = true);
      userBox.put('is_login', true);
    }
  }

  void _failedLogin({hint = "error_email_password", message}) {
    setState(() {
      _isLoading = false;
    });
    //        _message = map['error'];
    AwesomeDialog(
        context: context,
        dialogType: DialogType.ERROR,
        desc: AppLocalizations.of(context)!.translate(hint) ?? '',
        animType: AnimType.TOPSLIDE,
        title: 'Error',
        btnOk: RaisedButton(
          child: Text('ok'),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        btnOkColor: Colors.black)
      ..show();
  }

  Future<http.Response> _loginRequest(String token) async {
    var request = await http.post(Uri.parse('$kUrl/user/auth/login'), headers: {
      'accept': 'application/json'
    }, body: {
      'email': _email.trim(),
      'password': _password.trim(),
      'token': token
    });
    return request;
  }

  void _googleLogin() async{
    CGoogleSignIn google = CGoogleSignIn();
    User? user = await google.signInGoogle();

    if(user != null){
      navigate('done');

      Map map = await (google.loginRequest(user, 'google') as FutureOr<Map<dynamic, dynamic>>);


      if(map.containsKey('access_token')){
        _getUser(map['access_token']);
      }else{

        CGoogleSignIn.signOut();
        userBox.put('error_in_login', true);
      }
    }
  }
}
