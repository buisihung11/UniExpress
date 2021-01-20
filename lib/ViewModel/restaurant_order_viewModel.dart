import 'package:uni_express/Model/DAO/index.dart';
import 'package:uni_express/Model/DTO/index.dart';
import 'package:uni_express/ViewModel/base_model.dart';
import 'package:uni_express/ViewModel/index.dart';
import 'package:uni_express/acessories/dialog.dart';
import 'package:uni_express/enums/view_status.dart';

class RestaurantOrderViewModel extends BaseModel {
  int storeId;
  int supplierId;

  int _currentIndex = 0;
  OrderListDTO orderList;
  OrderDTO currentOrderSummary;
  OrderDTO currentOrderDetail;

  OrderDAO _orderDAO;

  RestaurantOrderViewModel(storeId, supplierId) {
    this.storeId = storeId;
    this.supplierId = supplierId;
    setState(ViewStatus.Loading);
    _orderDAO = OrderDAO();
    getStoreOrders();
  }

  Future<void> processChangeIndex() async {
    currentOrderSummary = orderList.orders.elementAt(_currentIndex);
    // get that order summnary detail
    try {
      setState(ViewStatus.Loading);
      currentOrderDetail = await _orderDAO.getStoreOrderDetail(
          storeId, supplierId, currentOrderSummary.id);

      setState(ViewStatus.Completed);
    } catch (e, stacktre) {
      bool isTryAgain = await showErrorDialog();
      if (isTryAgain) {
        await processChangeIndex();
      } else {
        setState(ViewStatus.Error);
        print(stacktre);
      }
    } finally {}
  }

  void nextOrder() {
    _currentIndex =
        _currentIndex < orderList.orders.length - 1 ? _currentIndex + 1 : 0;
    processChangeIndex();
  }

  void completeOrder() {
    orderList.orders.elementAt(_currentIndex).isCompleted = true;
    nextOrder();
  }

  void preOrder() {
    _currentIndex =
        _currentIndex > 0 ? _currentIndex - 1 : orderList.orders.length - 1;
    processChangeIndex();
  }

  Future<void> getStoreOrders() async {
    try {
      setState(ViewStatus.Loading);
      final data =
          await _orderDAO.getStoreOrders(this.storeId, this.supplierId);
      if (data.length != 0) {
        _currentIndex = 0;
        orderList = data[0];
        processChangeIndex();
      }
      setState(ViewStatus.Completed);
    } catch (e, stracktrace) {
      bool isTryAgain = await showErrorDialog();
      print(stracktrace);
      if (isTryAgain) {
        await getStoreOrders();
      } else
        setState(ViewStatus.Error);
    } finally {}
  }

  int get orderLeftQuanitity {
    if (orderList?.orders == null) return 0;
    return orderList?.orders?.where((element) => !element.isCompleted).length ??
        0;
  }
}
