import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:uni_express/Model/DTO/index.dart';
import 'package:uni_express/View/customer_order_detail.dart';
import 'package:uni_express/ViewModel/index.dart';
import 'package:uni_express/acessories/appbar.dart';
import 'package:uni_express/acessories/loading.dart';
import 'package:uni_express/enums/view_status.dart';
import 'package:uni_express/route_constraint.dart';
import 'package:uni_express/utils/index.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../constraints.dart';

class CustomerOrderScreen extends StatefulWidget {
  CustomerOrderScreen({Key key, @required this.store}) : super(key: key);
  StoreDTO store;

  @override
  _CustomerOrderScreenState createState() =>
      _CustomerOrderScreenState();
}

class _CustomerOrderScreenState extends State<CustomerOrderScreen> {
  OrderHistoryViewModel model = OrderHistoryViewModel();
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      new GlobalKey<RefreshIndicatorState>();
  TextEditingController _editingController = new TextEditingController();

  @override
  void initState() {
    super.initState();
    orderHandler();
  }

  Future<void> refreshFetchOrder() async {
    _editingController.clear();
    await model.getCustomerOrders(widget.store.id);
  }

  Future<void> orderHandler() async {
    _editingController.clear();
    model.getCustomerOrders(widget.store.id);
  }

  @override
  Widget build(BuildContext context) {
    return ScopedModel<RootViewModel>(
      model: RootViewModel.getInstance(),
      child: Scaffold(
        appBar: DefaultAppBar(
          title: widget.store.name,
        ),
        body: ScopedModel<OrderHistoryViewModel>(
          model: model,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _searchBar(),
              selectSearchType(),
              Expanded(
                child: Container(
                  child: _buildOrders(),
                  color: Color(0xffefefef),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _searchBar() {
    return ScopedModelDescendant<OrderHistoryViewModel>(builder:
        (BuildContext context, Widget child, OrderHistoryViewModel model) {
      return TextFormField(
        controller: _editingController,
        decoration: InputDecoration(
            prefixIcon: Icon(
              Icons.search,
              color: Colors.black,
            ),
            suffixIcon: IconButton(
              icon: Icon(Icons.clear, color: Colors.black),
              onPressed: () {
                _editingController.clear();
                model.showAll();
              },
            ),
            contentPadding: EdgeInsets.only(left: 15.0, top: 15.0),
            hintText: 'Nhập vào đây để tìm',
            hintStyle: TextStyle(color: Colors.orange)),
        onFieldSubmitted: (String input) {
          if (input.trim().isNotEmpty) {
            model.searchOrderByPhone(input);
            // model.getEventResult(input);
          }
        },
      );
    });
  }

  Widget _buildOrders() {
    return ScopedModelDescendant<OrderHistoryViewModel>(
        builder: (context, child, model) {
      final status = model.status;
      final orderSummaryList = model.orderThumbnail;
      if (status == ViewStatus.Loading)
        return Center(
          child: LoadingBean(),
        );
      else if (status == ViewStatus.Empty || orderSummaryList == null)
        return Container(
          child: SvgPicture.asset(
            'assets/images/order_history.svg',
            semanticsLabel: 'Acme Logo',
            fit: BoxFit.cover,
          ),
        );
      if (status == ViewStatus.Error)
        return Center(
          child: AspectRatio(
            aspectRatio: 1 / 4,
            child: Image.asset(
              'assets/images/error.png',
              width: 24,
            ),
          ),
        );

      return RefreshIndicator(
        key: _refreshIndicatorKey,
        onRefresh: refreshFetchOrder,
        child: Container(
          child: ListView(
            padding: EdgeInsets.all(8),
            children: [
              ...orderSummaryList
                  .map((orderSummary) => _buildOrderSummary(orderSummary))
                  .toList(),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Center(
                  child: Text(
                    "Bạn đã xem hết rồi đây :)",
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildOrderSummary(OrderListDTO orderSummary) {
    DateTime orderDate = DateTime.parse(orderSummary.checkInDate);
    DateTime today = DateTime.now();
    bool isToday = false;

    if (orderDate.year == today.year &&
        orderDate.month == today.month &&
        orderDate.day == today.day) {
      isToday = true;
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        isToday
            ? Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Text(
                  "Tổng số đơn hôm nay: " +
                      orderSummary.orders.length.toString(),
                  style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              )
            : Container(),
        Padding(
          padding: const EdgeInsets.only(left: 24, bottom: 16),
          child: Text(
            DateFormat('dd/MM/yyyy').format(orderDate),
            style: TextStyle(
              color: kSecondary,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
        ),
        ...orderSummary.orders.reversed
            .toList()
            .map((order) => _buildOrderItem(order, context))
            .toList(),
      ],
    );
  }

  Widget _buildOrderItem(OrderDTO order, BuildContext context) {
    return Container(
      // height: 80,
      margin: EdgeInsets.fromLTRB(8, 0, 8, 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: Colors.white,
      ),
      child: Material(
        color: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
          // side: BorderSide(color: Colors.red),
        ),
        child: Column(
          children: [
            ListTile(
              onTap: () async {
                await _settingModalBottomSheet(widget.store.id, order);
              },
              contentPadding: EdgeInsets.fromLTRB(16, 8, 16, 8),
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "${order.invoiceId}",
                    style: TextStyle(
                        fontSize: 16,
                        color: Colors.black,
                        fontWeight: FontWeight.bold),
                  ),
                  SizedBox(
                    height: 8,
                  ),
                  Text(
                    "KH: " + order.customer.name,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  SizedBox(
                    height: 4,
                  ),
                  Text(
                    order.customer.phone,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
              trailing: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "${formatPrice(order.finalAmount)}",
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      color: kPrimary,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
            // Text("Chi tiết", style: TextStyle(color: Colors.blue)),
          ],
        ),
      ),
    );
  }

  Future<void> _settingModalBottomSheet(int storeId, order) async {
    // get orderDetail
    bool result = await Get.toNamed(
      RouteHandler.CUSTOMER_ORDER_DETAIL,
      arguments: CustomerOrderDetailArguments(order, storeId),
    );
    if (result != null && result) {
      await refreshFetchOrder();
    }
  }

  Widget selectSearchType() {
    return ScopedModelDescendant<OrderHistoryViewModel>(
      builder:
          (BuildContext context, Widget child, OrderHistoryViewModel model) {
        if (model.list != null && model.list.isNotEmpty) {
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(
                  "Tìm kiếm theo:",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(
                  width: 10,
                ),
                DropdownButton(
                  hint: new Text("Select a cast"),
                  value: model.selectedFilter,
                  items: model.list
                      .map((e) => DropdownMenuItem(
                          value: e.filter, child: Text(e.name)))
                      .toList(),
                  onChanged: (value) {
                    _editingController.clear();
                    model.showAll();
                    model.changeSearchFilter(value);
                  },
                ),
              ],
            ),
          );
        }
        return Container();
      },
    );
  }
}
