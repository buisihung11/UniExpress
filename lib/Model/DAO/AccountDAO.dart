import 'package:dio/dio.dart';
import 'package:intl/intl.dart';
import 'package:uni_express/Model/DTO/index.dart';
import 'package:uni_express/services/firebase.dart';
import 'package:uni_express/services/push_notification_service.dart';
import 'package:uni_express/utils/request.dart';
import 'package:uni_express/utils/shared_pref.dart';

// TODO: Test Start_up Screen + FCM TOken

class AccountDAO {
  Future<AccountDTO> login(String idToken) async {
    try {
      String fcmToken =
          await PushNotificationService.getInstance().getFcmToken();

      Response response = await request
          .post("login", data: {"id_token": idToken, "fcm_token": fcmToken});

      // set access token
      final user = response.data["data"];
      final userDTO = AccountDTO.fromJson(user);
      final accessToken = user["access_token"] as String;
      print("accessToken    $accessToken");
      requestObj.setToken = accessToken;
      setToken(accessToken);
      return userDTO;
    } catch (e) {
      print("error: " + e.toString());
    }
    return null;
    // return AccountDTO(uid: idToken, name: "Default Name");
  }

  Future<AccountDTO> loginForStaff(String username, String password) async {
    print(username + "" + password);
    String fcmToken = await PushNotificationService.getInstance().getFcmToken();
    Response response = await request.post("admin/login-by-username", data: {
      "user_name": username,
      "password": password,
      "fcm_token": fcmToken
    });
    // set access token
    final user = response.data["data"];
    final userDTO = AccountDTO.fromJson(user);
    final accessToken = user["access_token"] as String;
    print("accessToken    $accessToken");
    requestObj.setToken = accessToken;
    setToken(accessToken);
    setRole(userDTO.role);
    return userDTO;
    // return AccountDTO(uid: idToken, name: "Default Name");
  }

  Future<int> isUserLoggedIn() async {
    final token = await getToken();
    if (token != null) {
      requestObj.setToken = token;
    }
    return await getRole();
  }

  Future<AccountDTO> getUser() async {
    Response response = await request.get("staffs/me");
    // set access token

    return AccountDTO.fromJson(response.data['data']);
    // return AccountDTO(uid: idToken, name: "Default Name");
  }

  Future<void> sendFeedback(String feedBack) async {
    await request.post("/me/feedback", data: "'$feedBack'");
  }

  Future<void> logOut() async {
    String fcmToken = await PushNotificationService.getInstance().getFcmToken();
    await AuthService().signOut();
    await request.post("/admin/logout", data: {"fcm_token": fcmToken});
  }

  Future<AccountDTO> updateUser(AccountDTO updateUser) async {
    Response res = await request.put("me", data: updateUser.toJson());
    return AccountDTO.fromJson(res.data["data"]);
  }

  Future<ReportDTO> getReport() async {
    try {
      DateTime current = DateTime.now();
      Map<String, dynamic> map = {
        "from": DateFormat("yyyy-MM-dd").parse("${current.year}-${current.month}-${current.day}").toIso8601String(),
        "to": DateFormat("yyyy-MM-dd HH:mm").parse("${current.year}-${current.month}-${current.day} 23:59").toIso8601String(),
      };
      Response res = await request.get("driver/report", queryParameters: map);
      return ReportDTO.fromJson(res.data);
    } catch (e) {
      return null;
    }
  }
}
