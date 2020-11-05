import 'package:animated_text_kit/animated_text_kit.dart';
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
import 'package:uni_express/utils/index.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../constraints.dart';


class OrderHistoryScreen extends StatefulWidget {
  OrderHistoryScreen({Key key}) : super(key: key);

  @override
  _OrderHistoryScreenState createState() => _OrderHistoryScreenState();
}

class _OrderHistoryScreenState extends State<OrderHistoryScreen> {
  List<bool> _selections = [true, false];

  OrderHistoryViewModel model = OrderHistoryViewModel();
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      new GlobalKey<RefreshIndicatorState>();

  @override
  void initState() {
    super.initState();
    orderHandler();
  }

  Future<void> refreshFetchOrder() async {
    OrderFilter filter =
        _selections[0] ? OrderFilter.ORDERING : OrderFilter.DONE;
    await model.getOrders(filter);
  }

  Future<void> orderHandler() async {
    OrderFilter filter =
        _selections[0] ? OrderFilter.ORDERING : OrderFilter.DONE;
    try {
      await model.getOrders(filter);
    } catch (e) {} finally {}
  }

  @override
  Widget build(BuildContext context) {
    return ScopedModel<OrderHistoryViewModel>(
      model: model,
      child: Scaffold(
        appBar: DefaultAppBar(
          title: "Lịch sử",
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Center(
              child: Container(
                // color: Colors.amber,
                padding: EdgeInsets.fromLTRB(0, 8, 0, 8),
                width: double.infinity,
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
                child: Center(
                  child: ToggleButtons(
                    renderBorder: false,
                    selectedColor: kPrimary,
                    onPressed: (int index) async {
                      setState(() {
                        _selections = _selections.map((e) => false).toList();
                        _selections[index] = true;
                      });
                      await orderHandler();
                    },
                    borderRadius: BorderRadius.circular(24),
                    isSelected: _selections,
                    children: [
                      Container(
                        width: MediaQuery.of(context).size.width / 3,
                        child: Text(
                          "Đang giao",
                          textAlign: TextAlign.center,
                        ),
                      ),
                      Container(
                        width: MediaQuery.of(context).size.width / 3,
                        child: Text(
                          "Hoàn thành",
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(height: 16),
            Expanded(
              child: Container(
                child: _buildOrders(),
                color: Color(0xffefefef),
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 24, bottom: 16),
          child: Text(
            DateFormat('dd/MM/yyyy')
                .format(DateTime.parse(orderSummary.checkInDate)),
            style: TextStyle(
              color: Colors.black,
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
              onTap: () {
                _settingModalBottomSheet(order.id);
              },
              contentPadding: EdgeInsets.fromLTRB(16, 8, 16, 8),
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "${order.itemQuantity} món",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    "FPT University",
                    style: TextStyle(
                      fontSize: 16,
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
  final int orderId;
  const OrderDetailBottomSheet({
    Key key,
    this.orderId,
  }) : super(key: key);

  @override
  _OrderDetailBottomSheetState createState() => _OrderDetailBottomSheetState();
}

class _OrderDetailBottomSheetState extends State<OrderDetailBottomSheet> {
  final orderDetailModel = OrderHistoryViewModel();

  @override
  void initState() {
    super.initState();
    orderDetailModel.getOrderDetail(widget.orderId);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: Get.width,
      padding: EdgeInsets.fromLTRB(16, 8, 16, 0),
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
            return Container(
              child: Column(
                children: <Widget>[
                  Container(
                    width: Get.width,
                    child: Row(
                      children: [
                        Container(
                          width: 85,
                          child: orderDetail.status == OrderFilter.ORDERING
                              ? TyperAnimatedTextKit(
                                  speed: Duration(milliseconds: 100),
                                  onTap: () {
                                    print("Tap Event");
                                  },
                                  text: ['Đang giao...'],
                                  textStyle: TextStyle(
                                      fontFamily: "Bobbers",
                                      color: Colors.amber),
                                  textAlign: TextAlign.start,
                                  alignment: AlignmentDirectional
                                      .topStart // or Alignment.topLeft
                                  )
                              : Text(
                                  'Đã nhận hàng',
                                  style: TextStyle(
                                    color: kPrimary,
                                  ),
                                ),
                        ),
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
            );
          },
        ),
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Tổng tiền",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(
                "${orderDetail.itemQuantity} món",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          RichText(
            text: TextSpan(
                text: "P.Thức: ",
                style: TextStyle(fontSize: 12, color: Colors.black),
                children: <TextSpan>[
                  TextSpan(
                    text:
                        "${PaymentType.getPaymentName(orderDetail.paymentType)}",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontStyle: FontStyle.italic,
                      fontSize: 12,
                      color: kPrimary,
                    ),
                  ),
                ]),
          ),
          Container(
            margin: EdgeInsets.only(top: 15),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
                border: Border.all(color: kBackgroundGrey[4]),
                borderRadius: BorderRadius.all(Radius.circular(10))),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 5, bottom: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Tạm tính",
                        style: TextStyle(),
                      ),
                      Text("${formatPrice(orderDetail.total)}"),
                    ],
                  ),
                ),
                MySeparator(),
                // OTHER AMOUNTS GO HERE
                ..._buildOtherAmount(orderDetail.otherAmounts),
                Divider(color: Colors.black),
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
