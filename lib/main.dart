import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:uni_express/View/DriverScreen/route.dart';
import 'package:uni_express/View/RestaurantScreen/restaurant_screen.dart';
import 'package:uni_express/View/RestaurantScreen/store_order.dart';
import 'package:uni_express/View/RestaurantScreen/store_order_detail.dart';
import 'package:uni_express/View/batch_history.dart';
import 'package:uni_express/View/layout.dart';
import 'package:uni_express/View/role_view.dart';
import 'package:uni_express/route_constraint.dart';
import 'package:uni_express/setup.dart';
import 'package:uni_express/utils/pageNavigation.dart';
import 'package:uni_express/utils/request.dart';
import 'View/BeanerScreen/customer_order.dart';
import 'View/BeanerScreen/customer_order_detail.dart';
import 'View/index.dart';
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
        debugShowCheckedModeBanner: false,
        onGenerateRoute: (settings) {
          switch (settings.name) {
            case RouteHandler.LOGIN:
              return ScaleRoute(page: LoginScreen());
            case RouteHandler.PROFILE:
              return CupertinoPageRoute(
                  builder: (context) => ProfileScreen(), settings: settings);
            // case RouteHandler.SIGN_UP:
            //   return CupertinoPageRoute<bool>(
            //       builder: (context) => SignUp(
            //             user: settings.arguments,
            //           ),
            //       settings: settings);
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
                        supplierName:
                            (settings.arguments as Map)["supplierName"],
                      ),
                  settings: settings);
            case RouteHandler.STORE_ORDER_DETAIL:
              StoreOrderDetailScreen storeOrderDetailScreen =
                  settings.arguments;
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
                      CustomerOrderScreen(),
                  settings: settings);
            case RouteHandler.CUSTOMER_ORDER_DETAIL:
              return CupertinoPageRoute<bool>(
                  builder: (context) => CustomerOrderDetail(
                        order:
                            (settings.arguments as CustomerOrderDetail).order,
                      ),
                  settings: settings);
            case RouteHandler.DRIVE_BATCH:
              return CupertinoPageRoute<bool>(
                  builder: (context) => BatchScreen(batchId: settings.arguments),
                  settings: settings);
            case RouteHandler.BEANER_BATCH:
              return CupertinoPageRoute<bool>(
                  builder: (context) => BeanerHomeScreen(
                        batchId: settings.arguments,
                      ),
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
                        edge: (settings.arguments as EdgeScreen).edge,
                        batch: (settings.arguments as EdgeScreen).batch,
                      ),
                  settings: settings);
            case RouteHandler.PACAKGE:
              return CupertinoPageRoute<bool>(
                  builder: (context) => PackageDetailScreen(
                        packageId: (settings.arguments as PackageDetailScreen)
                            .packageId,
                        batchId:
                            (settings.arguments as PackageDetailScreen).batchId,
                        driver:
                            (settings.arguments as PackageDetailScreen).driver,
                      ),
                  settings: settings);
            case RouteHandler.HOME:
              return CupertinoPageRoute<bool>(
                  builder: (context) => Layout(
                        role: (settings.arguments as Layout).role,
                        batchId: (settings.arguments as Layout).batchId,
                      ),
                  settings: settings);
            case RouteHandler.ROLE:
              return CupertinoPageRoute<bool>(
                  builder: (context) => RoleScreen(), settings: settings);
            case RouteHandler.BATCH_HISTORY:
              return CupertinoPageRoute<bool>(
                  builder: (context) => BatchHistoryScreen(
                        title: "Lịch sử chuyến hàng",
                        role: settings.arguments,
                      ),
                  settings: settings);
            default:
              return CupertinoPageRoute(
                  builder: (context) => NotFoundScreen(), settings: settings);
          }
        },
        theme: ThemeData(
          fontFamily: 'Nunito',
          primarySwatch: Colors.green,
          primaryColor: kPrimary,
          textTheme: TextTheme(
            headline1: TextStyle(fontSize: 72.0, fontWeight: FontWeight.bold),
            headline6: TextStyle(fontSize: 36.0, fontStyle: FontStyle.italic),
            bodyText2: TextStyle(fontSize: 14.0),
          ),
          // scaffoldBackgroundColor: Color(0xFFF0F2F5),
          toggleableActiveColor: kPrimary,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: StartUpView()
        // home: ProfileScreen(new AccountDTO(name: "Mít tơ Bin")),
        );
  }
}
