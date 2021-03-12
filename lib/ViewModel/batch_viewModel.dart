import 'package:flutter/material.dart';
import 'package:uni_express/Model/DAO/index.dart';
import 'package:uni_express/Model/DTO/index.dart';
import 'package:uni_express/ViewModel/base_model.dart';
import 'package:uni_express/acessories/dialog.dart';
import 'package:uni_express/constraints.dart';
import 'package:uni_express/enums/view_status.dart';
import 'package:get/get.dart';
import 'package:uni_express/route_constraint.dart';

class BatchViewModel extends BaseModel{

  // static BatchViewModel _instance;
  // static BatchViewModel getInstance() {
  //   if (_instance == null) {
  //     _instance = BatchViewModel();
  //   }
  //   return _instance;
  // }
  //
  // static void destroyInstance() {
  //   _instance = null;
  // }
  List<BatchDTO> listBatch;
  List<EdgeDTO> routes;
  ScrollController scrollController;
  BatchDAO _batchDAO;
  int selectedStatus;
  List<int> batchStatus = [-1, BatchStatus.PROCESSING, BatchStatus.SUCCESS];

  BatchViewModel(){
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
      listBatch = await _batchDAO.getBatches(selectedStatus);
      setState(ViewStatus.Completed);

    } catch (e, stacktrace) {
      print(stacktrace);
      bool result = await showErrorDialog();
      if (result) {
        await getBatches();
      } else
        setState(ViewStatus.Error);
    }
  }

  Future<void> getMoreBatches() async {
    try {
      setState(ViewStatus.LoadMore);
      listBatch += await _batchDAO.getBatches(selectedStatus, page: _batchDAO.metaDataDTO.page + 1);
      setState(ViewStatus.Completed);

    } catch (e) {
      bool result = await showErrorDialog();
      if (result) {
        await getMoreBatches();
      } else
        setState(ViewStatus.Error);
    }
  }

  void processBatch(BatchDTO batchDTO){
    if(batchDTO.status != BatchStatus.SUCCESS){
      showStatusDialog("assets/images/global_error.png", "ERROR", "Lô hàng chưa hoàn thành");
    }else{
      Get.toNamed(RouteHandler.ROUTE, arguments: batchDTO);
    }
  }

  void changeFilter(int value) {
    selectedStatus = value;
    getBatches();
  }

}