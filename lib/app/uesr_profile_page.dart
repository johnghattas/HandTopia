
import 'dart:io';

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../widgets/app_bar.dart';
import '../widgets/cust_buton.dart';
import '../widgets/custom_drawer.dart';
import '../Hive/user_model.dart';
import '../api/auth_requests.dart';
import '../api/firebase_storage.dart';
import '../app_localization.dart';
import 'package:hive/hive.dart';
import 'package:image_picker/image_picker.dart';

import '../constants.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {

  UserP? _user;

  var _isEdit = false;

  bool _isAddressRO = true;
  bool _isPhoneRO = true;

  File? _imageFile;
  late double _height;

  String? _image;
  String? _address = '';
  String? _phone = '';

  GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _user = Hive.box('user').get('userData');

  }

  @override
  Widget build(BuildContext context) {
    var _local = AppLocalizations.of(context)!;
    var orientation = MediaQuery.of(context).orientation;
    double height = MediaQuery.of(context).size.height;
    if(orientation == Orientation.portrait && height > 600){
      _height = height;
    }else{
      _height = 700;
    }
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: kBackground,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            height: _height - 40,
            child: Column(
              children: [
                CustomAppBar(scaffoldKey: _scaffoldKey,),

                Container(
                  child: Center(
                    child: Column(
                      children: [
                        GestureDetector(
                          onTap: pickImage,
                          child: Stack(
                            children: [
                              Container(
                                width: 100,
                                height: 100,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(50),
                                  image: DecorationImage(
                                    image: _showImage(),
                                    fit: BoxFit.cover,
                                  ),
                                  border: Border.all(width: 2.0,color: const Color(0xffc40018),),
                                ),
                              ),
                              Positioned(
                                  bottom: 5,
                                  right: 10,
                                  child: SvgPicture.asset(
                                    'assets/add_icon.svg',
                                    height: 15,
                                    width: 15,
                                  )),
                            ],
                          ),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Text(
                          _user!.name??"",
                          style: TextStyle(
                            fontFamily: 'HS Dream',
                            fontSize: 27,
                            color: const Color(0xffffffff),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(height: 10),
                        Text(
                          _user!.email??_local.translate('sign_to_handy')!,
                          style: TextStyle(
                            fontFamily: 'HS Dream',
                            fontSize: 20,
                            color: const Color(0xffff6107),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 10),
                Divider(
                  height: 1,
                  color: Colors.white,
                ),
                SizedBox(height: 40),

                //address input
                Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: Column(
                          children: [
                            Container(
                              width: double.infinity,
                              child: Text.rich(
                                TextSpan(
                                  style: TextStyle(
                                    fontFamily: 'HS Dream',
                                    fontSize: 20,
                                    color: const Color(0xffffffff),
                                  ),
                                  children: [
                                    TextSpan(
                                      text: _local.translate("required_address"),
                                      style: TextStyle(
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    TextSpan(
                                      text: "(${_local.translate('optional')}) ",
                                      style: TextStyle(
                                        fontWeight: FontWeight.w300,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            TextFormField(
                              initialValue: _user!.address,
                              readOnly: _isAddressRO,
                              keyboardType: TextInputType.streetAddress,
                              decoration: InputDecoration(
                                suffixIcon: Tooltip(
                                  message: _local.translate('edit'),
                                  showDuration: Duration(seconds: 1),
                                  child: InkWell(
                                      onTap: () {

                                        setState(() {
                                          _isEdit = true;
                                          _isAddressRO = false;
                                        });
                                      },
                                      child: Icon(Icons.edit)),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: Theme.of(context).primaryColor),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                hintStyle: kTextStyle,
                                border: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: Theme.of(context).primaryColor),
                                    borderRadius: BorderRadius.circular(16)),
                              ),
                              style: kTextStyle,
                              minLines: 2,
                              maxLines: 3,
                              onSaved: (v) => _address = v,
                            ),
                          ],
                        ),
                      ),

                      SizedBox(
                        height: 20,
                      ),
                      //phone input
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: Column(
                          children: [
                            Container(
                              width: double.infinity,
                              child: Text.rich(
                                TextSpan(
                                  style: TextStyle(
                                    fontFamily: 'HS Dream',
                                    fontSize: 20,
                                    color: const Color(0xffffffff),
                                  ),
                                  children: [
                                    TextSpan(
                                      text: _local.translate('required_phone'),
                                      style: TextStyle(
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    TextSpan(
                                      text: "(${_local.translate('optional')}) ",
                                      style: TextStyle(
                                        fontWeight: FontWeight.w300,
                                      ),
                                    ),
                                  ],
                                ),

                              ),
                            ),
                            TextFormField(
                              readOnly: _isPhoneRO,
                              initialValue:
                                  _user!.phone,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                suffixIcon: Tooltip(
                                  message: _local.translate('edit'),
                                  showDuration: Duration(seconds: 1),
                                  child: InkWell(
                                      onTap: () {
                                        setState(() {
                                          _isEdit = true;
                                          _isPhoneRO = false;
                                        });
                                      },
                                      child: Icon(Icons.edit)),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: Theme.of(context).primaryColor),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                disabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.grey),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                hintStyle: kTextStyle,
                                border: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: Theme.of(context).primaryColor),
                                    borderRadius: BorderRadius.circular(16)),
                              ),
                              style: kTextStyle,
                              onSaved: (v) => _phone = v,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Spacer(),
                AnimatedOpacity(
                  opacity: _isEdit ? 1 : 0,
                  duration: Duration(milliseconds: 300),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Align(
                      alignment: Alignment.topRight,
                      child: CustomButton(hintKey: 'submit',function: changeData,),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      drawer: CustomDrawer(path: 'profile',),
    );
  }

  pickImage() async{
    if ((_user!.tokenAvailable == null || !_user!.tokenAvailable!)){

      return;
    }
    PickedFile? _pickedFile ;
    _pickedFile =  await ImagePicker().getImage(source: ImageSource.gallery,maxHeight: 150, maxWidth: 150, imageQuality: 100);


    if (_pickedFile!.path != null){
      setState(() {
        _isEdit = true;
        _imageFile = File(_pickedFile!.path);
      });
    }
  }

  ImageProvider _showImage() {
    if (_imageFile != null)
      return FileImage(_imageFile!);
    return NetworkImage(_user!.image ?? "http://placehold.it/150x150");
  }

  changeData() async{

    _formKey.currentState!.save();
    if(_address!.trim() == AppLocalizations.of(context)!.translate('empty')){
      _address = '';
    }

    _image = await StorageFirebase.putImage(_imageFile!);
    _user?..phone = _phone!.trim()..address = _address!.trim()..image = _image..save();

    //////////////Done
    showSuccessDialog();

    UserApi().changeUser(_user!.token, _user!);

  }

  showSuccessDialog() {
    setState(() {
      _isEdit = false;
      _isAddressRO = true;
      _isPhoneRO = true;
    });
    AwesomeDialog(
        context: this.context,
        dialogType: DialogType.SUCCES,
        desc: AppLocalizations.of(context)!.translate("success_update_profile") ?? '',
        animType: AnimType.BOTTOMSLIDE,
        title: AppLocalizations.of(context)!.translate("success_update"),
        autoHide: Duration(seconds: 2, milliseconds: 300),
        )
      ..show();


  }
}
