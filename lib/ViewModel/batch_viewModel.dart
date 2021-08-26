import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:uni_express/Model/DAO/index.dart';
import 'package:uni_express/Model/DTO/index.dart';
import 'package:uni_express/ViewModel/base_model.dart';
import 'package:uni_express/ViewModel/beaner_package_viewModel.dart';
import 'package:uni_express/ViewModel/index.dart';
import 'package:uni_express/acessories/dialog.dart';
import 'package:uni_express/constraints.dart';
import 'package:uni_express/enums/view_status.dart';
import 'package:get/get.dart';
import 'package:uni_express/route_constraint.dart';
import 'package:uni_express/utils/shared_pref.dart';

class BatchViewModel extends BaseModel {
  List<BatchDTO> listBatch;
  ScrollController scrollController;
  BatchDAO _batchDAO;
  int selectedStatus;
  List<int> batchStatus;
  DateTimeRange timeRange;
  DateTime start, end;
  BatchDTO incomingBatch;
  static BatchViewModel _instance;

  static BatchViewModel getInstance() {
    if (_instance == null) {
      _instance = BatchViewModel();
    }
    return _instance;
  }

  static void destroyInstance() {
    _instance = null;
  }

  BatchViewModel() {
    _batchDAO = new BatchDAO();
    selectedStatus = -1;
    scrollController = ScrollController();
    scrollController.addListener(() async {
      if (scrollController.position.pixels ==
          scrollController.position.maxScrollExtent) {
        int total_page = (_batchDAO.metaDataDTO.total / DEFAULT_SIZE).ceil();
        if (total_page > _batchDAO.metaDataDTO.page) {
          await getMoreBatches();
        }
      }
    });
  }

  Future<void> getBatches() async {
    try {
      setState(ViewStatus.Loading);
      int role = await getRole();
      listBatch = (await _batchDAO.getBatches(selectedStatus, role));
      setState(ViewStatus.Completed);
    } catch (e, stacktrace) {
      setState(ViewStatus.Error);
    }
  }

  Future<void> getMoreBatches() async {
    try {
      setState(ViewStatus.LoadMore);
      int role = await getRole();
      listBatch += await _batchDAO.getBatches(selectedStatus, role,
          page: _batchDAO.metaDataDTO.page + 1);
      listBatch.removeWhere((element) => element.route == null);
      setState(ViewStatus.Completed);
    } catch (e) {
      bool result = await showErrorDialog();
      if (result) {
        await getMoreBatches();
      } else
        setState(ViewStatus.Error);
    }
  }

  Future<void> getIncomingBatch({int id}) async {
    try {
      setState(ViewStatus.Loading);
      int role = await getRole();
      int status;
      if (role == StaffRole.DRIVER) {
        status = BatchStatus.DRIVER_NOT_COMPLETED;
      } else {
        status = BatchStatus.BEANER_NEW;
      }
      List<BatchDTO> list = await _batchDAO.getBatches(status, role, id: id);
      if(list != null && list.isNotEmpty){
        incomingBatch = (await _batchDAO.getBatches(status, role, id: id))[0];
        setState(ViewStatus.Completed);
      }else{
        incomingBatch = null;
        setState(ViewStatus.Empty);
      }
    } catch (e, stacktrace) {
      setState(ViewStatus.Error);
      print(e.toString() + stacktrace.toString());
    }
  }

  Future<void> updateBatch() async {
    try {
      int result = await showOptionDialog("Xác nhận hoàn tất chuyến hàng?");
      if (result != 1) {
        return;
      }
      showLoadingDialog();
      int role = await getRole();
      await _batchDAO.putBatch(incomingBatch.routingBatchId, role);
      await showStatusDialog(
          "assets/images/global_sucsess.png", "Xác nhận thành công", "");
      Get.back(result: true);
    } on DioError catch (e) {
      if (e.response != null && e.response.statusCode == 400) {
        await showStatusDialog("assets/images/global_error.png",
            "${e.response.data['message']}", "");
        return;
      }
      bool result = await showErrorDialog();
      if (result) {
        await updateBatch();
      } else {
        setState(ViewStatus.Error);
      }
    }
  }

  void changeFilter(int value) {
    selectedStatus = value;
    getBatches();
  }

  Future<void> changeFilterTime() async {
    if (timeRange != null) {
      start = timeRange.start;
      end = timeRange.end;
    }
    bool result = await selectDateDialog(this, "Lọc theo ngày", "Xác nhận");
    if (result) {
      if (start == null) {
        timeRange = null;
      } else {
        if (end == null) {
          end = DateTime.now();
        }
        if (start.compareTo(end) > 0) {
          timeRange = DateTimeRange(start: end, end: start);
        } else {
          timeRange = DateTimeRange(start: start, end: end);
        }
      }
      getBatches();
    }
  }

  void setDate(Map<String, dynamic> form) {
    start = form['start'];
    end = form['end'];
  }
}
