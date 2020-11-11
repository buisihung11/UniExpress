import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:uni_express/View/store_order.dart';
import 'package:uni_express/View/store_order_detail.dart';
import 'package:uni_express/route_constraint.dart';
import 'package:uni_express/setup.dart';
import 'package:uni_express/utils/pageNavigation.dart';
import 'package:uni_express/utils/request.dart';

import 'View/LoginScreen/LoginByPhone.dart';
import 'View/LoginScreen/LoginPhoneOTP.dart';
import 'View/customer_order.dart';
import 'View/gift.dart';
import 'View/login.dart';
import 'View/notFoundScreen.dart';
import 'View/profile.dart';
import 'View/signup.dart';
import 'View/start_up.dart';
import 'constraints.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  HttpOverrides.global = new MyHttpOverrides();

  await setUp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    return GetMaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case RouteHandler.LOGIN_PHONE:
            return CupertinoPageRoute(
                builder: (context) => LoginWithPhone(), settings: settings);
          case RouteHandler.LOGIN_OTP:
            Map map = settings.arguments;
            return CupertinoPageRoute(
                builder: (context) => LoginWithPhoneOTP(
                  phoneNumber: map["phoneNumber"],
                  verificationId: map["verId"],
                ),
                settings: settings);
          case RouteHandler.LOGIN:
            return ScaleRoute(page: LoginScreen());
          case RouteHandler.GIFT:
            return CupertinoPageRoute(
                builder: (context) => GiftScreen(), settings: settings);
        // case RouteHandler.ORDER_DETAIL:
        //   return CupertinoPageRoute(
        //       builder: (context) => OrderDetailScreen(), settings: settings);
          case RouteHandler.ORDER_HISTORY:
            return CupertinoPageRoute(
                builder: (context) => OrderHistoryScreen(), settings: settings);
          case RouteHandler.PROFILE:
            return CupertinoPageRoute(
                builder: (context) => ProfileScreen(), settings: settings);
          case RouteHandler.SIGN_UP:
            return CupertinoPageRoute<bool>(
                builder: (context) => SignUp(
                  user: settings.arguments,
                ),
                settings: settings);
          case RouteHandler.LOADING:
            return CupertinoPageRoute<bool>(
                builder: (context) => LoadingScreen(
                  title: settings.arguments ?? "Đang xử lý...",
                ),
                settings: settings);
          case RouteHandler.STORE_ORDER:
            return CupertinoPageRoute<bool>(
                builder: (context) => StoreOrderScreen(
                ),
                settings: settings);
          case RouteHandler.STORE_ORDER_DETAIL:
            return CupertinoPageRoute<bool>(
                builder: (context) => StoreOrderDetailScreen(
                  store: settings.arguments,
                ),
                settings: settings);
          default:
            return CupertinoPageRoute(
                builder: (context) => NotFoundScreen(), settings: settings);
        }
      },
      theme: ThemeData(
        fontFamily: 'Gotham',
        primarySwatch: Colors.green,
        primaryColor: kPrimary,
        scaffoldBackgroundColor: Color(0xFFF0F2F5),
        toggleableActiveColor: kPrimary,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: StartUpView(),
      // home: ProfileScreen(new AccountDTO(name: "Mít tơ Bin")),
    );
  }
}

