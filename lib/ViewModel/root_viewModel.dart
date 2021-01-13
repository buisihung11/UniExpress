import 'package:get/get.dart';
import 'package:uni_express/Model/DAO/StoreDAO.dart';
import 'package:uni_express/Model/DAO/SupplierDAO.dart';
import 'package:uni_express/Model/DAO/index.dart';
import 'package:uni_express/Model/DTO/StoreDTO.dart';
import 'package:uni_express/Model/DTO/index.dart';
import 'package:uni_express/acessories/dialog.dart';
import 'package:uni_express/enums/view_status.dart';
import 'package:uni_express/services/analytic_service.dart';
import 'package:uni_express/utils/shared_pref.dart';
import '../route_constraint.dart';
import 'base_model.dart';

class RootViewModel extends BaseModel {
  AccountDAO _dao;
  AccountDTO currentUser;
  String error;
  static RootViewModel _instance;
  AnalyticsService _analyticsService;

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
    _analyticsService = AnalyticsService.getInstance();
    setState(ViewStatus.Loading);
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

  Future<void> getSuppliersFromStore(int storeId) async {
    try {
      setState(ViewStatus.Loading);
      SupplierDAO dao = new SupplierDAO();
      listSupplier = await dao.getSuppliersFromStore(storeId);
      setState(ViewStatus.Completed);
    } catch (e) {
      bool result = await showErrorDialog();
      if (result) {
        await getSuppliersFromStore(storeId);
      } else
        setState(ViewStatus.Error);
    }
  }

  Future<void> getStores(int supId) async {
    try {
      setState(ViewStatus.Loading);
      StoreDAO dao = new StoreDAO();
      listStore = await dao.getStores(supId);
      setState(ViewStatus.Completed);
    } catch (e) {
      bool result = await showErrorDialog();
      if (result) {
        await getStores(supId);
      } else
        setState(ViewStatus.Error);
    }
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
