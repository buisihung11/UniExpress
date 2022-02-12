import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:uni_express/Model/DAO/index.dart';
import 'package:uni_express/Model/DTO/index.dart';
import 'package:uni_express/View/layout.dart';
import 'package:uni_express/acessories/dialog.dart';
import 'package:uni_express/route_constraint.dart';
import 'package:uni_express/utils/shared_pref.dart';

import '../constraints.dart';

class PushNotificationService {
  static PushNotificationService _instance;

  static PushNotificationService getInstance() {
    if (_instance == null) {
      _instance = PushNotificationService();
    }
    return _instance;
  }

  static void destroyInstance() {
    _instance = null;
  }

  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  bool _initialized = false;

  Future init() async {
    if (!_initialized) {
      if ((defaultTargetPlatform == TargetPlatform.iOS)) {
        await _fcm.requestPermission();
        _fcm.setForegroundNotificationPresentationOptions(
            alert: true, badge: true, sound: true);
      }
      // TODO: Fix this
      FirebaseMessaging.onMessage.listen((event) {
        RemoteNotification notification = event.notification;
        handleNotificationDisplay(message);
      });
      _fcm.configure(
        //Called when the app is in the foreground and we receive a push notification
        onMessage: (Map<String, dynamic> message) async {
          print('onMessage: $message');
          handleNotificationDisplay(message);
        },
        //Called when the app has been closed completely and its opened
        onLaunch: (Map<String, dynamic> message) async {
          print('onLaunch: $message');
          Timer.periodic(Duration(milliseconds: 500), (timer) {
            if (Get.key.currentState == null) return;
            handelNoti(message);
            timer.cancel();
          });
          handelNoti(message);
        },
        //Called when the app is in the background
        onResume: (Map<String, dynamic> message) async {
          print('onResume: $message');
          handelNoti(message);
        },
      );
      _initialized = true;
    }
  }

  Future<void> handleNotificationDisplay(Map<String, dynamic> message) async {
    hideDialog();
    hideSnackbar();
    switch (message["data"]["Action"]) {
      case RouteHandler.PACAKGE:
      case RouteHandler.HOME:
        await showStatusDialog(
            "assets/images/global_sucsess.png",
            Platform.isIOS
                ? message['aps']['alert']['title']
                : message['notification']['title'],
            Platform.isIOS
                ? message['aps']['alert']['body']
                : message['notification']['body']);
        handelNoti(message);
        break;
      default:
        Get.snackbar(
            Platform.isIOS
                ? message['aps']['alert']['title']
                : message['notification']['title'], // title
            Platform.isIOS
                ? message['aps']['alert']['body']
                : message['notification']['body'],
            colorText: kPrimary,
            shouldIconPulse: true,
            backgroundColor: kBackgroundGrey[0],
            isDismissible: true,
            duration: Duration(minutes: 1),
            mainButton: TextButton(
              child: Text(
                "OK",
                style: TextStyle(color: kPrimary),
              ),
              onPressed: () {
                hideSnackbar();
              },
            ));
    }
  }

  Future<void> handelNoti(Map<String, dynamic> message) async {
    hideDialog();
    switch (message["data"]["Action"]) {
      case RouteHandler.PACAKGE:
        switch (Get.currentRoute) {
          case RouteHandler.EDGE:
            Get.back(result: true);
            break;
          case RouteHandler.PACAKGE:
            Get.back();
            Get.back(result: true);
            break;
          case RouteHandler.ROUTE:
            Map<String, dynamic> map = jsonDecode(message["data"]["Argument"]);
            Get.offNamed(RouteHandler.ROUTE,
                arguments: BatchDTO.fromJson(map["bean_batch_model"]));
            break;
          default:
            Map<String, dynamic> map = jsonDecode(message["data"]["Argument"]);
            Get.toNamed(RouteHandler.ROUTE,
                arguments: BatchDTO.fromJson(map["bean_batch_model"]));
        }
        break;
      case RouteHandler.HOME:
        Map<String, dynamic> map = jsonDecode(message["data"]["Argument"]);
        int role = await getRole();
        if (role != null) {
          Get.offAllNamed(RouteHandler.HOME,
              arguments: Layout(
                role: role,
                batchId: map["routing_batch_id"],
              ));
        }
        break;
    }
  }

  Future<String> getFcmToken() async {
    String token = await _fcm.getToken();
    print("FirebaseMessaging token: $token");
    return token;
  }
}
