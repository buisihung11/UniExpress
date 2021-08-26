import 'package:dio/dio.dart';
import 'package:uni_express/Model/DAO/index.dart';
import 'package:uni_express/Model/DTO/index.dart';
import 'package:uni_express/ViewModel/batch_viewModel.dart';
import 'package:uni_express/acessories/dialog.dart';
import 'package:uni_express/constraints.dart';
import 'package:uni_express/enums/view_status.dart';
import 'package:get/get.dart';
import 'base_model.dart';
import "package:collection/collection.dart";

enum OrderFilter { ORDERING, DONE }
enum SearchFilter { ID, NAME, PHONE }

class SearchType {
  SearchFilter filter;
  String name;

  SearchType({this.filter, this.name});
}

class OrderHistoryViewModel extends BaseModel {
  List<OrderDTO> orderThumbnail;
  OrderDAO _orderDAO;
  dynamic error;
  OrderDTO orderDetail;
  List<SearchType> list = [
    SearchType(filter: SearchFilter.ID, name: "Mã hóa đơn"),
    SearchType(filter: SearchFilter.NAME, name: "Tên khách hàng"),
    SearchType(filter: SearchFilter.PHONE, name: "Số điện thoại"),
  ];
  SearchFilter selectedFilter = SearchFilter.ID, tmpFilter;
  bool isFilterDone = false, tmpStatus;
  int selectedLocationIndex, tmpLocationIndex;
  Map<int, List<OrderDTO>> cacheOrderThumbnail;

  OrderHistoryViewModel() {
    _orderDAO = OrderDAO();
  }

  Future<void> getStoreOrders(int storeId, int supplierId) async {
    try {
      setState(ViewStatus.Loading);
      final data = await _orderDAO.getStoreOrders(storeId, supplierId);
      if (data != null && data.isNotEmpty) {
        orderThumbnail = data[0].orders;
      } else {
        orderThumbnail = null;
      }
      setState(ViewStatus.Completed);
    } catch (e, stacktrace) {
      print(e.toString());
      bool result = await showErrorDialog();
      print(stacktrace);
      if (result) {
        await getStoreOrders(storeId, supplierId);
      } else
        setState(ViewStatus.Error);
    } finally {}
  }

  Future<void> getStoreOrderDetail(
      int storeId, int supplierId, int orderId) async {
    // get order detail
    try {
      setState(ViewStatus.Loading);
      orderDetail =
          await _orderDAO.getStoreOrderDetail(storeId, supplierId, orderId);

      setState(ViewStatus.Completed);
    } catch (e, stacktre) {
      bool result = await showErrorDialog();
      if (result) {
        await getStoreOrderDetail(storeId, supplierId, orderId);
      } else {
        setState(ViewStatus.Error);
        print(stacktre);
      }
    } finally {}
  }

  void searchOrderBy(String input) {
    if (input.isEmpty) {
      if (cacheOrderThumbnail != null && cacheOrderThumbnail.isNotEmpty) {
        orderThumbnail = getListOrders();
        notifyListeners();
      }
      return;
    }
    switch (selectedFilter) {
      case SearchFilter.ID:
        orderThumbnail = getListOrders().where((element) =>
                element.invoiceId.toUpperCase().contains(input.toUpperCase()))
            .toList();
        break;
      case SearchFilter.NAME:
        orderThumbnail = getListOrders().where((element) => element.customer.name
                .toUpperCase()
                .contains(input.toUpperCase()))
            .toList();
        break;
      case SearchFilter.PHONE:
        orderThumbnail = getListOrders().where((element) => element.customer.phone
                .toUpperCase()
                .contains(input.toUpperCase()))
            .toList();
        break;
    }
    notifyListeners();
  }

  List<OrderDTO> getListOrders(){
    List<OrderDTO> list = List();
    if(selectedLocationIndex == -1){
      cacheOrderThumbnail.values.forEach((element) {
        list.addAll(element);
      });
      return list;
    }
    return cacheOrderThumbnail.values.elementAt(selectedLocationIndex);
  }

  Future<void> getCustomerOrders() async {
    try {
      setState(ViewStatus.Loading);

      final data = await _orderDAO.getCustomerOrders(
        BatchViewModel.getInstance().incomingBatch.routingBatchId,
        isFilterDone ? ORDER_DONE_STATUS : ORDER_NEW_STATUS,
      );
      if (data != null && data.isNotEmpty) {
        selectedLocationIndex = -1;
        cacheOrderThumbnail =
            groupBy(data[0].orders, (OrderDTO order) => order.location.id);
        orderThumbnail = getListOrders();
      } else {
        selectedLocationIndex = null;
        cacheOrderThumbnail = null;
        orderThumbnail = [];
      }
      setState(ViewStatus.Completed);
    } catch (e, stackTrace) {
      bool result = await showErrorDialog();
      print(e.toString() + stackTrace.toString());
      if (result) {
        await getCustomerOrders();
      } else
        setState(ViewStatus.Error);
    } finally {}
  }

  Future<void> getCustomerOrderDetail(int orderId) async {
    // get order detail
    try {
      setState(ViewStatus.Loading);
      orderDetail = await _orderDAO.getCustomerOrderDetail(
          BatchViewModel.getInstance().incomingBatch.routingBatchId, orderId);
      setState(ViewStatus.Completed);
    } catch (e, stacktre) {
      bool result = await showErrorDialog();
      if (result) {
        await getCustomerOrderDetail(orderId);
      } else {
        setState(ViewStatus.Error);
        print(stacktre);
      }
    } finally {}
  }

  Future<void> putOrder() async {
    try {
      showLoadingDialog();
      await _orderDAO.putOrder(
          BatchViewModel.getInstance().incomingBatch.routingBatchId,
          orderDetail,
          ORDER_DONE_STATUS);
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
        await putOrder();
      } else
        setState(ViewStatus.Error);
    }
  }

  void prepareFilter() {
    tmpFilter = selectedFilter;
    tmpStatus = isFilterDone;
    tmpLocationIndex = selectedLocationIndex;
    notifyListeners();
  }

  void onChangeFilter({SearchFilter filter, bool status, int location}) {
    if (filter != null) {
      tmpFilter = filter;
    }
    if (status != null) {
      tmpStatus = status;
    }
    if (location != null) {
      tmpLocationIndex = location;
    }
    notifyListeners();
  }

  Future<void> updateFilter(String input) async {
    if (isFilterDone != tmpStatus) {
      isFilterDone = tmpStatus;
      await getCustomerOrders();
    }
    if (selectedFilter != tmpFilter) {
      selectedFilter = tmpFilter;
    }
    if (selectedLocationIndex != tmpLocationIndex && tmpLocationIndex != null) {
      selectedLocationIndex = tmpLocationIndex;
    }
    searchOrderBy(input);
    notifyListeners();
  }
}
