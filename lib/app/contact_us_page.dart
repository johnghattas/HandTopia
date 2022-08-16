
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../widgets/app_bar.dart';
import '../widgets/custom_drawer.dart';
import '../app_localization.dart';
import '../constants.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:math' as  math;

class ContactUs extends StatefulWidget {
  @override
  _ContactUsState createState() => _ContactUsState();
}

class _ContactUsState extends State<ContactUs> {
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  String _phone = "+201125821726";

  @override
  Widget build(BuildContext context) {
    AppLocalizations locale = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: kBackground,
      key: _scaffoldKey,
      body: SafeArea(
        child: Column(
          children: [
            CustomAppBar(scaffoldKey: _scaffoldKey,),

            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [

                    ListTile(
                      onTap: goToCall,
                        leading: Transform(transform: locale.locale.languageCode == 'ar'?Matrix4.rotationY(math.pi) : Matrix4.rotationY(0),alignment: Alignment.center,child: Icon(Icons.phone, color: Colors.blueAccent, size: 50,)),
                        title: Text( _phone.substring(2) , style: kTextStyle.copyWith(fontSize: 18),)
                    ),

                    Divider(color: Colors.grey,),
                    SizedBox(height: 40),

                    ListTile(
                      onTap:goToWhatsApp,
                        leading: Image.asset('assets/whatsapp.png', width: 50, height: 50,),
                        title: Text(_phone.substring(2), style: kTextStyle.copyWith(fontSize: 18), )
                    ),

                    Divider(color: Colors.grey,),
                    SizedBox(height: 40),

                    Container(
                      color: Colors.white,
                      child: ListTile(
                          onTap: goToFaceBook,
                          leading: Image.asset('assets/facebook.png', width: 50, height: 50,),
                          title:  Text('HandTopia Page', style: kTextStyle.copyWith(color: Colors.blue, fontSize: 18, decoration: TextDecoration.underline),)
                      ),
                    ),
                    Divider(color: Colors.grey,),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
      drawer: CustomDrawer(path: '/contact_us',),
    );
  }

  void goToFaceBook() async{
    String fbProtocolUrl;
    if (Platform.isIOS) {
      fbProtocolUrl = 'fb://profile/224594322204955';
    } else {
      fbProtocolUrl = 'fb://page/224594322204955';
    }
    String fallbackUrl = 'https://www.facebook.com/HandTopia8';
    try {
      bool launched = await launch(fbProtocolUrl, forceSafariVC: false);

      if (!launched) {
        await launch(fallbackUrl, forceSafariVC: false);
      }
    } catch (e) {
      await launch(fallbackUrl, forceSafariVC: false);
    }

  }

  goToWhatsApp() async{
    var whatsappUrl ="whatsapp://send?phone=$_phone";
    await canLaunch(whatsappUrl)? launch(whatsappUrl):_scaffoldKey.currentState!.showSnackBar(SnackBar(content: Text('you don\'t have installed whats app'),));
  }

  goToCall() async{
    launch('tel://$_phone');
  }
}

