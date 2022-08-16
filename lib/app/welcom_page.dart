import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'craft_page.dart';
import '../auth/loign_page.dart';
import '../constants.dart';
import 'package:hive/hive.dart';
import 'package:page_transition/page_transition.dart';
import '../app_localization.dart';

class WelcomePage extends StatefulWidget {
  @override
  _WelcomePageState createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  int _currentPage = 0;
  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: kBackground,
      body: SafeArea(
        child: Container(
          child: Column(
            children: [
              Expanded(
                flex: 5,
                child: PageView(
                  onPageChanged: (v){
                    setState(() {
                      _currentPage = v;
                    });
                  },
                  children: <Widget>[
                    Container(child: Image.asset('assets/group.png')),
                    Center(child: SecondWidget(width: width, height: height)),
                  ],
                ),
              ),

              Expanded(flex: 1,child: _makeThreeDot())
            ],
          ),
        ),
      ),
    );
  }

  Row _makeThreeDot() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        2,
            (index) => AnimatedContainer(
          duration: Duration(milliseconds: 200),
          child: Container(
            margin: EdgeInsets.only(right: 4),
            width: index == _currentPage? 24 : 14,
            height: 14,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(7),
                color: index == _currentPage ? kButtonColor : Colors.white,


            ),
          ),
        ),
      ),
    );
  }
}

class SecondWidget extends StatelessWidget {
  const SecondWidget({
    Key? key,
    required this.width, this.height,

  }) : super(key: key);

  final double width;
  final double? height;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      primary: false,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          SizedBox(height: 40),
          SvgPicture.asset(
            'assets/logo.svg',
            width: 150,
            height: 150,
          ),
          SizedBox(height: 40),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            height: height! * 0.25,
            child: SingleChildScrollView(
              primary: false,
              child: Text(
                AppLocalizations.of(context)!.translate('about_handy')!,
                style: TextStyle(
                  fontFamily: 'Amiri',
                  fontSize: 18,
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.8,
                  height: 1.6,

                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          SizedBox(height: 60),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                RaisedButton(

                  onPressed: () {
                    Hive.box('user').put('is_first', false);
                    Navigator.pushReplacement(
                        context,
                        PageTransition(
                            child: LoginPage(), type: PageTransitionType.fade));
                  },
                  elevation: 10,
                  child: Container(
                    width: width / 2 - 70,
                    height: 50,
                    child: Align(
                      alignment: Alignment.center,
                      child: Text(
                          AppLocalizations.of(context)!.translate('sign_in')!,
                          style: TextStyle(color: Colors.white, fontSize: width <= 390? 14 :18)),
                    ),
                  ),
                  color: Theme.of(context).primaryColor,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20)),
                ),
                RaisedButton(
                  onPressed: () {
                    Hive.box('user').put('is_first', false);
                    Navigator.pushReplacement(
                        context,
                        PageTransition(
                            child: CraftPage(), type: PageTransitionType.fade));
                  },
                  elevation: 10,
                  child: Container(
                    width: width / 2 - 70,
                    height: 50,
                    child: Align(
                      alignment: Alignment.center,
                      child: Text(
                          AppLocalizations.of(context)!.translate('browse')!,
                          style: TextStyle(color: Colors.white, fontSize: width <= 390? 14 :18)),
                    ),
                  ),
                  color: Theme.of(context).primaryColor,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20)),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
