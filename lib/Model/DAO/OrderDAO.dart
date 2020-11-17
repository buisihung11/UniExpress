import 'package:uni_express/Model/DTO/index.dart';
import 'package:uni_express/ViewModel/orderHistory_viewModel.dart';
import 'package:uni_express/utils/request.dart';
import '../../constraints.dart';

class OrderDAO {
  Future<List<OrderListDTO>> getOrders(OrderFilter filter) async {
    final res = await request.get('/orders', queryParameters: {
      "delivery-status":
          filter == OrderFilter.ORDERING ? ORDER_NEW_STATUS : ORDER_DONE_STATUS
    });
    List<OrderListDTO> orderSummaryList;
    if (res.statusCode == 200) {
      orderSummaryList = OrderListDTO.fromList(res.data['data']);
    }
    return orderSummaryList;
  }

  Future<OrderDTO> getOrderDetail(int orderId) async {
    final res = await request.get(
      '/orders/$orderId',
    );
    OrderDTO orderDetail;
    if (res.statusCode == 200) {
      orderDetail = OrderDTO.fromJSON(res.data['data']);
    }
    return orderDetail;
  }

  Future<List<OrderListDTO>> getStoreOrders(int storeId) async {
    final res = await request.get('/stores/${storeId}/orders',
        queryParameters: {"delivery-status": ORDER_NEW_STATUS});
    List<OrderListDTO> orderSummaryList;
    if (res.statusCode == 200) {
      orderSummaryList = OrderListDTO.fromList(res.data['data']);
      print("OK");
    }
    return orderSummaryList;
  }

  Future<OrderDTO> getStoreOrderDetail(int storeId, int orderId) async {
    final res = await request.get(
      '/stores/$storeId/orders/$orderId',
    );
    OrderDTO orderDetail;
    if (res.statusCode == 200) {
      orderDetail = OrderDTO.fromJSON(res.data['data']);
    }
    return orderDetail;
  }

  Future<List<OrderListDTO>> getCustomerOrders(int storeId) async {
    final res = await request.get('/orders', queryParameters: {
      "from-date": "2020-11-02",
      "to-date": "2020-12-12",
      "delivery-status": ORDER_NEW_STATUS
    });
    List<OrderListDTO> orderSummaryList;
    if (res.statusCode == 200) {
      orderSummaryList = OrderListDTO.fromList(res.data['data']);
      print("OK");
    }
    return orderSummaryList;
  }

  Future<OrderDTO> getCustomerOrderDetail(int orderId) async {
    final res = await request.get(
      '/orders/$orderId',
    );
    OrderDTO orderDetail;
    if (res.statusCode == 200) {
      orderDetail = OrderDTO.fromJSON(res.data['data']);
    }
    return orderDetail;
  }

  Future<void> putOrder(int orderId, int status) async {
    final res = await request
        .put('/orders/${orderId}', data: {"delivery_status": status});
  }
}
