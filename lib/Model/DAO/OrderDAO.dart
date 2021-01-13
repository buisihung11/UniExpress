import 'package:uni_express/Model/DTO/index.dart';
import 'package:uni_express/utils/request.dart';
import '../../constraints.dart';

class OrderDAO {

  Future<List<OrderListDTO>> getStoreOrders(int storeId, int supplierId) async {
    final res = await request.get('stores/${storeId}/suppliers/$supplierId/orders',
        queryParameters: {"order-status": ORDER_NEW_STATUS});
    List<OrderListDTO> orderSummaryList;
    if (res.statusCode == 200) {
      orderSummaryList = OrderListDTO.fromList(res.data['data']);
      print("OK");
    }
    return orderSummaryList;
  }

  Future<OrderDTO> getStoreOrderDetail(int storeId, int supplierId, int orderId) async {
    final res = await request.get(
      'stores/$storeId/suppliers/$supplierId/orders/$orderId',
    );
    OrderDTO orderDetail;
    if (res.statusCode == 200) {
      orderDetail = OrderDTO.fromJSON(res.data['data']);
    }
    return orderDetail;
  }

  Future<List<OrderListDTO>> getCustomerOrders(int storeId) async {
    final res = await request.get('stores/$storeId/orders', queryParameters: {
      "from-date": "2020-11-02",
      // "to-date": "2020-12-12",
      "order-status": ORDER_NEW_STATUS
    });
    List<OrderListDTO> orderSummaryList;
    if (res.statusCode == 200) {
      orderSummaryList = OrderListDTO.fromList(res.data['data']);
      print("OK");
    }
    return orderSummaryList;
  }

  Future<OrderDTO> getCustomerOrderDetail(int storeId, int orderId) async {
    final res = await request.get(
      'stores/$storeId/orders/$orderId',
    );
    OrderDTO orderDetail;
    if (res.statusCode == 200) {
      orderDetail = OrderDTO.fromJSON(res.data['data']);
    }
    return orderDetail;
  }

  Future<void> putOrder(int storeId, int orderId, int status) async {
    await request
        .put('stores/$storeId/orders/${orderId}', data: status);

  }
}
