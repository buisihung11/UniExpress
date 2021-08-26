import 'dart:convert';

import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:uni_express/Model/DAO/BatchDAO.dart';
import 'package:uni_express/Model/DAO/PackageDAO.dart';
import 'package:uni_express/Model/DTO/index.dart';
import 'package:uni_express/ViewModel/base_model.dart';
import 'package:uni_express/ViewModel/batch_viewModel.dart';
import 'package:uni_express/acessories/dialog.dart';
import 'package:uni_express/enums/view_status.dart';
import "package:collection/collection.dart";
import '../constraints.dart';

class BeanerPackageViewModel extends BaseModel {
  BatchDAO _batchDAO;
  PackageDAO _packageDAO;
  int selectedAreaIndex, selectedStatus;
  Map<int, List<PackageDTO>> packagesOfArea;
  List<PackageDTO> displayedPackages;
  List<int> packageStatus = [-1, PackageStatus.NEW, PackageStatus.DELIVERIED];

  BeanerPackageViewModel() {
    _batchDAO = BatchDAO();
    _packageDAO = PackageDAO();
    selectedStatus = -1;
    selectedAreaIndex = -1;
  }

  Future<void> getPackages() async {
    try {
      setState(ViewStatus.Loading);
      if (BatchViewModel.getInstance().incomingBatch == null) {
        await BatchViewModel.getInstance().getIncomingBatch();
      }
      if (BatchViewModel.getInstance().status == ViewStatus.Error) {
        setState(ViewStatus.Error);
      } else {
        List<PackageDTO> packages = await _batchDAO.getPackages(BatchViewModel.getInstance().incomingBatch.routingBatchId);
        if (packages != null) {
          packagesOfArea =
              groupBy(packages, (PackageDTO item) => item.toLocation.id);
          displayedPackages = getCurrentPackages();
          setState(ViewStatus.Completed);
        }
      }
    } catch (e, stacktrace) {
      print(e.toString() + stacktrace.toString());
      setState(ViewStatus.Error);
    }
  }

  void changeArea(value) {
    selectedAreaIndex = value;
    displayedPackages = getCurrentPackages();
    notifyListeners();
  }

  void changeStatus(int status) {
    selectedStatus = status;
    displayedPackages = getCurrentPackages();
    notifyListeners();
  }

  List<PackageDTO> getCurrentPackages(){
    if(selectedAreaIndex != -1){
      if(selectedStatus != -1){
        if(selectedStatus != PackageStatus.DELIVERIED){
          return packagesOfArea.values.elementAt(selectedAreaIndex).where((element) => element.status != PackageStatus.DELIVERIED).toList();
        }
        return packagesOfArea.values.elementAt(selectedAreaIndex).where((element) => element.status == PackageStatus.DELIVERIED).toList();
      }
      return packagesOfArea.values.elementAt(selectedAreaIndex);
    }
    List<PackageDTO> packages = List();
    packagesOfArea.values.forEach((element) {
      packages.addAll(element);
    });
    if(selectedStatus != -1){
      if(selectedStatus != PackageStatus.DELIVERIED){
        return packages.where((element) => element.status != PackageStatus.DELIVERIED).toList();
      }
      return packages.where((element) => element.status == PackageStatus.DELIVERIED).toList();
    }
    return packages;
  }

  void selectPackage(bool value, PackageDTO dto) {
    dto.isSelected = value;
    notifyListeners();
  }

  Future scanQR() async {
    try {
      String barcode = await FlutterBarcodeScanner.scanBarcode(
          "#ff6666", "Hủy", true, ScanMode.QR);
      List listIds = jsonDecode(barcode);
      print(listIds.toString());
      if (listIds != null && listIds.isNotEmpty) {
        showLoadingDialog();
        List<int> packages =
            listIds.map((e) => e['package_id']).toList().cast<int>();
        await _packageDAO.updatePackagesForBeaner(packages);
        await showStatusDialog(
            "assets/images/global_sucsess.png", "Xác thực thành công 😎", "");
        getPackages();
      } else {
        if (barcode != "-1")
          showStatusDialog("assets/images/global_error.png",
              "Mã túi không chính xác 😲", "");
      }
    } catch (e) {
      print(e.toString());
      showStatusDialog(
          "assets/images/global_error.png", "Xác thực thất bại 😲", "");
    }
  }
}
