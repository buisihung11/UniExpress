import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:uni_express/View/DriverScreen/edge_detail.dart';
import 'package:uni_express/View/DriverScreen/list_batch.dart';
import 'package:uni_express/View/DriverScreen/route.dart';
import 'package:uni_express/View/RestaurantScreen/restaurant_screen.dart';
import 'package:uni_express/View/RestaurantScreen/store_order.dart';
import 'package:uni_express/View/RestaurantScreen/store_order_detail.dart';
import 'package:uni_express/route_constraint.dart';
import 'package:uni_express/setup.dart';
import 'package:uni_express/utils/pageNavigation.dart';
import 'package:uni_express/utils/request.dart';

import 'View/LoginScreen/LoginByPhone.dart';
import 'View/LoginScreen/LoginPhoneOTP.dart';
import 'View/CustomerScreen/customer_order.dart';
import 'View/index.dart';
import 'View/login.dart';
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
          case RouteHandler.STORE_ORDER_PRE:
            return CupertinoPageRoute<bool>(
                builder: (context) => CampusScreen(
                    navigationPath: RouteHandler.STORE_ORDER,
                    title: "Nhà hàng"),
                settings: settings);
          case RouteHandler.STORE_ORDER:
            return CupertinoPageRoute<bool>(
                builder: (context) => StoreOrderScreen(
                  store: settings.arguments,
                ),
                settings: settings);
          case RouteHandler.STORE_ORDER_RESTAURANT_MODE:
            return CupertinoPageRoute<bool>(
                builder: (context) => RestaurantScreen(
                      storeId: (settings.arguments as Map)["storeId"],
                      supplierId: (settings.arguments as Map)["supplierId"],
                      supplierName: (settings.arguments as Map)["supplierName"],
                    ),
                settings: settings);
          case RouteHandler.STORE_ORDER_DETAIL:
            StoreOrderDetailScreen storeOrderDetailScreen = settings.arguments;
            return CupertinoPageRoute<bool>(
                builder: (context) => StoreOrderDetailScreen(
                      supplier: storeOrderDetailScreen.supplier,
                      storeId: storeOrderDetailScreen.storeId,
                    ),
                settings: settings);
          case RouteHandler.CUSTOMER_ORDER_PRE: // List store screen
            return CupertinoPageRoute(
                builder: (context) => CampusScreen(
                      navigationPath: RouteHandler.CUSTOMER_ORDER,
                      title: "Giao hàng",
                    ),
                settings: settings);
          case RouteHandler.CUSTOMER_ORDER:
            return CupertinoPageRoute<bool>(
                builder: (context) =>
                    CustomerOrderScreen(store: settings.arguments),
                settings: settings);
          case RouteHandler.CUSTOMER_ORDER_DETAIL:
            return CupertinoPageRoute<bool>(
                builder: (context) => CustomerOrderDetail(
                      order: (settings.arguments as CustomerOrderDetail).order,
                      storeId: (settings.arguments as CustomerOrderDetail).storeId,
                    ),
                settings: settings);
          case RouteHandler.BATCH:
            return CupertinoPageRoute<bool>(
                builder: (context) => BatchScreen(
                    title: "Lấy hàng"),
                settings: settings);
          case RouteHandler.ROUTE:
            return CupertinoPageRoute<bool>(
                builder: (context) => RouteScreen(
                  batch: settings.arguments,
                ),
                settings: settings);
          case RouteHandler.EDGE:
            return CupertinoPageRoute<bool>(
                builder: (context) => EdgeScreen(
                  area: (settings.arguments as EdgeScreen).area,
                  actions: (settings.arguments as EdgeScreen).actions,
                  packages: (settings.arguments as EdgeScreen).packages,
                  title: (settings.arguments as EdgeScreen).title,
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
      home: StartUpView()
      // home: ProfileScreen(new AccountDTO(name: "Mít tơ Bin")),
    );
  }
}
