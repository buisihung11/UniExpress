import 'dart:io';

import 'package:connectivity/connectivity.dart';
import 'package:intl/intl.dart';

String formatPrice(double price) {
  return NumberFormat.simpleCurrency(locale: 'vi').format(price);
}

Future<bool> checkNetworkAvailable() async {
  var connectivityResult = await (Connectivity().checkConnectivity());
  if (connectivityResult == ConnectivityResult.none) {
    return false;
  } else {
    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        return true;
      }
    } on SocketException catch (_) {
      return false;
    }
  }
  return false;
}
