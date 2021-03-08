import 'package:get/get.dart';
import 'package:uni_express/Model/DAO/index.dart';
import 'package:uni_express/Model/DTO/index.dart';
import 'package:uni_express/acessories/dialog.dart';
import 'package:uni_express/enums/view_status.dart';
import 'package:uni_express/utils/shared_pref.dart';
import '../route_constraint.dart';
import 'base_model.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class RootViewModel extends BaseModel {
  AccountDAO _dao;
  AccountDTO currentUser;
  String error;
  Map<String, LatLng> suppliers = {
    "Đầm Sen": LatLng(10.766311624602196, 106.64190483025601),
    "Bến Thành": LatLng(10.772815186731581, 106.69830011594244),
    "FPT University": LatLng(10.84203783147812, 106.80930917241754),
    "Suối Tiên": LatLng(10.866104142943794, 106.8030719020283),
  };


  static RootViewModel _instance;


  static RootViewModel getInstance() {
    if (_instance == null) {
      _instance = RootViewModel();
    }
    return _instance;
  }

  static void destroyInstance() {
    _instance = null;
  }

  List<StoreDTO> listStore;
  List<SupplierDTO> listSupplier;

  RootViewModel() {
    _dao = AccountDAO();


    fetchUser();
  }

  Future<void> fetchUser() async {
    try {
      setState(ViewStatus.Loading);
      final user = await _dao.getUser();
      currentUser = user;
      setState(ViewStatus.Completed);
    } catch (e) {
      bool result = await showErrorDialog();
      if (result) {
        await fetchUser();
      } else
        setState(ViewStatus.Error);
    } finally {}
  }

  Future<void> signOut() async {
    await _dao.logOut();
    await removeALL();
  }

  Future<void> processSignout() async {
    int option = await showOptionDialog("Mình sẽ nhớ bạn lắm ó huhu :'(((");
    if (option == 1) {
      await signOut();
      Get.offAllNamed(RouteHandler.LOGIN);
    }
    destroyInstance();
  }

  Future<void> getVirtualStores() async {
    try {
      setState(ViewStatus.Loading);
      StoreDAO dao = new StoreDAO();
      listStore = await dao.getVirtualStores();
      setState(ViewStatus.Completed);
    } catch (e) {
      bool result = await showErrorDialog();
      if (result) {
        await getVirtualStores();
      } else
        setState(ViewStatus.Error);
    }
  }

}
