import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:uni_express/Model/DTO/index.dart';

class AnalyticsService {
  final FirebaseAnalytics _analytics = FirebaseAnalytics();
  static AnalyticsService _instance;

  static AnalyticsService getInstance() {
    if (_instance == null) {
      _instance = AnalyticsService();
    }
    return _instance;
  }

  static void destroyInstance() {
    _instance = null;
  }

  FirebaseAnalyticsObserver getAnalyticsObserver() =>
      FirebaseAnalyticsObserver(analytics: _analytics);

  // User properties tells us what the user is
  // Future setUserProperties(AccountDTO user) async {
  //   await _analytics.setUserId(user.uid.toString());
  //   await _analytics.setUserProperty(name: 'name', value: user.name,);
  //   await _analytics.setUserProperty(name: 'sex', value: user.gender,);
  //   await _analytics.setUserProperty(name: 'birthdate', value: user.birthdate.toString(),);
  //   // property to indicate if it's a pro paying member
  //   // property that might tell us it's a regular poster, etc
  // }

  Future logLogin(String method) async {
    print("LOG_LOGIN");
    await _analytics.logLogin(loginMethod: method);
  }

  Future logSignUp(String method) async {
    await _analytics.logSignUp(signUpMethod: method);
  }

  // Select a product from a list
  Future logViewItem(ProductDTO product) async {
    await _analytics.logViewItem(
      itemId: product.id.toString(),
      itemName: product.name,
      itemCategory: product.catergoryId.toString(),
    );
    print("Loged order");
  }

  // View product details
  // Add/remove a product from a shopping cart
  Future logChangeCart(ProductDTO product, int quantity, bool isAdd) async {
    if (isAdd) {
      await _analytics.logAddToCart(
          itemId: product.id.toString(),
          itemName: product.name,
          itemCategory: product.catergoryId.toString(),
          quantity: quantity);
    } else {
      await _analytics.logRemoveFromCart(
        itemId: product.id.toString(),
        itemName: product.name,
        itemCategory: product.catergoryId.toString(),
        quantity: quantity,
      );
    }

    print("Loged order");
  }

  // Initiate the checkout process
  Future logBeginCheckout(double value) async {
    await _analytics.logBeginCheckout(value: value, currency: "VND");
  }

  // Make purchases or refunds
  Future logOrderCreated(double value) async {
    await _analytics.logEcommercePurchase(value: value, currency: "VND");
    print("Loged order");
  }
  // Apply promotions

}
