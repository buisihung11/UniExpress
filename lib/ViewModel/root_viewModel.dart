import 'package:uni_express/Model/DAO/index.dart';
import 'package:uni_express/Model/DTO/index.dart';
import 'package:uni_express/acessories/dialog.dart';
import 'package:uni_express/enums/view_status.dart';
import 'base_model.dart';

class RootViewModel extends BaseModel {
  String error;

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

  RootViewModel() {}

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
      } else {
        setState(ViewStatus.Error);
      }
    }
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
      } else {
        setState(ViewStatus.Error);
      }
    }
  }
}
