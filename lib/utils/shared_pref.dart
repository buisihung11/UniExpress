import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:uni_express/Model/DTO/StoreDTO.dart';

Future<bool> setIsFirstOnboard(bool isFirstOnboard) async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.setBool('isFirstOnBoard', isFirstOnboard);
}

Future<bool> getIsFirstOnboard() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.getBool('isFirstOnBoard');
}

Future<bool> setFCMToken(String value) async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.setString('FCMToken', value);
}

Future<String> getFCMToken() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.getString('FCMToken');
}

Future<bool> setToken(String value) async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.setString('TOKEN', value);
}

Future<String> getToken() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.getString('TOKEN');
}

Future<void> setStore(StoreDTO dto) async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  if (dto != null) {
    prefs.setString('STORE', jsonEncode(dto?.toJson()));
  }
}

Future<StoreDTO> getStore() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  String encodedCart = prefs.getString('STORE');
  if (encodedCart != null) {
    return StoreDTO.fromJson(jsonDecode(encodedCart));
  }
  return null;
}

Future<bool> setRole(int value) async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.setInt('ROLE', value);
}

Future<int> getRole() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.getInt('ROLE');
}

Future<void> removeALL() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.clear();
  await setIsFirstOnboard(true);
}

// Future<bool> setUser(A value) async {
//   final SharedPreferences prefs = await SharedPreferences.getInstance();
//   return prefs.setString('token', value);
// }

// Future<String> getToken() async {
//   final SharedPreferences prefs = await SharedPreferences.getInstance();
//   return prefs.getString('token');
// }
