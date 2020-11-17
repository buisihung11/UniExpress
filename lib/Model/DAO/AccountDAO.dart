import 'package:dio/dio.dart';
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
      print("FCM_token: " + fcmToken);
      print('idToken $idToken');

      Response response = await request
          .post("/login", data: {"id_token": idToken, "fcm_token": fcmToken});



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

  Future<bool> isUserLoggedIn() async {
    final token = await getToken();
    if (token != null) requestObj.setToken = token;
    return token != null;
  }

  Future<AccountDTO> getUser() async {
    Response response = await request.get("/me");
    // set access token
    final user = response.data["data"];

    return AccountDTO.fromJson(user);
    // return AccountDTO(uid: idToken, name: "Default Name");
  }

  Future<void> logOut() async {
    await AuthService().signOut();
  }

  Future<AccountDTO> updateUser(AccountDTO updateUser) async {
    final updateJSON = updateUser.toJson();
    print('updateUser');
    print(updateJSON.toString());
    Response res = await request.put("/me", data: updateUser.toJson());
    return AccountDTO.fromJson(res.data["data"]);
  }
}
