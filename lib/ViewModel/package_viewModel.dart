import 'package:uni_express/Model/DAO/index.dart';
import 'package:uni_express/Model/DTO/index.dart';
import 'package:uni_express/acessories/dialog.dart';
import 'package:uni_express/constraints.dart';
import 'package:uni_express/enums/view_status.dart';
import 'package:get/get.dart';
import 'base_model.dart';

class PackageViewModel extends BaseModel {
  PackageDTO package;
  ItemDTO itemDetail;
  BatchDAO _batchDAO;


  PackageViewModel() {
    _batchDAO = BatchDAO();
  }

  Future<void> getPackageDetail(int batchId, int packageId) async {
    try {
      setState(ViewStatus.Loading);
      package = await _batchDAO.getPackage(batchId, packageId);
      setState(ViewStatus.Completed);
    } catch (e, stracktrace) {
      bool result = await showErrorDialog();
      print(stracktrace);
      if (result) {
        await getPackageDetail(batchId, packageId);
      } else
        setState(ViewStatus.Error);
    }
  }
}
