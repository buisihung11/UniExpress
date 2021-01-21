import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:uni_express/Model/DTO/index.dart';
import 'package:uni_express/ViewModel/index.dart';
import 'package:uni_express/acessories/appbar.dart';
import 'package:uni_express/acessories/dash_border.dart';
import 'package:uni_express/acessories/loading.dart';
import 'package:uni_express/enums/view_status.dart';
import 'package:uni_express/route_constraint.dart';
import 'package:uni_express/utils/index.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:url_launcher/url_launcher.dart';

import '../constraints.dart';

class StoreOrderDetailScreen extends StatefulWidget {
  StoreOrderDetailScreen({Key key, @required this.supplier, this.storeId})
      : super(key: key);
  SupplierDTO supplier;
  final int storeId;

  @override
  _StoreOrderDetailScreenState createState() => _StoreOrderDetailScreenState();
}

class _StoreOrderDetailScreenState extends State<StoreOrderDetailScreen> {
  OrderHistoryViewModel model = OrderHistoryViewModel();
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      new GlobalKey<RefreshIndicatorState>();

  @override
  void initState() {
    super.initState();
    orderHandler();
  }

  Future<void> refreshFetchOrder() async {
    await model.getStoreOrders(widget.storeId, widget.supplier.id);
  }

  Future<void> orderHandler() async {
    model.getStoreOrders(widget.storeId, widget.supplier.id);
  }

  @override
  Widget build(BuildContext context) {
    return ScopedModel<RootViewModel>(
      model: RootViewModel.getInstance(),
      child: Scaffold(
        appBar: DefaultAppBar(
          title: widget.supplier.name,
        ),
        floatingActionButton: FloatingActionButton(
          child: Icon(
            Icons.restaurant_menu,
            color: Colors.white,
          ),
          onPressed: () {
            Get.toNamed(RouteHandler.STORE_ORDER_RESTAURANT_MODE, arguments: {
              "storeId": widget.storeId,
              "supplierId": widget.supplier.id,
              "supplierName": widget.supplier.name,
            });
          },
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 16),
            Expanded(
              child: ScopedModel<OrderHistoryViewModel>(
                model: model,
                child: Container(
                  child: _buildOrders(),
                  color: Color(0xffefefef),
                ),
              ),
            ),
          ],
        ),
      ),
    );
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

    var f = new NumberFormat("###.0#", "vi_VN");
    final totalSellAmount = orderSummary.orders.fold(
        0, (previousValue, element) => previousValue + element.finalAmount);

    if (orderDate.year == today.year &&
        orderDate.month == today.month &&
        orderDate.day == today.day) {
      isToday = true;
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // isToday
        //     ? Padding(
        //         padding: const EdgeInsets.only(bottom: 16),
        //         child: Text(
        //           "Tổng số đơn hôm nay: " +
        //               orderSummary.orders.length.toString(),
        //           style: TextStyle(
        //             color: Colors.red,
        //             fontWeight: FontWeight.bold,
        //             fontSize: 18,
        //           ),
        //         ),
        //       )
        //     : Container(),
        Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: kPrimary,
            gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [
                  Color(0xff0BAB64),
                  Color(0xff3BB78F),
                ]),
            borderRadius: BorderRadius.circular(8),
          ),
          width: Get.width,
          child: Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    "Số tiền bán được hôm nay:",
                    style: TextStyle(
                      color: Colors.grey[300],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Container(
                    child: Text(
                      "${f.format(totalSellAmount)} VND",
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        fontSize: 20,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      "Số đơn:",
                      style: TextStyle(
                        color: Colors.grey[300],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      orderSummary.orders.length.toString(),
                      style: TextStyle(
                        fontSize: 20,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 24, bottom: 16, top: 8),
          child: Text(
            DateFormat('dd/MM/yyyy').format(orderDate),
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
        ),
        SizedBox(height: 8),
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
              onTap: () {
                _settingModalBottomSheet(order.id);
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
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    "${order.itemQuantity} món",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                      fontWeight: FontWeight.bold,
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
                      fontSize: 20,
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

  void _settingModalBottomSheet(orderId) {
    // get orderDetail
    Get.bottomSheet(
      OrderDetailBottomSheet(
        orderId: orderId,
        storeId: widget.storeId,
        supplierId: widget.supplier.id,
      ),
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
        // side: BorderSide(color: Colors.orange),
      ),
      backgroundColor: kBackgroundGrey[2],
    );
  }
}

class OrderDetailBottomSheet extends StatefulWidget {
  final int orderId, storeId, supplierId;
  const OrderDetailBottomSheet(
      {Key key, this.orderId, this.storeId, this.supplierId})
      : super(key: key);

  @override
  _OrderDetailBottomSheetState createState() => _OrderDetailBottomSheetState();
}

class _OrderDetailBottomSheetState extends State<OrderDetailBottomSheet> {
  final orderDetailModel = OrderHistoryViewModel();

  @override
  void initState() {
    super.initState();
    orderDetailModel.getStoreOrderDetail(
        widget.storeId, widget.supplierId, widget.orderId);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: Get.width,
      padding: EdgeInsets.fromLTRB(0, 8, 0, 0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
        // color: Colors.grey,
      ),
      height: 500,
      child: ScopedModel<OrderHistoryViewModel>(
        model: orderDetailModel,
        child: ScopedModelDescendant<OrderHistoryViewModel>(
          builder: (context, child, model) {
            final status = model.status;
            if (status == ViewStatus.Loading)
              return AspectRatio(
                aspectRatio: 1,
                child: Center(child: CircularProgressIndicator()),
              );

            final orderDetail = model.orderDetail;
            return Scaffold(
              bottomNavigationBar: _buildBottomBar(),
              body: Container(
                padding: EdgeInsets.only(left: 8, right: 8),
                child: Column(
                  children: <Widget>[
                    Container(
                      width: Get.width,
                      child: Row(
                        children: [
                          Expanded(
                            child: Padding(
                              padding: EdgeInsets.only(left: 8, right: 8),
                              child: Divider(),
                            ),
                          ),
                          Container(
                            width: Get.width * 0.4,
                            child: Column(
                              children: [
                                Text(
                                  '${orderDetail.invoiceId}',
                                  style: TextStyle(color: Colors.black45),
                                  overflow: TextOverflow.ellipsis,
                                  textAlign: TextAlign.center,
                                  maxLines: 2,
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: Padding(
                              padding: EdgeInsets.only(left: 8, right: 8),
                              child: Divider(),
                            ),
                          ),
                          Text(
                            DateFormat('HH:mm dd/MM')
                                .format(DateTime.parse(orderDetail.orderTime)),
                            style: TextStyle(color: Colors.black45),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 8),
                    SizedBox(height: 8),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: buildOrderSummaryList(orderDetail),
                      ),
                    ),
                    layoutSubtotal(orderDetail),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Container _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.only(left: 8, right: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey,
            offset: Offset(0.0, 1.0), //(x,y)
            blurRadius: 6.0,
          ),
        ],
      ),
      child: ListView(
        shrinkWrap: true,
        children: [
          SizedBox(
            height: 16,
          ),
          FlatButton(
            onPressed: () async {
              // if (!isOrderDone) await model.putOrder(widget.storeId);
            },
            padding: EdgeInsets.only(left: 8.0, right: 8.0),
            textColor: Colors.white,
            color: kPrimary,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(8))),
            child: Column(
              children: [
                SizedBox(
                  height: 16,
                ),
                Text("${!false ? 'Đã nhận đơn' : 'Đã hoàn thành'}",
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                SizedBox(
                  height: 16,
                )
              ],
            ),
          ),
          SizedBox(
            height: 8,
          )
        ],
      ),
    );
  }

  ListView buildOrderSummaryList(OrderDTO orderDetail) {
    return ListView.separated(
      itemBuilder: (context, index) {
        final orderMaster = orderDetail.orderItems[index];
        final orderChilds = orderMaster.productChilds;

        double orderItemPrice = orderMaster.amount;
        orderChilds?.forEach((element) {
          orderItemPrice += element.amount;
        });
        // orderItemPrice *= orderMaster.quantity;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  "${orderMaster.quantity}x",
                  style: TextStyle(color: Colors.grey),
                ),
                SizedBox(width: 4),
                Expanded(
                  child: Container(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          orderMaster.masterProductName.contains("Extra")
                              ? orderMaster.masterProductName
                                  .replaceAll("Extra", "+")
                              : orderMaster.masterProductName,
                          textAlign: TextAlign.start,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        ...orderChilds
                            .map(
                              (child) => Text(
                                child.masterProductName.contains("Extra")
                                    ? child.masterProductName
                                        .replaceAll("Extra", "+")
                                    : child.masterProductName,
                                style: TextStyle(fontSize: 12),
                              ),
                            )
                            .toList(),
                      ],
                    ),
                  ),
                ),
                Text("${formatPrice(orderItemPrice)}"),
              ],
            ),
          ],
        );
      },
      separatorBuilder: (context, index) => Divider(),
      itemCount: orderDetail.orderItems.length,
    );
  }

  Widget layoutSubtotal(OrderDTO orderDetail) {
    return Container(
      width: MediaQuery.of(context).size.width,
      padding: const EdgeInsets.all(8),
      // margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: kBackgroundGrey[0],
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text("Tên K/H: ${orderDetail.customer.name}"),
            ],
          ),
          Row(
            children: [
              Text("SDT:"),
              FlatButton(
                height: 12,
                onPressed: () async {
                  final url = 'tel:${orderDetail.customer.phone}';
                  if (await canLaunch(url) &&
                      orderDetail.customer.phone != null) {
                    await launch(url);
                  } else {
                    throw 'Could not launch $url';
                  }
                },
                child: new Text("${orderDetail.customer.phone}",
                    style: TextStyle(
                      color: Colors.blue,
                      fontWeight: FontWeight.bold,
                    )),
              ),
            ],
          ),
          Container(
            margin: EdgeInsets.only(top: 15),
            padding: const EdgeInsets.all(10),
            // decoration: BoxDecoration(
            //     border: Border.all(color: kBackgroundGrey[4]),
            //     borderRadius: BorderRadius.all(Radius.circular(10))),
            child: Column(
              children: [
                // OTHER AMOUNTS GO HERE
                // ..._buildOtherAmount(orderDetail.otherAmounts),
                // Divider(color: Colors.black),
                Padding(
                  padding: const EdgeInsets.only(top: 5, bottom: 5),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Tổng cộng",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        "${formatPrice(orderDetail.finalAmount)}",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildOtherAmount(List<OtherAmount> otherAmounts) {
    if (otherAmounts == null) return [SizedBox.shrink()];
    return otherAmounts
        .map((amountObj) => Padding(
              padding: const EdgeInsets.only(top: 5, bottom: 5),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("${amountObj.name}", style: TextStyle()),
                  Text("${formatPrice(amountObj.amount)}", style: TextStyle()),
                ],
              ),
            ))
        .toList();
  }
}
