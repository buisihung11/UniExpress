import 'package:get/get.dart';
import 'package:uni_express/Model/DAO/index.dart';
import 'package:uni_express/utils/shared_pref.dart';

import '../route_constraint.dart';
import 'base_model.dart';

class StartUpViewModel extends BaseModel {
  static StartUpViewModel _instance;

  static StartUpViewModel getInstance() {
    if (_instance == null) {
      _instance = StartUpViewModel();
    }
    return _instance;
  }

  static void destroyInstance() {
    _instance = null;
  }

  StartUpViewModel() {
    handleStartUpLogic();
  }

  Future handleStartUpLogic() async {
    AccountDAO _accountDAO = AccountDAO();
    // Register for push notifications
    // await _pushNotificationService.initialise();
    await Future.delayed(Duration(seconds: 5));
    var hasLoggedInUser = await _accountDAO.isUserLoggedIn();
    if (hasLoggedInUser) {
      Get.offAndToNamed(RouteHandler.BATCH);
    } else {
      Get.offAndToNamed(RouteHandler.LOGIN);
    }
  }
}
