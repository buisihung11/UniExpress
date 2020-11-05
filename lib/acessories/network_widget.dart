import 'package:flutter/material.dart';
import 'package:uni_express/View/index.dart';
import 'package:uni_express/services/push_notification_service.dart';
import 'package:uni_express/utils/request.dart';
import 'package:uni_express/utils/shared_pref.dart';



Widget checkAuthorize() {
  PushNotificationService ps = PushNotificationService.getInstance();
  ps.init();
  // return token != null ? HomeScreen() : LoginScreen();
  return FutureBuilder(
    future: getToken(),
    builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
      // AccountDAO dao = AccountDAO();
      String token = snapshot.data;
      if (token != null) requestObj.setToken = token;
      // cho nay co can gui token lai cho server khong
      // neu khong thi lay thong tin user tu token ma thoi
      return token != null ? RootScreen() : LoginScreen();
    },
  );
}

