import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:deliveryboy_multivendor/Helper/Session.dart';
import 'package:deliveryboy_multivendor/Helper/app_btn.dart';
import 'package:deliveryboy_multivendor/Helper/color.dart';
import 'package:deliveryboy_multivendor/Helper/constant.dart';
import 'package:deliveryboy_multivendor/Helper/string.dart';
import 'package:deliveryboy_multivendor/Model/GetBoUpdateModel.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

class Profile extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => StateProfile();
}

String? lat, long;

class StateProfile extends State<Profile> with TickerProviderStateMixin {
  String? name,
      email,
      mobile,
      address,
      image,
      curPass,
      newPass,
      confPass,
      loaction;

  bool _isLoading = false;
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  TextEditingController? nameC,
      emailC,
      mobileC,
      addressC,
      curPassC,
      newPassC,
      confPassC;
  bool isSelected = false, isArea = true;
  bool _isNetworkAvail = true;
  bool _showCurPassword = false, _showPassword = false, _showCmPassword = false;
  Animation? buttonSqueezeanimation;
  AnimationController? buttonController;

  userId() async {
    CUR_USERID = await getPrefrence(ID);
  }

  @override
  void initState() {
    super.initState();
    userId();
    mobileC = new TextEditingController();
    nameC = new TextEditingController();
    emailC = new TextEditingController();

    addressC = new TextEditingController();
    getUserDetails();

    buttonController = new AnimationController(
        duration: new Duration(milliseconds: 2000), vsync: this);

    buttonSqueezeanimation = new Tween(
      begin: deviceWidth! * 0.7,
      end: 50.0,
    ).animate(new CurvedAnimation(
      parent: buttonController!,
      curve: new Interval(
        0.0,
        0.150,
      ),
    ));
  }

  @override
  void dispose() {
    buttonController!.dispose();
    mobileC?.dispose();
    nameC?.dispose();
    addressC!.dispose();
    super.dispose();
  }

  Future<Null> _playAnimation() async {
    try {
      await buttonController!.forward();
    } on TickerCanceled {}
  }

  getUserDetails() async {
    CUR_USERID = await getPrefrence(ID);
    mobile = await getPrefrence(MOBILE);
    name = await getPrefrence(USERNAME);
    email = await getPrefrence(EMAIL);

    address = await getPrefrence(ADDRESS);
    image = await getPrefrence(IMAGE);

    mobileC!.text = mobile!;
    nameC!.text = name!;
    emailC!.text = email!;

    addressC!.text = address ?? "";

    setState(() {});
  }

  Widget noInternet(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          noIntImage(),
          noIntText(context),
          noIntDec(context),
          AppBtn(
            title: TRY_AGAIN_INT_LBL,
            btnAnim: buttonSqueezeanimation,
            btnCntrl: buttonController,
            onBtnSelected: () async {
              _playAnimation();

              Future.delayed(Duration(seconds: 2)).then((_) async {
                _isNetworkAvail = await isNetworkAvailable();
                if (_isNetworkAvail) {
                  Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (BuildContext context) => super.widget));
                } else {
                  await buttonController!.reverse();
                  setState(() {});
                }
              });
            },
          )
        ]),
      ),
    );
  }

  void validateAndSubmit() async {
    if (validateAndSave()) {
      checkNetwork();
    }
  }

  Future<void> checkNetwork() async {
    _isNetworkAvail = await isNetworkAvailable();
    if (_isNetworkAvail) {
      setUpdateUser();
    } else {
      setState(() {
        _isNetworkAvail = false;
      });
    }
  }

  bool validateAndSave() {
    final form = _formKey.currentState!;
    if (form.validate()) {
      form.save();
      return true;
    }
    return false;
  }

  Future<void> setProfilePic(File _image) async {
    _isNetworkAvail = await isNetworkAvailable();
    if (_isNetworkAvail) {
      setState(() {
        _isLoading = true;
      });
      try {
        var request = http.MultipartRequest("POST", getUpdateUserApi);
        request.headers.addAll(headers);
        request.fields[USER_ID] = CUR_USERID!;
        var pic = await http.MultipartFile.fromPath(IMAGE, _image.path);
        request.files.add(pic);

        var response = await request.send();
        var responseData = await response.stream.toBytes();
        var responseString = String.fromCharCodes(responseData);

        var getdata = json.decode(responseString);
        bool error = getdata["error"];
        String? msg = getdata['message'];
        if (!error) {
          List data = getdata["data"];
          for (var i in data) {
            image = i[IMAGE];
          }
          setPrefrence(IMAGE, image!);
        } else {
          setSnackbar(msg!);
        }
        setState(() {
          _isLoading = false;
        });
      } on TimeoutException catch (_) {
        setSnackbar(somethingMSg);
        setState(() {
          _isLoading = false;
        });
      }
    } else {
      setState(() {
        _isNetworkAvail = false;
      });
    }
  }

  Future<void> setUpdateUser() async {
    var data = {USER_ID: CUR_USERID, USERNAME: name, EMAIL: email};
    if (newPass != null && newPass != "") {
      data[NEWPASS] = newPass;
    }
    if (curPass != null && curPass != "") {
      data[OLDPASS] = curPass;
    }

    if (address != null && address != "") {
      data[ADDRESS] = address;
    }

    http.Response response = await http
        .post(getUpdateUserApi, body: data, headers: headers)
        .timeout(Duration(seconds: timeOut));

    if (response.statusCode == 200) {
      var getdata = json.decode(response.body);

      bool error = getdata["error"];
      String? msg = getdata["message"];
      await buttonController!.reverse();
      if (!error) {
        CUR_USERNAME = name;
        saveUserDetail(
            userId: CUR_USERID!, name: name!, email: email!, mobile: mobile!);
        setSnackbar("Password Change Successfully");
      } else {
        setSnackbar(msg!);
      }
    }
  }

  /* _imgFromGallery() async {
    File image = await FilePicker.getFile(type: FileType.image);

    if (image != null) {

      setState(() {
        _isLoading = true;
      });
      setProfilePic(image);
    }

    ///for file picker greater version
    */
  /*  FilePickerResult result = await FilePicker.platform.pickFiles();
    if(result != null) {
      File image = File(result.files.single.path);
      if (image != null) {
        print('path**${image.path}');
        setState(() {
          _isLoading = true;
        });
        setProfilePic(image);
      }
    } else {
      // User canceled the picker
    }*/
  /*
  }*/

  setSnackbar(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(new SnackBar(
      content: new Text(
        msg,
        textAlign: TextAlign.center,
        style: TextStyle(color: primary),
      ),
      backgroundColor: white,
      elevation: 1.0,
    ));
  }

  setUser() {
    return Column(
      children: [
        ListTile(
          leading: Icon(Icons.person),
          title: Text("Name"),
          subtitle: Text("$name"),
        )
      ],
    );
    // Padding(
    //   padding: EdgeInsets.all(15.0),
    //   child: Row(
    //     children: <Widget>[
    //       // Image.asset('assets/images/username.png', fit: BoxFit.fill),
    //       Icon(Icons.person),
    //       Padding(
    //           padding: EdgeInsets.only(left: 15.0),
    //           child: Column(
    //             crossAxisAlignment: CrossAxisAlignment.start,
    //             children: [
    //               Text(
    //                 NAME_LBL,
    //                 style: Theme.of(this.context).textTheme.caption!.copyWith(
    //                     color: lightBlack2, fontWeight: FontWeight.normal),
    //               ),
    //               name != "" && name != null
    //                   ? Text(
    //                       name!,
    //                       style: Theme.of(this.context)
    //                           .textTheme
    //                           .subtitle2!
    //                           .copyWith(
    //                               color: lightBlack,
    //                               fontWeight: FontWeight.bold),
    //                     )
    //                   : Container()
    //             ],
    //           )),
    //       Spacer(),
    //       // IconButton(
    //       //   icon: Icon(
    //       //     Icons.edit,
    //       //     size: 20,
    //       //     color: lightBlack,
    //       //   ),
    //       //   onPressed: () {
    //       //     showDialog(
    //       //         context: context,
    //       //         barrierDismissible: false,
    //       //         builder: (BuildContext context) {
    //       //           return AlertDialog(
    //       //             contentPadding: const EdgeInsets.all(0),
    //       //             elevation: 2.0,
    //       //             shape: RoundedRectangleBorder(
    //       //                 borderRadius:
    //       //                     BorderRadius.all(Radius.circular(5.0))),
    //       //             content: Column(
    //       //                 mainAxisSize: MainAxisSize.min,
    //       //                 crossAxisAlignment: CrossAxisAlignment.start,
    //       //                 children: [
    //       //                   Padding(
    //       //                       padding:
    //       //                           EdgeInsets.fromLTRB(20.0, 20.0, 0, 2.0),
    //       //                       child: Text(
    //       //                         ADD_NAME_LBL,
    //       //                         style: Theme.of(this.context)
    //       //                             .textTheme
    //       //                             .subtitle1!
    //       //                             .copyWith(color: fontColor),
    //       //                       )),
    //       //                   Divider(color: lightBlack),
    //       //                   Form(
    //       //                       key: _formKey,
    //       //                       child: Padding(
    //       //                           padding:
    //       //                               EdgeInsets.fromLTRB(20.0, 0, 20.0, 0),
    //       //                           child: TextFormField(
    //       //                             keyboardType: TextInputType.text,
    //       //                             style: Theme.of(this.context)
    //       //                                 .textTheme
    //       //                                 .subtitle1!
    //       //                                 .copyWith(
    //       //                                     color: lightBlack,
    //       //                                     fontWeight: FontWeight.normal),
    //       //                             validator: validateUserName,
    //       //                             autovalidateMode:
    //       //                                 AutovalidateMode.onUserInteraction,
    //       //                             controller: nameC,
    //       //                             onChanged: (v) => setState(() {
    //       //                               name = v;
    //       //                             }),
    //       //                           )))
    //       //                 ]),
    //       //             actions: <Widget>[
    //       //               new ElevatedButton(
    //       //                   child: const Text(CANCEL,
    //       //                       style: TextStyle(
    //       //                           color: lightBlack,
    //       //                           fontSize: 15,
    //       //                           fontWeight: FontWeight.bold)),
    //       //                   onPressed: () {
    //       //                     setState(() {
    //       //                       Navigator.pop(context);
    //       //                     });
    //       //                   }),
    //       //               new ElevatedButton(
    //       //                   child: Text(SAVE_LBL,
    //       //                       style: TextStyle(
    //       //                           color: fontColor,
    //       //                           fontSize: 15,
    //       //                           fontWeight: FontWeight.bold)),
    //       //                   onPressed: () {
    //       //                     final form = _formKey.currentState!;
    //       //                     if (form.validate()) {
    //       //                       form.save();
    //       //                       setState(() {
    //       //                         name = nameC!.text;
    //       //                         Navigator.pop(context);
    //       //                       });
    //       //                       checkNetwork();
    //       //                     }
    //       //                   })
    //       //             ],
    //       //           );
    //       //         });
    //       //   },
    //       // )
    //     ],
    //   ));
  }

/*  setEmail() {
    return Padding(
        padding: EdgeInsets.all(15.0),
        child: Row(
          children: <Widget>[
            Image.asset('assets/images/email.png', fit: BoxFit.fill),
            Padding(
                padding: EdgeInsets.only(left: 15.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      EMAILHINT_LBL,
                      style: Theme.of(this.context).textTheme.caption.copyWith(
                          color: lightBlack2, fontWeight: FontWeight.normal),
                    ),
                    email != null && email != ""
                        ? Text(
                            email,
                            style: Theme.of(this.context)
                                .textTheme
                                .subtitle2
                                .copyWith(
                                    color: lightBlack,
                                    fontWeight: FontWeight.bold),
                          )
                        : Container()
                  ],
                )),
            Spacer(),
            IconButton(
              icon: Icon(
                Icons.edit,
                size: 20,
                color: lightBlack,
              ),
              onPressed: () {
                showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        contentPadding: const EdgeInsets.all(0.0),
                        elevation: 2.0,
                        shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(5.0))),
                        content: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                  padding:
                                      EdgeInsets.fromLTRB(20.0, 20.0, 0, 2.0),
                                  child: Text(
                                    ADD_EMAIL_LBL,
                                    style: Theme.of(this.context)
                                        .textTheme
                                        .subtitle1
                                        .copyWith(color: fontColor),
                                  )),
                              Divider(color: lightBlack),
                              Form(
                                  key: _formKey,
                                  child: Padding(
                                      padding:
                                          EdgeInsets.fromLTRB(20.0, 0, 20.0, 0),
                                      child: TextFormField(
                                        keyboardType: TextInputType.text,
                                        style: Theme.of(this.context)
                                            .textTheme
                                            .subtitle1
                                            .copyWith(
                                                color: lightBlack,
                                                fontWeight: FontWeight.normal),
                                        validator: validateEmail,
                                        autovalidateMode:
                                            AutovalidateMode.onUserInteraction,
                                        controller: emailC,
                                        onChanged: (v) => setState(() {
                                          email = v;
                                        }),
                                      )))
                            ]),
                        actions: <Widget>[
                          new ElevatedButton(
                              child:  Text(CANCEL,
                                  style: TextStyle(
                                      color: lightBlack,
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold)),
                              onPressed: () {
                                setState(() {
                                  Navigator.pop(context);
                                });
                              }),
                          new ElevatedButton(
                              child: const Text(SAVE_LBL,
                                  style: TextStyle(
                                      color: fontColor,
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold)),
                              onPressed: () {
                                final form = _formKey.currentState;
                                if (form.validate()) {
                                  form.save();
                                  setState(() {
                                    email = emailC.text;
                                    Navigator.pop(context);
                                  });
                                  checkNetwork();
                                }
                              })
                        ],
                      );
                    });
              },
            )
          ],
        ));
  }*/

  setEmail() {
    return Column(
      children: [
        ListTile(
          leading: Icon(Icons.mail),
          title: Text("Email"),
          subtitle: Text("${email!}"),
        )
      ],
    );
  }

  setMobileNo() {
    return Column(
      children: [
        ListTile(
          leading: Icon(Icons.phone),
          title: Text("Mobile Number"),
          subtitle: Text("${mobile!}"),
        )
      ],
    );
    // return Padding(
    //     padding: EdgeInsets.symmetric(horizontal: 15.0, vertical: 20),
    //     child: Row(
    //       children: <Widget>[
    //         Icon(Icons.phone),
    //         // Image.asset('assets/images/mobilenumber.png', fit: BoxFit.fill),
    //         Padding(
    //             padding: EdgeInsets.only(left: 15.0),
    //             child: Column(
    //               crossAxisAlignment: CrossAxisAlignment.start,
    //               children: [
    //                 Text(
    //                   MOBILEHINT_LBL,
    //                   style: Theme.of(this.context).textTheme.caption!.copyWith(
    //                       color: lightBlack2, fontWeight: FontWeight.normal),
    //                 ),
    //                 mobile != null && mobile != ""
    //                     ? Text(
    //                         mobile!,
    //                         style: Theme.of(this.context)
    //                             .textTheme
    //                             .subtitle2!
    //                             .copyWith(
    //                                 color: lightBlack,
    //                                 fontWeight: FontWeight.bold),
    //                       )
    //                     : Container()
    //               ],
    //             )),
    //       ],
    //     ));
  }

  changePass() {
    return Container(
        height: 60,
        width: deviceWidth,
        margin: EdgeInsets.only(bottom: 5.0),
        child: Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(10.0))),
            child: InkWell(
              child: Padding(
                padding: EdgeInsets.only(left: 20.0, top: 15.0, bottom: 15.0),
                child: Text(
                  CHANGE_PASS_LBL,
                  style: Theme.of(this.context)
                      .textTheme
                      .subtitle2!
                      .copyWith(color: fontColor, fontWeight: FontWeight.bold),
                ),
              ),
              onTap: () {
                _showDialog();
              },
            )));
  }

  _showDialog() async {
    await showDialog(
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder(
              builder: (BuildContext context, StateSetter setStater) {
            return AlertDialog(
              contentPadding: const EdgeInsets.all(0.0),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(5.0))),
              content: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Padding(
                            padding: EdgeInsets.fromLTRB(20.0, 20.0, 0, 2.0),
                            child: Text(
                              CHANGE_PASS_LBL,
                              style: Theme.of(this.context)
                                  .textTheme
                                  .subtitle1!
                                  .copyWith(color: fontColor),
                            )),
                        Divider(color: lightBlack),
                        Form(
                            key: _formKey,
                            child: new Column(
                              children: <Widget>[
                                Padding(
                                    padding:
                                        EdgeInsets.fromLTRB(20.0, 0, 20.0, 0),
                                    child: TextFormField(
                                      keyboardType: TextInputType.text,
                                      validator: validatePass,
                                      autovalidateMode:
                                          AutovalidateMode.onUserInteraction,
                                      decoration: InputDecoration(
                                          hintText: CUR_PASS_LBL,
                                          hintStyle: Theme.of(this.context)
                                              .textTheme
                                              .subtitle1!
                                              .copyWith(
                                                  color: lightBlack,
                                                  fontWeight:
                                                      FontWeight.normal),
                                          suffixIcon: IconButton(
                                            icon: Icon(_showCurPassword
                                                ? Icons.visibility
                                                : Icons.visibility_off),
                                            iconSize: 20,
                                            color: lightBlack,
                                            onPressed: () {
                                              setStater(() {
                                                _showCurPassword =
                                                    !_showCurPassword;
                                              });
                                            },
                                          )),
                                      obscureText: !_showCurPassword,
                                      controller: curPassC,
                                      onChanged: (v) => setState(() {
                                        curPass = v;
                                      }),
                                    )),
                                Padding(
                                    padding:
                                        EdgeInsets.fromLTRB(20.0, 0, 20.0, 0),
                                    child: TextFormField(
                                      keyboardType: TextInputType.text,
                                      validator: validatePass,
                                      autovalidateMode:
                                          AutovalidateMode.onUserInteraction,
                                      decoration: new InputDecoration(
                                          hintText: NEW_PASS_LBL,
                                          hintStyle: Theme.of(this.context)
                                              .textTheme
                                              .subtitle1!
                                              .copyWith(
                                                  color: lightBlack,
                                                  fontWeight:
                                                      FontWeight.normal),
                                          suffixIcon: IconButton(
                                            icon: Icon(_showPassword
                                                ? Icons.visibility
                                                : Icons.visibility_off),
                                            iconSize: 20,
                                            color: lightBlack,
                                            onPressed: () {
                                              setStater(() {
                                                _showPassword = !_showPassword;
                                              });
                                            },
                                          )),
                                      obscureText: !_showPassword,
                                      controller: newPassC,
                                      onChanged: (v) => setState(() {
                                        newPass = v;
                                      }),
                                    )),
                                Padding(
                                    padding:
                                        EdgeInsets.fromLTRB(20.0, 0, 20.0, 0),
                                    child: TextFormField(
                                      keyboardType: TextInputType.text,
                                      validator: (value) {
                                        if (value!.length == 0)
                                          return CON_PASS_REQUIRED_MSG;
                                        if (value != newPass) {
                                          return CON_PASS_NOT_MATCH_MSG;
                                        } else {
                                          return null;
                                        }
                                      },
                                      autovalidateMode:
                                          AutovalidateMode.onUserInteraction,
                                      decoration: new InputDecoration(
                                          hintText: CONFIRMPASSHINT_LBL,
                                          hintStyle: Theme.of(this.context)
                                              .textTheme
                                              .subtitle1!
                                              .copyWith(
                                                  color: lightBlack,
                                                  fontWeight:
                                                      FontWeight.normal),
                                          suffixIcon: IconButton(
                                            icon: Icon(_showCmPassword
                                                ? Icons.visibility
                                                : Icons.visibility_off),
                                            iconSize: 20,
                                            color: lightBlack,
                                            onPressed: () {
                                              setStater(() {
                                                _showCmPassword =
                                                    !_showCmPassword;
                                              });
                                            },
                                          )),
                                      obscureText: !_showCmPassword,
                                      controller: confPassC,
                                      onChanged: (v) => setState(() {
                                        confPass = v;
                                      }),
                                    )),
                              ],
                            ))
                      ])),
              actions: <Widget>[
                new ElevatedButton(
                    child: Text(
                      CANCEL,
                      style: Theme.of(this.context)
                          .textTheme
                          .subtitle2!
                          .copyWith(
                              color: lightBlack, fontWeight: FontWeight.bold),
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                    }),
                new ElevatedButton(
                    child: Text(
                      SAVE_LBL,
                      style: Theme.of(this.context)
                          .textTheme
                          .subtitle2!
                          .copyWith(
                              color: fontColor, fontWeight: FontWeight.bold),
                    ),
                    onPressed: () {
                      final form = _formKey.currentState!;
                      if (form.validate()) {
                        form.save();
                        setState(() {
                          Navigator.pop(context);
                        });
                        checkNetwork();
                      }
                    })
              ],
            );
          });
        });
  }

  profileImage() {
    return Container(
      padding: EdgeInsets.only(left: 20.0, right: 20.0, top: 30.0),
      child: CircleAvatar(
        radius: 50,
        backgroundColor: primary,
        child: Container(
            decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(100),
                border: Border.all(color: primary)),
            child: Icon(Icons.account_circle, size: 100)),
      ),
    );
  }

  profile() {
    return Container(
      child: FutureBuilder(
          future: getupdateboy(CUR_USERID),
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            if (snapshot.hasData) {
              var data = snapshot.data.data;
              return CircleAvatar(
                radius: 50,
                backgroundImage: NetworkImage(
                  "${snapshot.data.imgPath}${data[0].proPic}",
                ),
              );
              //   Container(
              //   height: 80,
              //   width: 100,
              //   decoration: BoxDecoration(
              //     borderRadius: BorderRadius.circular(100),
              //     image: DecorationImage(
              //       image: NetworkImage("${snapshot.data.imgPath}${data[0].proPic}",
              //       ),
              //     )
              //   ),
              // );
              //   Column(
              //   children: [
              //     CircleAvatar(
              //       radius: 50,
              //       backgroundColor: primary,
              //       child: Container(
              //           decoration: BoxDecoration(
              //               color: Colors.grey[200],
              //               borderRadius: BorderRadius.circular(100),
              //               border: Border.all(color: primary)),
              //           child: Image.network("${snapshot.data.imgPath}${data[0].proPic}",
              //           fit: BoxFit.fill,
              //           )
              //       ),
              //     ),
              //
              //
              //   ],
              // );
            } else if (snapshot.hasError) {
              return Icon(Icons.error_outline);
            } else {
              return Center(child: CircularProgressIndicator());
            }
          }),
    );
  }

  genderAndDob() {
    return Container(
      child: FutureBuilder(
          future: getupdateboy(CUR_USERID),
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            if (snapshot.hasData) {
              var data = snapshot.data.data;
              return Column(
                children: [
                  ListTile(
                    leading: Icon(Icons.person_add_alt_1),
                    title: Text("Gender"),
                    subtitle: Text("${data[0].gender}"),
                  ),
                  Divider(
                    color: Colors.black,
                  ),
                  ListTile(
                    leading: Icon(Icons.date_range),
                    title: Text("Date Of Birth"),
                    subtitle: Text("${data[0].dob}"),
                  ),
                  Divider(
                    color: Colors.black,
                  ),
                  ListTile(
                    leading: Icon(Icons.electric_bike),
                    title: Text("Vehicle No."),
                    subtitle: Text("${data[0].vehicle}"),
                  ),
                  Divider(
                    color: Colors.black,
                  ),
                  ListTile(
                    leading: Icon(Icons.home),
                    title: Text("Address"),
                    subtitle: Text("${data[0].address}"),
                  ),
                  Divider(
                    color: Colors.black,
                  ),
                  ListTile(
                    leading: Icon(Icons.account_balance),
                    title: Text("Account Number"),
                    subtitle: Text("${data[0].accountNumber}"),
                  ),
                  Divider(
                    color: Colors.black,
                  ),
                  ListTile(
                    leading: Icon(Icons.qr_code),
                    title: Text("IFSC Code"),
                    subtitle: Text("${data[0].bankCode}"),
                  ),
                  Divider(
                    color: Colors.black,
                  ),
                  ListTile(
                    leading: Icon(Icons.qr_code),
                    title: Text("License Number"),
                    subtitle: Text("${data[0].licenseNumber}"),
                  ),
                  Divider(
                    color: Colors.black,
                  ),
                  ListTile(
                    leading: Icon(Icons.qr_code),
                    title: Text("License Number Ex"),
                    subtitle: Text("${data[0].licenseNumberEx}"),
                  ),
                  Divider(
                    color: Colors.black,
                  ),
                  ListTile(
                    leading: Icon(Icons.qr_code),
                    title: Text("Aadhar Number"),
                    subtitle: Text("${data[0].adharNum}"),
                  ),
                  Divider(
                    color: Colors.black,
                  ),
                  ListTile(
                    leading: Icon(Icons.qr_code),
                    title: Text("Pan Card"),
                    subtitle: Text("${data[0].pancard}"),
                  ),
                  Divider(
                    color: Colors.black,
                  ),
                  ListTile(
                    leading: Icon(Icons.qr_code),
                    title: Text("RC Number"),
                    subtitle: Text("${data[0].rcNumber}"),
                  ),
                  Divider(
                    color: Colors.black,
                  ),
                  ListTile(
                    leading: Icon(Icons.local_police),
                    title: Text("Licence"),
                    subtitle: Card(
                      child: Image.network(
                          "${snapshot.data.imgPath}${data[0].license}"),
                    ),
                  ),
                  ListTile(
                    leading: Icon(Icons.local_police),
                    title: Text("Pan Card"),
                    subtitle: Card(
                      child: Image.network(
                          "${snapshot.data.imgPath}${data[0].pancardImage}"),
                    ),
                  ),
                  ListTile(
                    leading: Icon(Icons.local_police),
                    title: Text("Aadhar Front Image"),
                    subtitle: Card(
                      child: Image.network(
                          "${snapshot.data.imgPath}${data[0].adharFrontImage}"),
                    ),
                  ),
                  ListTile(
                    leading: Icon(Icons.local_police),
                    title: Text("Aadhar Back Image"),
                    subtitle: Card(
                      child: Image.network(
                          "${snapshot.data.imgPath}${data[0].adharBackImage}"),
                    ),
                  ),
                  ListTile(
                    leading: Icon(Icons.local_police),
                    title: Text("Rc Back Image"),
                    subtitle: Card(
                      child: Image.network(
                          "${snapshot.data.imgPath}${data[0].rcBackImage}"),
                    ),
                  ),
                  ListTile(
                    leading: Icon(Icons.local_police),
                    title: Text("Rc Front Image"),
                    subtitle: Card(
                      child: Image.network(
                          "${snapshot.data.imgPath}${data[0].rcFrontImage}"),
                    ),
                  ),
                  ListTile(
                    leading: Icon(Icons.local_police),
                    title: Text("Insurance Image"),
                    subtitle: Card(
                      child: Image.network(
                          "${snapshot.data.imgPath}${data[0].insuranceImage}"),
                    ),
                  ),
                ],
              );
            } else if (snapshot.hasError) {
              return Icon(Icons.error_outline);
            } else {
              return Center(child: CircularProgressIndicator());
            }
          }),
    );
  }

  _getDivider() {
    return Divider(
      height: 1,
      color: lightBlack,
    );
  }

  _showContent1() {
    return SingleChildScrollView(
        child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            child: _isNetworkAvail
                ? Column(children: <Widget>[
                    // profileImage(),
                    profile(),
                    Padding(
                        padding: const EdgeInsets.only(top: 20, bottom: 5.0),
                        child: Container(
                            child: Card(
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.all(
                                        Radius.circular(10.0))),
                                child: Column(
                                  children: <Widget>[
                                    setUser(),
                                    _getDivider(),
                                    setEmail(),
                                    _getDivider(),
                                    setMobileNo(),
                                    _getDivider(),
                                    genderAndDob(),
                                  ],
                                )))),
                    changePass(),
                    SizedBox(
                      height: 20.0,
                    ),
                  ])
                : noInternet(context)));
  }

  @override
  Widget build(BuildContext context) {
    deviceHeight = MediaQuery.of(context).size.height;
    deviceWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: lightWhite,
      appBar: getAppBar(EDIT_PROFILE_LBL, context),
      body: Stack(
        children: <Widget>[
          _showContent1(),
          showCircularProgress(_isLoading, primary)
        ],
      ),
    );
  }

  Future<GetBoUpdateModel?> getupdateboy(id) async {
    var header = headers;
    var request = http.MultipartRequest('POST', getDeliveryBoyDetailApi);
    request.fields.addAll({'id': '$id'});
    print("fffffffffff________${request.fields}");

    request.headers.addAll(header);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      final str = await response.stream.bytesToString();
      print(str);
      return GetBoUpdateModel.fromJson(json.decode(str));
    } else {
      return null;
    }
  }
}
