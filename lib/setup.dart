import 'package:firebase_core/firebase_core.dart';
import 'package:uni_express/services/push_notification_service.dart';


Future setUp() async {
  // setStore(null);
  // setCart(null);
  await Firebase.initializeApp();
  PushNotificationService ps = PushNotificationService.getInstance();
  await ps.init();
}
