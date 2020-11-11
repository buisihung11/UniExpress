import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:uni_express/Model/DAO/index.dart';
import 'package:uni_express/Model/DTO/index.dart';
import 'package:uni_express/acessories/dialog.dart';
import 'package:uni_express/enums/view_status.dart';
import 'package:uni_express/services/analytic_service.dart';
import 'package:uni_express/services/firebase.dart';


import '../route_constraint.dart';
import 'base_model.dart';

class LoginViewModel extends BaseModel {
  static LoginViewModel _instance;
  AccountDAO dao = AccountDAO();
  String verificationId;
  AnalyticsService _analyticsService;
  String _phoneNb;
  static LoginViewModel getInstance() {
    if (_instance == null) {
      _instance = LoginViewModel();
    }
    return _instance;
  }

  static void destroyInstance() {
    _instance = null;
  }

  AccountDTO user;

  LoginViewModel() {
    _analyticsService = AnalyticsService.getInstance();
  }

  Future<AccountDTO> signIn(AuthCredential authCredential) async {
    try {
      // lay thong tin user tu firebase
      final userCredential = await AuthService().signIn(authCredential);

      await _analyticsService.logLogin(authCredential.signInMethod);
      // TODO: Thay uid = idToken
      String token = await userCredential.user.getIdToken();
      print("token: " + token);
      final userInfo = await dao.login(token);
      // await setToken(userInfo.toString());
      await _analyticsService.setUserProperties(userInfo);
      print("User: " + userInfo.toString());
      return userInfo;
    } catch (e) {
      bool result = await showErrorDialog();
      if (result) {
        await signIn(authCredential);
      } else
        setState(ViewStatus.Error);
    }
  }

  Future<void> signOut() async {
    await AuthService().signOut();
  }

  Future<void> onLoginWithPhone(String phone) async {
    _phoneNb = phone;
    Get.toNamed(RouteHandler.LOADING);
    final PhoneVerificationCompleted verificationCompleted =
        (AuthCredential authCredential) async {
      try {
        showLoadingDialog();
        final userInfo = await signIn(authCredential);
        userInfo.phone = _phoneNb;
        hideDialog();
        // TODO: Kiem tra xem user moi hay cu
        if (userInfo.isFirstLogin) {
          // Navigate to sign up screen
          await Get.offAllNamed(RouteHandler.SIGN_UP, arguments: userInfo);
        } else {
          await Get.offAllNamed(RouteHandler.STORE_ORDER);
          // chuyen sang trang home
        }
      } catch (e) {
        await showStatusDialog("assets/images/global_error.png",
            "Lỗi khi đăng nhập", e.toString());
        Get.back();
      }
      // dem authuser cho controller xu ly check user
    };

    final PhoneVerificationFailed verificationFailed =
        (FirebaseAuthException authException) async {
      print(
          "===== Dang nhap fail: ${authException.toString()} ${authException.message}");
      await showStatusDialog("assets/images/global_error.png", "Xảy ra lỗi",
          authException.message);
      Get.back();
    };

    final PhoneCodeSent phoneCodeSent =
        (String verId, [int forceResend]) async {
      await Get.offNamed(RouteHandler.LOGIN_OTP,
          arguments: {"verId": verId, "phoneNumber": phone});
    };

    final PhoneCodeAutoRetrievalTimeout phoneTimeout = (String verId) {
      verificationId = verId;
    };

    await FirebaseAuth.instance.verifyPhoneNumber(
      phoneNumber: phone,
      timeout: Duration(seconds: 30),
      verificationCompleted: verificationCompleted,
      verificationFailed: verificationFailed,
      codeSent: phoneCodeSent,
      codeAutoRetrievalTimeout: phoneTimeout,

    );
    print("Login Done");
  }

  Future<void> onSignInWithGmail() async {
    try {
      final authCredential = await AuthService().signInWithGoogle();
      if (authCredential == null) return;

      showLoadingDialog();
      return Get.offAllNamed(RouteHandler.STORE_ORDER);
    } on FirebaseAuthException catch (e) {
      print("=====OTP Fail: ${e.message}  ");
      await await showStatusDialog(
          "assets/images/global_error.png", "Error", e.message);
    } finally {
      hideDialog();
    }
  }

  Future<void> onsignInWithOTP(smsCode, verificationId) async {
    print("DN = OTP");
    showLoadingDialog();
    try {
      final authCredential =
          await AuthService().signInWithOTP(smsCode, verificationId);
      final userInfo = await signIn(authCredential);
      userInfo.phone = _phoneNb;
      print("User info: " + userInfo.toString());

      if (userInfo.isFirstLogin || userInfo.isFirstLogin == null) {
        // Navigate to sign up screen
        await Get.offAndToNamed(RouteHandler.SIGN_UP, arguments: userInfo);
      } else {
        Get.rawSnackbar(
            message: "Đăng nhập thành công!!",
            duration: Duration(seconds: 3),
            snackPosition: SnackPosition.BOTTOM,
            margin: EdgeInsets.only(left: 8, right: 8, bottom: 32),
            borderRadius: 8);
        await Get.offAllNamed(RouteHandler.STORE_ORDER);
      }
    } on FirebaseAuthException catch (e) {
      print("Error: " + e.toString());
      print("=====OTP Fail: ${e.message}  ");
      await showStatusDialog(
          "assets/images/global_error.png", "Error", e.message);
    } catch (e, strack) {
      print("Error: " + e.toString() + strack.toString());
      await showStatusDialog(
          "assets/images/global_error.png", "Error", e.toString());
    } finally {
      hideDialog();
    }
  }
}
