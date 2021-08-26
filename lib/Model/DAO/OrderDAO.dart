import 'package:uni_express/Model/DTO/index.dart';
import 'package:uni_express/utils/request.dart';
import '../../constraints.dart';

class OrderDAO {
  Future<List<OrderListDTO>> getStoreOrders(int storeId, int supplierId) async {
    final res = await request.get(
        'stores/${storeId}/suppliers/$supplierId/orders',
        queryParameters: {"order-status": ORDER_NEW_STATUS});
    List<OrderListDTO> orderSummaryList;
    if (res.statusCode == 200) {
      orderSummaryList = OrderListDTO.fromList(res.data['data']);
      print("OK");
    }
    return orderSummaryList;
  }

  Future<OrderDTO> getStoreOrderDetail(
      int storeId, int supplierId, int orderId) async {
    final res = await request.get(
      'stores/$storeId/suppliers/$supplierId/orders/$orderId',
    );
    OrderDTO orderDetail;
    if (res.statusCode == 200) {
      orderDetail = OrderDTO.fromJSON(res.data['data']);
    }
    return orderDetail;
  }

  Future<List<OrderListDTO>> getCustomerOrders(int batchId,
      [int orderStatus = ORDER_NEW_STATUS]) async {
    final res =
        await request.get('beaner/batchs/$batchId/orders', queryParameters: {
      // "from-date": "2020-11-02",
      // "to-date": "2020-12-12",
      "order-status": orderStatus
    });
    List<OrderListDTO> orderSummaryList;
    if (res.statusCode == 200) {
      orderSummaryList = OrderListDTO.fromList(res.data['data']);
      print("OK");
    }
    return orderSummaryList;
  }

  Future<OrderDTO> getCustomerOrderDetail(int batchId, int orderId) async {
    final res = await request.get(
      'beaner/batchs/$batchId/orders/$orderId',
    );
    OrderDTO orderDetail;
    if (res.statusCode == 200) {
      orderDetail = OrderDTO.fromJSON(res.data['data']);
    }
    return orderDetail;
  }

  Future<void> putOrder(int batchId, OrderDTO order, int status) async {
    await request.put('beaner/batchs/${batchId}/orders/${order.id}',
        data: {"status": status, "package_ids": order.packageIds});
  }
}
