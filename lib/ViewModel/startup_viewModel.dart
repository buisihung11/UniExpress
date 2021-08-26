import 'package:get/get.dart';
import 'package:uni_express/Model/DAO/index.dart';
import 'package:uni_express/View/layout.dart';
import 'package:uni_express/services/push_notification_service.dart';
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
    int role = await _accountDAO.isUserLoggedIn();
    if (role != null) {
      Get.offAndToNamed(RouteHandler.HOME, arguments: Layout(role: role,));
    } else {
      Get.offAndToNamed(RouteHandler.LOGIN);
    }
  }
}
