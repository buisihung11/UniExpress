

import 'package:uni_express/Model/DAO/index.dart';
import 'package:uni_express/Model/DTO/index.dart';
import 'package:uni_express/acessories/dialog.dart';
import 'package:uni_express/enums/view_status.dart';

import 'base_model.dart';

enum OrderFilter { ORDERING, DONE }

class OrderHistoryViewModel extends BaseModel {
  List<OrderListDTO> orderThumbnail;
  OrderDAO _orderDAO;
  dynamic error;
  OrderDTO orderDetail;

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
    } catch (e) {
      bool result = await showErrorDialog();
      if (result) {
        await getOrderDetail(orderId);
      } else
        setState(ViewStatus.Error);
    } finally {}
  }


  void normalizeOrders(List<OrderDTO> orders) {}
}
