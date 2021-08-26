import 'package:flutter/material.dart';

const kPrimary = Color(0xFF4fba6f);
final kSecondary = Color(0xFF438029);
final kSuccess = Colors.green;
final kFail = Colors.red;
final kBean = Color(0xffffe844);
final kBackgroundGrey = [
  Color(0xFFFFFFFF),
  Color(0xfffafafa),
  Color(0xfff5f5f5),
  Color(0xffe0e0e0),
  Color(0xffbdbdbd),
  Color(0xff9e9e9e),
  Color(0xff757575),
];
final kGreyTitle = Color(0xFF575757);

final kTextPrimary = TextStyle(color: Color(0xFFFFFFFF));
final kTextSecondary = TextStyle(color: kPrimary);

// Colors
const kTextColor = Color(0xFF0D1333);
const kBlueColor = Color(0xFF6E8AFA);
const kBestSellerColor = Color(0xFFFFD073);
const kGreenColor = Color(0xFF49CC96);

// My Text Styles
const kHeadingextStyle = TextStyle(
  fontSize: 28,
  color: kTextColor,
  fontWeight: FontWeight.bold,
);

const kSubheadingextStyle = TextStyle(
  fontSize: 24,
  color: Color(0xFF61688B),
  height: 2,
);

const kTitleTextStyle = TextStyle(
  fontSize: 20,
  color: kTextColor,
  fontWeight: FontWeight.bold,
);

const kSubtitleTextStyle = TextStyle(
  fontSize: 18,
  color: kTextColor,
  // fontWeight: FontWeight.bold,
);

const kDescriptionTextSyle = TextStyle(
  fontSize: 14,
  color: Color(0xffa7b4ce),
  fontWeight: FontWeight.bold,
);

const String CART_TAG = "cartTag";

const double DELIVERY_FEE = 5000;
const UNIBEAN_STORE = 150;
const UNIBEAN_BRAND = 10;
const double DIALOG_ICON_SIZE = 60;
const String defaultImage =
    "https://mcnewsmd1.keeng.net/netnews/archive/images/2020052200/tinngan_120240_510965964_20wap_320.jpg";
const String TIME = "12:10";
const String VERSION = "0.0.1";
const TEST_STORE = 69;
const int ORDER_NEW_STATUS = 1;
const int ORDER_DONE_STATUS = 3;
const int VIRTUAL_STORE_TYPE = 8;
const int DEFAULT_SIZE = 20;
const String MAP_KEY = "AIzaSyCme39Qpilr_NIsHPzxthtOulUSMx-54_Q";

class ProductType {
  static const int EXTRA_PRODUCT = 5;
  static const int MASTER_PRODUCT = 6;
  static const int DETAIL_PRODUCT = 7;
  static const int COMPLEX_PRODUCT = 10;
  static const int GIFT_PRODUCT = 12;
}

class PaymentType {
  static const int CASH = 1;
  static const int WALLET = 3;

  static Map<int, String> options = {
    PaymentType.CASH: "Tiền mặt",
    PaymentType.WALLET: "Tiền trong ví"
  };

  static String getPaymentName(int type) {
    return options[type] ?? "N/A";
  }
}

class BatchStatus {
  static const int DRIVER_COMPLETED = 0;
  static const int DRIVER_NOT_COMPLETED = 1;
  static const int BEANER_COMPLETED = 3;
  static const int BEANER_NEW = 2;
}

class PackageStatus {
  static const int NEW = 1;
  static const int PICKEDUP = 2;
  static const int DELIVERIED = 3;
}

class ActionType {
  static const int PICKUP = 0;
  static const int DELIVERY = 1;
}

class StaffRole {
  static const int DRIVER = 2;
  static const int BEANER = 4;
}
