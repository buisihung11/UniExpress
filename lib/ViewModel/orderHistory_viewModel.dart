import 'package:uni_express/Model/DAO/index.dart';
import 'package:uni_express/Model/DTO/index.dart';
import 'package:uni_express/acessories/dialog.dart';
import 'package:uni_express/constraints.dart';
import 'package:uni_express/enums/view_status.dart';
import 'package:get/get.dart';
import 'base_model.dart';

enum OrderFilter { ORDERING, DONE }
enum SearchFilter { ID, NAME, PHONE }

class SearchType {
  SearchFilter filter;
  String name;

  SearchType({this.filter, this.name});
}

class OrderHistoryViewModel extends BaseModel {
  List<OrderListDTO> orderThumbnail;
  OrderDAO _orderDAO;
  dynamic error;
  OrderDTO orderDetail;
  List<OrderListDTO> cacheOrderThumbnail;
  List<SearchType> list = [
    SearchType(filter: SearchFilter.ID, name: "Mã hóa đơn"),
    SearchType(filter: SearchFilter.NAME, name: "Tên khách hàng"),
    SearchType(filter: SearchFilter.PHONE, name: "Số điện thoại"),
  ];
  SearchFilter selectedFilter = SearchFilter.ID;

  OrderHistoryViewModel() {
    setState(ViewStatus.Loading);
    _orderDAO = OrderDAO();
  }

  Future<void> getOrders(OrderFilter filter) async {
    try {
      setState(ViewStatus.Loading);
      final data = await _orderDAO.getOrders(filter);

      orderThumbnail = data;

      setState(ViewStatus.Completed);
    } catch (e) {
      bool result = await showErrorDialog();
      print(e.toString());
      if (result) {
        await getOrders(filter);
      } else
        setState(ViewStatus.Error);
    } finally {}
  }

  Future<void> getStoreOrders(int storeId) async {
    try {
      setState(ViewStatus.Loading);
      final data = await _orderDAO.getStoreOrders(storeId);
      orderThumbnail = data;
      setState(ViewStatus.Completed);
    } catch (e) {
      bool result = await showErrorDialog();
      print(e.toString());
      if (result) {
        await getStoreOrders(storeId);
      } else
        setState(ViewStatus.Error);
    } finally {}
  }

  Future<void> getOrderDetail(int orderId) async {
    // get order detail
    try {
      setState(ViewStatus.Loading);
      final data = await _orderDAO.getOrderDetail(orderId);
      orderDetail = data;
      setState(ViewStatus.Completed);
    } catch (e) {
      bool result = await showErrorDialog();
      if (result) {
        await getOrderDetail(orderId);
      } else
        setState(ViewStatus.Error);
    } finally {}
  }

  Future<void> getStoreOrderDetail(int storeId, int orderId) async {
    // get order detail
    try {
      setState(ViewStatus.Loading);
      final data = await _orderDAO.getStoreOrderDetail(storeId, orderId);
      orderDetail = data;
      setState(ViewStatus.Completed);
    } catch (e, stacktre) {
      bool result = await showErrorDialog();
      if (result) {
        await getOrderDetail(orderId);
      } else {
        setState(ViewStatus.Error);
        print(stacktre);
      }
    } finally {}
  }

  void normalizeOrders(List<OrderDTO> orders) {}

  void searchOrderByPhone(String input) {
    orderThumbnail = List();
    switch (selectedFilter) {
      case SearchFilter.ID:
        cacheOrderThumbnail.forEach((element) {
          List<OrderDTO> listOrder = element.orders
              .where((order) =>
                  order.invoiceId.toUpperCase().contains(input.toUpperCase()))
              .toList();
          if (listOrder != null && listOrder.isNotEmpty) {
            orderThumbnail.add(element);
            orderThumbnail.last.orders = listOrder;
          }
        });
        break;
      case SearchFilter.NAME:
        cacheOrderThumbnail.forEach((element) {
          List<OrderDTO> listOrder = element.orders
              .where((order) => order.customer.name
                  .toUpperCase()
                  .contains(input.toUpperCase()))
              .toList();
          if (listOrder != null && listOrder.isNotEmpty) {
            orderThumbnail.add(element);
            orderThumbnail.last.orders = listOrder;
          }
        });
        break;
      case SearchFilter.PHONE:
        cacheOrderThumbnail.forEach((element) {
          List<OrderDTO> listOrder = element.orders
              .where((order) => order.customer.phone
                  .toUpperCase()
                  .contains(input.toUpperCase()))
              .toList();
          if (listOrder != null && listOrder.isNotEmpty) {
            orderThumbnail.add(element);
            orderThumbnail.last.orders = listOrder;
          }
        });
        break;
    }
    notifyListeners();
  }

  void showAll() {
    if (cacheOrderThumbnail != null && cacheOrderThumbnail.isNotEmpty) {
      orderThumbnail = cacheOrderThumbnail;
      notifyListeners();
    }
  }

  Future<void> getCustomerOrders(int storeId) async {
    try {
      setState(ViewStatus.Loading);
      final data = await _orderDAO.getCustomerOrders(storeId);
      orderThumbnail = data;
      cacheOrderThumbnail = orderThumbnail;
      setState(ViewStatus.Completed);
    } catch (e, strcke) {
      bool result = await showErrorDialog();
      print(strcke);
      if (result) {
        await getCustomerOrders(storeId);
      } else
        setState(ViewStatus.Error);
    } finally {}
  }

  Future<void> getCustomerOrderDetail(int storeId, int orderId) async {
    // get order detail
    try {
      setState(ViewStatus.Loading);
      final data = await _orderDAO.getCustomerOrderDetail(storeId, orderId);
      orderDetail = data;
      setState(ViewStatus.Completed);
    } catch (e, stacktre) {
      bool result = await showErrorDialog();
      if (result) {
        await getCustomerOrderDetail(storeId, orderId);
      } else {
        setState(ViewStatus.Error);
        print(stacktre);
      }
    } finally {}
  }

  Future<void> putOrder() async {
    try {
      showLoadingDialog();
      await _orderDAO.putOrder(orderDetail.id, ORDER_DONE_STATUS);
      await showStatusDialog(
          "assets/images/global_sucsess.png", "Xác nhận thành công", "");
      Get.back(result: true);
    } catch (e) {
      bool result = await showErrorDialog();
      if (result) {
        await putOrder();
      } else
        setState(ViewStatus.Error);
    }
  }

  void changeSearchFilter(SearchFilter filter) {
    selectedFilter = filter;
    notifyListeners();
  }
}
