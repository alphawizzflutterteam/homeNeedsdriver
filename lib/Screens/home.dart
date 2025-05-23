import 'dart:async';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:deliveryboy_multivendor/Helper/Session.dart';
import 'package:deliveryboy_multivendor/Helper/app_btn.dart';
import 'package:deliveryboy_multivendor/Helper/color.dart';
import 'package:deliveryboy_multivendor/Helper/constant.dart';
import 'package:deliveryboy_multivendor/Helper/push_notification_service.dart';
import 'package:deliveryboy_multivendor/Helper/string.dart';
import 'package:deliveryboy_multivendor/Model/GetBoUpdateModel.dart';
import 'package:deliveryboy_multivendor/Model/order_model.dart';
import 'package:deliveryboy_multivendor/Screens/Authentication/login.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import 'notification_lIst.dart';
import 'order_detail.dart';
import 'privacy_policy.dart';
import 'profile.dart';
import 'wallet_history.dart';
import 'package:http/http.dart' as http;

class Home extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return StateHome();
  }
}

int? total, offset;
List<Order_Model> orderList = [];
bool _isLoading = true;
bool isLoadingmore = true;
bool isLoadingItems = true;

class StateHome extends State<Home> with TickerProviderStateMixin {
  int curDrwSel = 0;

  bool _isNetworkAvail = true;
  List<Order_Model> tempList = [];
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  Animation? buttonSqueezeanimation;
  AnimationController? buttonController;
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();
  String? profile;
  ScrollController controller = ScrollController();
  List<String> statusList = [
    ALL,
    PLACED,
    PROCESSED,
    SHIPED,
    DELIVERD,
    CANCLED,
    RETURNED,
    awaitingPayment
  ];
  String? activeStatus;

  @override
  void initState() {
    offset = 0;
    total = 0;
    getUserCurrentLocation();
    getUserDetail();
    orderList.clear();
    getSetting();

    updateLetLongTimer();

    init();

    final pushNotificationService = PushNotificationService(context: context);
    pushNotificationService.initialise();

    buttonController = AnimationController(
        duration: Duration(milliseconds: 2000), vsync: this);

    buttonSqueezeanimation = Tween(
      begin: deviceWidth! * 0.7,
      end: 50.0,
    ).animate(CurvedAnimation(
      parent: buttonController!,
      curve: Interval(
        0.0,
        0.150,
      ),
    ));
    controller.addListener(_scrollListener);

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: lightWhite,
      appBar: AppBar(
        title: Text(
          appName,
          style: TextStyle(
            color: primary,
          ),
        ),
        iconTheme: IconThemeData(color: primary),
        backgroundColor: white,
        actions: [
          InkWell(
              onTap: filterDialog,
              child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Icon(
                    Icons.filter_alt_outlined,
                    color: primary,
                  )))
        ],
      ),
      drawer: _getDrawer(),
      body: _isNetworkAvail
          ? _isLoading
              ? shimmer()
              : RefreshIndicator(
                  key: _refreshIndicatorKey,
                  onRefresh: _refresh,
                  child: SingleChildScrollView(
                      controller: controller,
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _detailHeader(),
                                orderList.isEmpty
                                    ? isLoadingItems
                                        ? const Center(
                                            child: CircularProgressIndicator())
                                        : const Center(child: Text(noItem))
                                    : ListView.builder(
                                        shrinkWrap: true,
                                        itemCount: (offset! < total!)
                                            ? orderList.length + 1
                                            : orderList.length,
                                        physics:
                                            const NeverScrollableScrollPhysics(),
                                        itemBuilder: (context, index) {
                                          return (index == orderList.length &&
                                                  isLoadingmore)
                                              ? const Center(
                                                  child:
                                                      CircularProgressIndicator())
                                              : orderItem(index);
                                        },
                                      )
                              ]))))
          : noInternet(context),
    );
  }

  void filterDialog() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return ButtonBarTheme(
            data: const ButtonBarThemeData(
              alignment: MainAxisAlignment.center,
            ),
            child: AlertDialog(
                elevation: 2.0,
                shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(5.0))),
                contentPadding: const EdgeInsets.all(0.0),
                content: SingleChildScrollView(
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                    Padding(
                        padding:
                            EdgeInsetsDirectional.only(top: 19.0, bottom: 16.0),
                        child: Text(
                          'Filter By',
                          style: Theme.of(context)
                              .textTheme
                              .headline6!
                              .copyWith(color: fontColor),
                        )),
                    Divider(color: lightBlack),
                    Flexible(
                      child: SingleChildScrollView(
                        child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: getStatusList()),
                      ),
                    ),
                  ]),
                )),
          );
        });
  }

  List<Widget> getStatusList() {
    return statusList
        .asMap()
        .map(
          (index, element) => MapEntry(
            index,
            Column(
              children: [
                Container(
                  width: double.maxFinite,
                  child: TextButton(
                      child: Text(capitalize(statusList[index]),
                          style: Theme.of(context)
                              .textTheme
                              .subtitle1!
                              .copyWith(color: lightBlack)),
                      onPressed: () {
                        setState(() {
                          activeStatus = index == 0 ? null : statusList[index];
                          isLoadingmore = true;
                          offset = 0;
                          isLoadingItems = true;
                        });

                        getOrder();

                        Navigator.pop(context, 'option $index');
                      }),
                ),
                const Divider(
                  color: lightBlack,
                  height: 1,
                ),
              ],
            ),
          ),
        )
        .values
        .toList();
  }

  _scrollListener() {
    if (controller.offset >= controller.position.maxScrollExtent &&
        !controller.position.outOfRange) {
      if (this.mounted) {
        setState(() {
          isLoadingmore = true;

          if (offset! < total!) getOrder();
        });
      }
    }
  }

  Drawer _getDrawer() {
    return Drawer(
      child: SafeArea(
        child: Container(
          color: white,
          child: ListView(
            padding: EdgeInsets.all(0),
            shrinkWrap: true,
            physics: BouncingScrollPhysics(),
            children: <Widget>[
              _getHeader(),
              Divider(),
              _getDrawerItem(0, HOME_LBL, Icons.home_outlined),
              _getDrawerItem(7, WALLET, Icons.account_balance_wallet_outlined),
              // _getDrawerItem(5, NOTIFICATION, Icons.notifications_outlined),
              _getDivider(),
              _getDrawerItem(8, PRIVACY, Icons.lock_outline),
              _getDrawerItem(9, TERM, Icons.speaker_notes_outlined),
              CUR_USERID == "" || CUR_USERID == null
                  ? Container()
                  : _getDivider(),
              CUR_USERID == "" || CUR_USERID == null
                  ? Container()
                  : _getDrawerItem(11, LOGOUT, Icons.input),
            ],
          ),
        ),
      ),
    );
  }

  Widget _getHeader() {
    return InkWell(
      child: Container(
        decoration: back(),
        padding: const EdgeInsets.only(left: 10.0, bottom: 10),
        child: Row(
          children: [
            Padding(
                padding: const EdgeInsets.only(top: 20, left: 10),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      CUR_USERNAME!,
                      style: Theme.of(context)
                          .textTheme
                          .subtitle1!
                          .copyWith(color: white, fontWeight: FontWeight.bold),
                    ),
                    Text("$WALLET_BAL: ${CUR_CURRENCY!}$CUR_BALANCE",
                        style: Theme.of(context)
                            .textTheme
                            .caption!
                            .copyWith(color: white)),
                    Padding(
                        padding: const EdgeInsets.only(
                          top: 7,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(EDIT_PROFILE_LBL,
                                style: Theme.of(context)
                                    .textTheme
                                    .caption!
                                    .copyWith(color: white)),
                            const Icon(
                              Icons.arrow_right_outlined,
                              color: white,
                              size: 20,
                            ),
                          ],
                        ))
                  ],
                )),
            Spacer(),
            profileImage(),
          ],
        ),
      ),
      onTap: () async {
        await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => Profile(),
            ));

        setState(() {});
      },
    );
  }

  Widget _getDivider() {
    return const Padding(
      padding: EdgeInsets.all(8.0),
      child: Divider(
        height: 1,
      ),
    );
  }

  Widget _getDrawerItem(int index, String title, IconData icn) {
    return Container(
      margin: const EdgeInsets.only(right: 20),
      decoration: BoxDecoration(
          gradient: curDrwSel == index
              ? LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [
                      secondary.withOpacity(0.2),
                      primary.withOpacity(0.2)
                    ],
                  stops: [
                      0,
                      1
                    ])
              : null,
          // color: curDrwSel == index ? primary.withOpacity(0.2) : Colors.transparent,

          borderRadius: const BorderRadius.only(
            topRight: Radius.circular(50),
            bottomRight: Radius.circular(50),
          )),
      child: ListTile(
        dense: true,
        leading: Icon(
          icn,
          color: curDrwSel == index ? primary : lightBlack2,
        ),
        title: Text(
          title,
          style: TextStyle(
              color: curDrwSel == index ? primary : lightBlack2, fontSize: 15),
        ),
        onTap: () {
          Navigator.of(context).pop();
          if (title == HOME_LBL) {
            setState(() {
              curDrwSel = index;
            });
            Navigator.pushNamedAndRemoveUntil(context, "/home", (r) => false);
          } else if (title == NOTIFICATION) {
            setState(() {
              curDrwSel = index;
            });

            Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => NotificationList(),
                ));
          } else if (title == LOGOUT) {
            logOutDailog();
          } else if (title == PRIVACY) {
            setState(() {
              curDrwSel = index;
            });
            Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const PrivacyPolicy(
                    title: PRIVACY,
                  ),
                ));
          } else if (title == TERM) {
            setState(() {
              curDrwSel = index;
            });
            Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const PrivacyPolicy(
                    title: TERM,
                  ),
                ));
          } else if (title == WALLET) {
            Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => WalletHistory(),
                ));
          }
        },
      ),
    );
  }

  @override
  void dispose() {
    buttonController!.dispose();
    _timer!.cancel();
    super.dispose();
  }

  Future<Null> _refresh() {
    offset = 0;
    total = 0;
    orderList.clear();

    setState(() {
      _isLoading = true;
      isLoadingItems = false;
    });
    orderList.clear();
    return getOrder();
  }

  logOutDailog() async {
    await showDialog(
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder(
              builder: (BuildContext context, StateSetter setStater) {
            return AlertDialog(
              shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(5.0))),
              content: Text(
                LOGOUTTXT,
                style: Theme.of(this.context)
                    .textTheme
                    .subtitle1!
                    .copyWith(color: fontColor),
              ),
              actions: <Widget>[
                TextButton(
                    child: Text(
                      LOGOUTNO,
                      style: Theme.of(this.context)
                          .textTheme
                          .subtitle2!
                          .copyWith(
                              color: lightBlack, fontWeight: FontWeight.bold),
                    ),
                    onPressed: () {
                      Navigator.of(context).pop(false);
                    }),
                TextButton(
                    child: Text(
                      LOGOUTYES,
                      style: Theme.of(this.context)
                          .textTheme
                          .subtitle2!
                          .copyWith(
                              color: fontColor, fontWeight: FontWeight.bold),
                    ),
                    onPressed: () {
                      clearUserSession();

                      Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(builder: (context) => Login()),
                          (Route<dynamic> route) => false);
                    })
              ],
            );
          });
        });
  }

  Future<Null> _playAnimation() async {
    try {
      await buttonController!.forward();
    } on TickerCanceled {}
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
                  getOrder();
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

  Future<Null> getOrder() async {
    _isNetworkAvail = await isNetworkAvailable();
    if (_isNetworkAvail) {
      if (offset == 0) {
        orderList = [];
      }
      try {
        CUR_USERID = await getPrefrence(ID);
        CUR_USERNAME = await getPrefrence(USERNAME);

        var parameter = {
          USER_ID: CUR_USERID,
          LIMIT: perPage.toString(),
          OFFSET: offset.toString(),
          LATITUDE: lat ?? '',
          LONGITUDE: long ?? '',
        };
        print("fgfgffgfdd__________${parameter}");
        if (activeStatus != null) {
          if (activeStatus == awaitingPayment) activeStatus = "awaiting";
          parameter[ACTIVE_STATUS] = activeStatus;
        }

        Response response =
            await post(getOrdersApi, body: parameter, headers: headers)
                .timeout(Duration(seconds: timeOut));

        var getdata = json.decode(response.body);
        bool error = getdata["error"];
        String? msg = getdata["message"];
        total = int.parse(getdata["total"].toString());

        if (!error) {
          if (offset! < total!) {
            tempList.clear();
            var data = getdata["data"];

            tempList = (data as List)
                .map((data) => Order_Model.fromJson(data))
                .toList();

            orderList.addAll(tempList);

            offset = offset! + perPage;
          }
        }
        if (mounted)
          setState(() {
            _isLoading = false;
            isLoadingItems = false;
          });
      } on TimeoutException catch (_) {
        setSnackbar(somethingMSg);
        setState(() {
          _isLoading = false;
          isLoadingItems = false;
        });
      }
    } else {
      if (mounted)
        setState(() {
          _isNetworkAvail = false;
          _isLoading = false;
          isLoadingItems = false;
        });
    }

    return null;
  }

  Future<Null> getUserDetail() async {
    _isNetworkAvail = await isNetworkAvailable();
    if (_isNetworkAvail) {
      try {
        CUR_USERID = await getPrefrence(ID);

        var parameter = {ID: CUR_USERID};

        Response response =
            await post(getBoyDetailApi, body: parameter, headers: headers)
                .timeout(Duration(seconds: timeOut));

        var getdata = json.decode(response.body);
        bool error = getdata["error"];
        String? msg = getdata["message"];

        if (!error) {
          var data = getdata["data"][0];
          CUR_BALANCE = double.parse(data[BALANCE]).toStringAsFixed(2);
          CUR_BONUS = data[BONUS];
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
      if (mounted)
        setState(() {
          _isNetworkAvail = false;
          _isLoading = false;
        });
    }

    return null;
  }

  Future<void> acceptRejectOrder(String status,
      {required String orderId}) async {
    _isNetworkAvail = await isNetworkAvailable();

    if (_isNetworkAvail) {
      try {
        CUR_USERID = await getPrefrence(ID);
        CUR_USERNAME = await getPrefrence(USERNAME);

        if (CUR_USERID == null) {
          setSnackbar("User ID is missing");
          return;
        }

        var request = http.MultipartRequest(
          'POST',
          Uri.parse(
              'https://homeneedsyourplace.in/delivery_boy/app/v1/api/accept_order'),
        );

        request.fields.addAll({
          'user_id': CUR_USERID!,
          'order_id': orderId,
          'status': status,
        });

        print("Request Fields: ${request.fields}");

        request.headers.addAll({
          'Cookie': 'ci_session=9aa62c0e47342a0409b97926dcb0cefdc90f23c6',
          'Accept': 'application/json',
        });

        http.StreamedResponse response = await request.send();

        if (response.statusCode == 200) {
          String res = await response.stream.bytesToString();
          var getdata = json.decode(res);

          print("Response Data: $getdata");

          bool error = getdata["error"] ?? true;
          String? msg = getdata["message"];
          setSnackbar(msg!);

          _refresh();
          // total = int.tryParse(getdata["total"]?.toString() ?? '0') ?? 0;

          // if (!error && getdata["data"] != null) {
          //   if (offset! < total!) {
          //     tempList.clear();
          //     var data = getdata["data"];

          //     tempList = (data as List)
          //         .map((data) => Order_Model.fromJson(data))
          //         .toList();

          //     orderList.addAll(tempList);
          //     offset = offset! + perPage;
          //   }
          // }

          // if (mounted) {
          //   setState(() {
          //     _isLoading = false;
          //     isLoadingItems = false;
          //   });
          // }
        } else {
          print('Server error: ${response.reasonPhrase}');
          setSnackbar('Server Error');
          if (mounted) {
            setState(() {
              _isLoading = false;
              isLoadingItems = false;
            });
          }
        }
      } on TimeoutException catch (_) {
        setSnackbar(somethingMSg);
        if (mounted) {
          setState(() {
            _isLoading = false;
            isLoadingItems = false;
          });
        }
      }
    } else {
      if (mounted) {
        setState(() {
          _isNetworkAvail = false;
          _isLoading = false;
          isLoadingItems = false;
        });
      }
    }
  }

  setSnackbar(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(
        msg,
        textAlign: TextAlign.center,
        style: TextStyle(color: black),
      ),
      backgroundColor: white,
      elevation: 1.0,
    ));
  }

  Widget orderItem(int index) {
    Order_Model model = orderList[index];
    Color back;

    if (model.itemList != null &&
        model.itemList!.isNotEmpty &&
        (model.itemList![0].status!) == DELIVERD)
      back = Colors.green;
    else if (model.itemList != null &&
        model.itemList!.isNotEmpty &&
        (model.itemList![0].status!) == SHIPED)
      back = Colors.orange;
    else if (model.itemList != null &&
        model.itemList!.isNotEmpty &&
        ((model.itemList![0].status!) == CANCLED ||
            model.itemList![0].status! == RETURNED))
      back = Colors.red;
    else if (model.itemList != null &&
        model.itemList!.isNotEmpty &&
        (model.itemList![0].status!) == PROCESSED)
      back = Colors.indigo;
    else if (model.itemList != null &&
        model.itemList!.isNotEmpty &&
        model.itemList![0].status! == WAITING)
      back = Colors.black;
    else
      back = Colors.cyan;

    return Card(
      elevation: 0,
      margin: const EdgeInsets.all(5.0),
      child: InkWell(
        borderRadius: BorderRadius.circular(4),
        child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Text("Order No.${model.id!}"),
                        const Spacer(),
                        Container(
                          margin: const EdgeInsets.only(left: 8),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 2),
                          decoration: BoxDecoration(
                              color: back,
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(4.0))),
                          child: Text(
                            model.itemList == null || model.itemList!.isEmpty
                                ? '-'
                                : capitalize(model.itemList![0].status!),
                            style: const TextStyle(color: white),
                          ),
                        )
                      ],
                    ),
                  ),
                  Divider(),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8.0, vertical: 5),
                    child: Row(
                      children: [
                        Flexible(
                          child: Row(
                            children: [
                              const Icon(Icons.person, size: 14),
                              Expanded(
                                child: Text(
                                  model.name != null && model.name!.isNotEmpty
                                      ? " ${capitalize(model.name!)}"
                                      : " ",
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                        InkWell(
                          child: Row(
                            children: [
                              const Icon(
                                Icons.call,
                                size: 14,
                                color: fontColor,
                              ),
                              Text(
                                " ${model.mobile!}",
                                style: const TextStyle(
                                    color: fontColor,
                                    decoration: TextDecoration.underline),
                              ),
                            ],
                          ),
                          onTap: () {
                            _launchCaller(index);
                          },
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8.0, vertical: 5),
                    child: Row(
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.money, size: 14),
                            Text(
                                " Payable: ${CUR_CURRENCY!} ${model.payable!}"),
                          ],
                        ),
                        Spacer(),
                        Row(
                          children: [
                            const Icon(Icons.payment, size: 14),
                            Text(" ${model.payMethod!}"),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8.0, vertical: 5),
                    child: Row(
                      children: [
                        const Icon(Icons.date_range, size: 14),
                        Text(" Order on: ${model.orderDate!}"),
                      ],
                    ),
                  ),
                  model.deliveryBoyStatus == "1" ||
                          model.deliveryBoyStatus == "2"
                      ? Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8.0, vertical: 5),
                          child: Row(
                            children: [
                              const Icon(Icons.stacked_bar_chart_outlined,
                                  size: 14),
                              Text(
                                " Delivery Boy Status: ${model.deliveryBoyStatus == "1" ? "Accepted" : "Rejected"}",
                                style: TextStyle(
                                    color: model.deliveryBoyStatus == "1"
                                        ? Colors.green
                                        : Colors.red),
                              ),
                            ],
                          ),
                        )
                      : Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8.0, vertical: 5),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              InkWell(
                                onTap: () {
                                  acceptRejectOrder('1', orderId: model.id!);
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(5),
                                  width: 120,
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(20),
                                      color: Colors.green),
                                  child: Center(
                                    child: Text("Accept", //'Accept',
                                        style: const TextStyle(
                                            color: Colors.white)),
                                  ),
                                ),
                              ),
                              InkWell(
                                onTap: () {
                                  acceptRejectOrder('2', orderId: model.id!);
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(5),
                                  width: 120,
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(20),
                                      color: Colors.red),
                                  child: Center(
                                    child: Text("Reject", //'Accept',
                                        style: const TextStyle(
                                            color: Colors.white)),
                                  ),
                                ),
                              )
                            ],
                          ),
                        )
                ])),
        onTap: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => OrderDetail(model: orderList[index])),
          );
          setState(() {
            /* _isLoading = true;
             total=0;
             offset=0;
orderList.clear();*/
            getUserDetail();
          });
          // getOrder();
        },
      ),
    );
  }

  // void init() async {
  //   FirebaseMessaging.onMessage.listen(
  //     (message) {
  //       getOrder();
  //     },
  //   );
  // }
  void init() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Notification received: ${message.data}');
      getOrder();
      String orderId = message.data['order_id'] ?? '';
      String status = message.data['status'] ?? 'pending';
      if (orderId.isNotEmpty) {
        acceptRejectOrder(status, orderId: orderId);
      }
    });
  }

  _launchCaller(index) async {
    var url = "tel:${orderList[index].mobile}";
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  _detailHeader() {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: Card(
              elevation: 0,
              child: Padding(
                padding: const EdgeInsets.all(18.0),
                child: Column(
                  children: [
                    const Icon(
                      Icons.shopping_cart,
                      color: fontColor,
                    ),
                    Text(ORDER),
                    Text(
                      total.toString(),
                      style: const TextStyle(
                          color: fontColor, fontWeight: FontWeight.bold),
                    )
                  ],
                ),
              )),
        ),
        Expanded(
          flex: 3,
          child: Card(
            elevation: 0,
            child: Padding(
              padding: const EdgeInsets.all(18.0),
              child: Column(
                children: [
                  const Icon(
                    Icons.account_balance_wallet,
                    color: fontColor,
                  ),
                  Text(BAL_LBL),
                  Text(
                    "${CUR_CURRENCY!} $CUR_BALANCE",
                    style: const TextStyle(
                        color: fontColor, fontWeight: FontWeight.bold),
                  )
                ],
              ),
            ),
          ),
        ),
        Expanded(
          flex: 2,
          child: Card(
            elevation: 0,
            child: Padding(
              padding: const EdgeInsets.all(18.0),
              child: Column(
                children: [
                  const Icon(
                    Icons.wallet_giftcard,
                    color: fontColor,
                  ),
                  const Text(BONUS_LBL),
                  Text(
                    "${CUR_CURRENCY!} ${CUR_BONUS!}",
                    style: const TextStyle(
                        color: fontColor, fontWeight: FontWeight.bold),
                  )
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> getSetting() async {
    try {
      CUR_USERID = await getPrefrence(ID);

      var parameter = {TYPE: CURRENCY};

      Response response =
          await post(getSettingApi, body: parameter, headers: headers)
              .timeout(Duration(seconds: timeOut));
      if (response.statusCode == 200) {
        var getdata = json.decode(response.body);
        bool error = getdata["error"];
        String? msg = getdata["message"];
        if (!error) {
          CUR_CURRENCY = getdata["currency"];
        } else {
          setSnackbar(msg!);
        }
      }
    } on TimeoutException catch (_) {
      setSnackbar(somethingMSg);
    }
  }

  profileImage() {
    return Container(
      child: FutureBuilder(
          future: getupdateboy(CUR_USERID),
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            if (snapshot.hasData) {
              var data = snapshot.data.data;
              return data[0].proPic != null
                  ? Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: CircleAvatar(
                        radius: 40,
                        backgroundImage: NetworkImage(
                          "${snapshot.data.imgPath}${data[0].proPic}",
                        ),
                      ),
                    )
                  : Container(
                      margin: const EdgeInsets.only(top: 20, right: 20),
                      height: 64,
                      width: 64,
                      decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(width: 1.0, color: white)),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(100.0),
                        child: imagePlaceHolder(62),
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

  Future<GetBoUpdateModel?> getupdateboy(id) async {
    var header = headers;
    var request = http.MultipartRequest('POST', getDeliveryBoyDetailApi);
    request.fields.addAll({'id': '$id'});

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

  CollectionReference humanCollection =
      FirebaseFirestore.instance.collection("driverlocation");

  Future<void> updateDriverLocation(double latitude, double longitude) async {
    print("location store function Start===========");

    humanCollection.doc('$CUR_USERID').set({
      'lat': latitude,
      'long': longitude,
    }, SetOptions(merge: true));

    print("location store success===========");
  }

  late String lat;
  late String long;

  Position? currentLocation;

  Future getUserCurrentLocation() async {
    var status = await Permission.location.request();
    if (status.isDenied) {
    } else if (status.isGranted) {
      await Geolocator.getCurrentPosition(
              desiredAccuracy: LocationAccuracy.high)
          .then((position) {
        if (mounted)
          setState(() {
            currentLocation = position;
            lat = currentLocation!.latitude.toString();
            long = currentLocation!.longitude.toString();
          });
      });
      getOrder();

      //updateDriverLocation();
      // addData();
    } else if (status.isPermanentlyDenied) {
      openAppSettings();
    }
  }

  //
  // late Timer _timer;
  //
  void _startTimer() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    CUR_USERID = await getPrefrence(ID);
    _timer = Timer.periodic(Duration(minutes: 2), (timer) async {
      await getUserCurrentLocation();
    });
  }

  Timer? _timer;
  String? CUR_USERID;

  void updateLetLongTimer() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    CUR_USERID = prefs.getString('id');

    _timer = Timer.periodic(Duration(minutes: 1), (timer) async {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      double latitude = position.latitude;
      double longitude = position.longitude;
      updateDriverLocation(latitude, longitude);
      await updateLatLongApi(latitude, longitude);
    });
  }

  Future<void> updateLatLongApi(double lat, double long) async {
    var headers = {
      'Cookie': 'ci_session=5ad0a538404095e3cbf80e50bfb519c2996def5e'
    };

    var request = http.MultipartRequest(
      'POST',
      Uri.parse('https://homeneedsyourplace.in/app/v1/api/update_latlong'),
    );

    request.fields.addAll({
      'user_id': CUR_USERID ?? '',
      'latitude': lat.toString(),
      'longitude': long.toString(),
    });

    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      String res = await response.stream.bytesToString();
      print("API Success: $res");
    } else {
      print("API Error: ${response.reasonPhrase}");
    }
  }

// updateCurrentLocation() {
//   positionStream = Geolocator.getPositionStream(
//     locationSettings: const LocationSettings(
//       accuracy: LocationAccuracy.high,
//       distanceFilter:
//       1000, // Minimum change in distance (in meters) before update
//     ),
//   ).listen((Position position) async {
//     // Handle location update
//     double latitude = position.latitude;
//     double longitude = position.longitude;
//     // Your method to update the driver location
//     updateDriverLocation(
//       userId.toString(),
//       latitude,
//       longitude,
//     );
//   });
// }
//
// // @pragma('vm:entry-point')
// // Future<bool> onIosBackground(ServiceInstance service) async {
// //   log("----- error log --- ",error: "ngnkdfnkgkdf");
// //
// //   updateCurrentLocation();
// //   return true;
// // }
// //
// // @pragma('vm:entry-point')
// // void onStart(ServiceInstance service) async {
// //   updateCurrentLocation();
// // }
//
// StreamSubscription<Position>? positionStream;
// final FirebaseFirestore _firestore = FirebaseFirestore.instance;
}
