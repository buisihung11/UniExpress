import 'package:dio/dio.dart';
import 'package:uni_express/Model/DTO/index.dart';
import 'package:uni_express/ViewModel/orderHistory_viewModel.dart';
import 'package:uni_express/enums/order_status.dart';
import 'package:uni_express/utils/request.dart';
import 'package:uni_express/utils/shared_pref.dart';

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

  // TODO: nen dep cart ra ngoai truyen vao parameter
  Future<OrderStatus> createOrders(
      String note, int store_id, int payment) async {
    try {
      Cart cart = await getCart();
      if (cart != null) {
        // print("Request Note: " + note);
        cart.orderNote = note;
        cart.payment = payment;
        print(cart.toJsonAPi());
        final res = await request.post('/orders',
            queryParameters: {"brand-id": UNIBEAN_BRAND, "store-id": store_id},
            data: cart.toJsonAPi());
        if (res.statusCode == 200) {
          return OrderStatus.Success;
        }
      }
    } on DioError catch (e) {
      if (e.response.statusCode == 400) {
        print("Code: " + e.response.data['code'].toString());
        if (e.response.data['code'] == 'ERR_BALANCE')
          return OrderStatus.NoMoney;
        return OrderStatus.Timeout;
      }
      return OrderStatus.Fail;
    }
    return OrderStatus.Fail;
  }
}
