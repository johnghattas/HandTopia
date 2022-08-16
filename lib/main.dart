import 'dart:convert';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'app/craft_page.dart';
import 'widgets/cart_item.dart';
import 'Hive/user_model.dart';
import 'constants.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:http/http.dart' as http;
import 'app/welcom_page.dart';
import 'app_localization.dart';
import 'components/product.dart';
import 'package:hive_flutter/hive_flutter.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  var directory = await getApplicationDocumentsDirectory();
  Hive..init(directory.path)..registerAdapter(CartItemAdapter())..registerAdapter(ProductAdapter())..registerAdapter(UserAdapter());
  var user = await Hive.openBox('user');
  Hive.openBox<CartItem>('carts');

  runApp(ValueListenableBuilder<Box>(
    valueListenable: user.listenable(),
    builder: (context, value, child) {
      return new MaterialApp(
        debugShowCheckedModeBanner: false,
        locale: Locale(value.get('language') ?? 'ar', value.get('country')??'EG'),
        supportedLocales: [
          Locale('ar', 'EG'),
          Locale('en', 'US'),
        ],
        localizationsDelegates: [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
        ],
        localeResolutionCallback: (locale, supportedLocales) {
          for (var supportedLocale in supportedLocales) {
            if (supportedLocale.languageCode == locale!.languageCode &&
                supportedLocale.countryCode == locale.countryCode) {
              return supportedLocale;
            }
          }
          return supportedLocales.first;
        },
        home: user.get('is_first')?? true?  WelcomePage() : MyApp() ,

        theme: ThemeData(
          primaryColor: kPrimaryColor,
          accentColor: kAccentColor,
          textTheme: TextTheme(
            button: TextStyle(
              color: Colors.white
            )
          ),
        ),
      );
    }
  ));
}


class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => new _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late Box user;

  @override
  void initState() {

    super.initState();
    user = Hive.box('user');
    userIsSignIn();
  }
  @override
  Widget build(BuildContext context) {
    return new Container();

      
  }

   userIsSignIn() async {

    if(!user.containsKey('userData')){
      return;
    }

    String? token = user.get('userData').token;
    if (token != null) {
      http.Response refresh = await http.post(Uri.parse('$kUrl/user/auth/refresh'), headers: {
        'Accept':"application/json",
        'Authorization': "Bearer $token"
      });
      Map map = jsonDecode(refresh.body);
      if(map.containsKey('access_token')){
        token = map['access_token'];
      }else{
        user.put('userData', UserP()..tokenAvailable = false);
        user.put('is_login', false);

        return;
      }
      http.Response response = await http.get(Uri.parse('$kUrl/user'), headers: {
        'Authorization': "Bearer $token",
        'Accept': 'application/json'
      });

      map = jsonDecode(response.body);

      if (map.containsKey('data')) {


        user.put('userData', UserP.fromMap(map['data'])..tokenAvailable = true..token=token);
        user.put('is_login', true);
        return ;
      }
    }

  }
}



