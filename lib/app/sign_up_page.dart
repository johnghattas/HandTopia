import 'dart:convert';

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'craft_page.dart';
import '../widgets/cust_buton.dart';
import '../Hive/user_model.dart';
import '../components/custom_button.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import 'package:page_transition/page_transition.dart';

import '../app_localization.dart';
import '../constants.dart';

class SignUpPage extends StatefulWidget {
  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late FirebaseAuth _auth;
  late Box userBox;

  String _firstName = '';
  String _lastName = '';
  String _email = '';
  String _password = '';
  String _confirmPassword = '';

  bool _isLoading = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _auth = FirebaseAuth.instance;
    userBox = Hive.box('user');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackground,
      body: SingleChildScrollView(
        child: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  //logo area
                  SvgPicture.asset('assets/logo.svg',
                      height: 150, width: 91.17),

                  SizedBox(height: 20),

                  Text(
                    AppLocalizations.of(context)!.translate('sign_up')!,
                    style: TextStyle(
                      fontFamily: 'HS Dream',
                      fontSize: 28,
                      color: const Color(0xffffffff),
                      fontWeight: FontWeight.w700,
                    ),
                    textAlign: TextAlign.left,
                  ),
                  SizedBox(height: 20),

                  Form(
                    key: _formKey,
                    child: Column(
                      children: <Widget>[
                        FieldCustom(
                          hintKey: 'first_name',
                          onchange: (value) {
                            _firstName = value;
                          },
                        ),
                        SizedBox(height: 10),
                        FieldCustom(
                          hintKey: 'last_name',
                          onchange: (value) {
                            _lastName = value;
                          },
                        ),
                        SizedBox(height: 10),
                        FieldCustom(
                          hintKey: 'email',
                          onchange: (value) {
                            _email = value;
                          },
                        ),
                        SizedBox(height: 10),
                        FieldCustom(
                          hintKey: 'password',
                          onchange: (value) {
                            _password = value;
                          },
                          obscurity: true,
                        ),
                        SizedBox(height: 10),
                        FieldCustom(
                          hintKey: 'confirm_password',
                          onchange: (value) {
                            _confirmPassword = value;
                          },
                          obscurity: true,
                          onValidate: (v){
                            if(v != _password){
                              return 'didn"t match';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 40),
                        CustomButton(
                          hintKey: 'sign_up',
                          function: _isLoading ? null : signUp,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 20),

                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Text.rich(
                      TextSpan(
                        style: TextStyle(
                          fontFamily: 'Amiri',
                          fontSize: 18,
                          color: const Color(0xffffffff),
                        ),
                        children: [
                          TextSpan(
                            text: AppLocalizations.of(context)!
                                .translate('did_have_acc'),
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          TextSpan(
                            text:
                                AppLocalizations.of(context)!.translate('sign_in'),
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
    );
  }



  signUp() async {
    if (!_formKey.currentState!.validate()) {
      if (_password != _confirmPassword)
        _failedRegister(hint: 'password_isnt_match');
      return;
    }
    setState(() {
      _isLoading = true;
    });

    User? user = (await _auth
            .createUserWithEmailAndPassword(
                email: _email.trim(), password: _password.trim())
            .catchError((e) {
              setState(() {
                _isLoading = false;
              });
      _failedRegister(message: e.message);
    }))
        ?.user;


    if (user != null) {

      Navigator.pop(context);
      Navigator.pushReplacement(
          context,
          PageTransition(
              child: CraftPage(), type: PageTransitionType.rightToLeft));


      http.Response request =
          await _registerRequest(await user.getIdToken());



      Map map = jsonDecode(request.body);

      if (map.containsKey('error') || map.containsKey('message')) {

        userBox.put("error_in_signup", true);
        _auth.currentUser!.delete();
//        _failedRegister();
        return;
      }

      if (map.containsKey('access_token')) {
        userBox.put("error_in_signup", false);
        userBox.put(
          'userData',
          UserP(
              email: _email.trim(),
              name: _firstName + " " + _lastName,
              token: map['access_token'])
            ..tokenAvailable = true,
        );


      }
    } else
      setState(() {
        _isLoading = false;
      });
  }

  void _failedRegister({hint = "unexpected_error", message}) {
    setState(() {
      _isLoading = false;
    });
    //        _message = map['error'];
    AwesomeDialog(
        context: context,
        dialogType: DialogType.ERROR,
        desc: message != null
            ? message
            : AppLocalizations.of(context)!.translate(hint) ?? '',
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

  _registerRequest(String token) async {

    var request = await http.post(Uri.parse('$kUrl/user/auth/register'), headers: {
      'accept': 'application/json'
    }, body: {
      'password': _password.trim(),
      'password_confirmation': _confirmPassword,
      'first_name': _firstName,
      'last_name': _lastName,
      'method': 'email and password',
      'token': token
    });
    return request;
  }
}
