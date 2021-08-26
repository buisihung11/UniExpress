import 'dart:convert';

import 'package:barcode_widget/barcode_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:uni_express/Model/DAO/PackageDAO.dart';
import 'package:uni_express/Model/DAO/index.dart';
import 'package:uni_express/Model/DTO/index.dart';
import 'package:uni_express/acessories/dialog.dart';
import 'package:uni_express/constraints.dart';
import 'package:uni_express/enums/view_status.dart';
import 'package:get/get.dart';
import 'base_model.dart';

class PackageViewModel extends BaseModel {
  PackageDTO package;
  PackageDAO _packageDAO;
  EdgeDTO edge;
  Map<int, String> actions;
  List<PackageDTO> displayPackages;

  PackageViewModel({EdgeDTO edge}) {
    _packageDAO = PackageDAO();
    actions = Map();
    if (edge != null) {
      this.edge = edge;
      if (edge.packages
          .any((element) => element.actionType == ActionType.PICKUP)) {
        actions[ActionType.PICKUP] = "Túi Lấy";
      }
      if (edge.packages
          .any((element) => element.actionType == ActionType.DELIVERY)) {
        actions[ActionType.DELIVERY] = "Túi Giao";
      }
      displayPackages = edge.packages.where((element) => element.actionType == actions.keys.elementAt(0)).toList();
    }
  }

  Future<void> getPackageDetail(int batchId, int packageId) async {
    try {
      setState(ViewStatus.Loading);
      package = await _packageDAO.getPackage(batchId, packageId);
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

  Future generateQr(List<int> packages) async {
    try {
      List<Map<String, int>> listIds = packages.map((e) => {"package_id": e}).toList();
      await showWidgetDialog(
          BarcodeWidget(
            barcode: Barcode.qrCode(typeNumber: 3),
            data: jsonEncode(listIds),
            width: 200,
            height: 200,
            drawText: false,
          ),
          title: "Quét mã để xác thực");
    } catch (e, stacktrace) {
      print("Error: " + e.toString() + stacktrace.toString());
      showStatusDialog(
          "assets/images/global_error.png", "Xác thực thất bại 😲", "");
    }
  }

  Future<void> updatedPackagesForDriver(List<int> packages) async {
    try {
      showLoadingDialog();
      await _packageDAO.updatePackagesForDriver(packages);
      await showStatusDialog("assets/images/global_sucsess.png", "Cập nhật túi hàng thành công!", "");
      Get.back(result: true);
    } catch (e, stracktrace) {
      bool result = await showErrorDialog();
      print(stracktrace);
      if (result) {
        await updatedPackagesForDriver(packages);
      } else
        setState(ViewStatus.Error);
    }
  }

  void changeDisplayPackages(int value){
    displayPackages = edge.packages.where((element) => element.actionType == actions.keys.elementAt(value)).toList();
    notifyListeners();
  }

  void selectPackage(bool value, PackageDTO dto){
    dto.isSelected = value;
    notifyListeners();
  }

  bool enableUpdate(PackageDTO dto){
    if(dto.status == PackageStatus.NEW && displayPackages.every(
            (element) => element.actionType == ActionType.PICKUP)){
      return true;
    }else if (dto.status == PackageStatus.PICKEDUP && displayPackages.every(
            (element) => element.actionType == ActionType.DELIVERY)){
      return true;
    }return false;
  }
}
