import 'package:get/get.dart';
import 'package:package_info/package_info.dart';
import 'package:uni_express/Model/DAO/index.dart';
import 'package:uni_express/Model/DTO/index.dart';
import 'package:uni_express/acessories/dialog.dart';
import 'package:uni_express/enums/view_status.dart';
import 'package:uni_express/utils/shared_pref.dart';
import '../route_constraint.dart';
import 'index.dart';

class AccountViewModel extends BaseModel {
  AccountDAO _dao;
  AccountDTO currentUser;
  static AccountViewModel _instance;
  String version;

  static AccountViewModel getInstance() {
    if (_instance == null) {
      _instance = AccountViewModel();
    }
    return _instance;
  }

  static void destroyInstance() {
    _instance = null;
  }

  AccountViewModel() {
    _dao = AccountDAO();
    fetchUser();
  }

  Future<void> fetchUser() async {
    try {
      if (status != ViewStatus.Loading) {
        setState(ViewStatus.Loading);
      }
      final user = await _dao.getUser();
      currentUser = user;

      String token = await getToken();
      print(token.toString());

      if (version == null) {
        PackageInfo packageInfo = await PackageInfo.fromPlatform();
        version = packageInfo.version;
      }

      setState(ViewStatus.Completed);
    } catch (e) {
      bool result = await showErrorDialog();
      if (result) {
        await fetchUser();
      } else
        setState(ViewStatus.Error);
    }
  }

  Future<void> sendFeedback() async {
    try {
      String feedback =
          await inputDialog("Bạn cho mình xin feedback nha 🤗", "Gửi thôi 💛");
      if (feedback != null && feedback.isNotEmpty) {
        showLoadingDialog();
        await _dao.sendFeedback(feedback);
        await showStatusDialog("assets/images/option.png", "Cảm ơn bạn",
            "Feedback của bạn sẽ giúp tụi mình cải thiện app tốt hơn 😊");
      }
    } catch (e, stacktrace) {
      print(e.toString() + stacktrace.toString());
      bool result = await showErrorDialog();
      if (result) {
        await sendFeedback();
      } else
        setState(ViewStatus.Error);
    }
  }

  Future<void> processSignout() async {
    int option = await showOptionDialog("Mình sẽ nhớ bạn lắm ó huhu :'(((");
    if (option == 1) {
      await _dao.logOut();
      await removeALL();
      destroyInstance();
      RootViewModel.destroyInstance();
      Get.offAllNamed(RouteHandler.LOGIN);
    }
  }
}
