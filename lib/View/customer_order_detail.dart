import 'package:flutter/material.dart';
import 'package:uni_express/Model/DTO/index.dart';
import 'package:uni_express/ViewModel/index.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:uni_express/acessories/appbar.dart';
import 'package:uni_express/acessories/dash_border.dart';
import 'package:uni_express/enums/view_status.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:uni_express/utils/index.dart';

import '../constraints.dart';

class CustomerOrderDetailArguments {
  final OrderDTO order;
  final int storeId;

  CustomerOrderDetailArguments(this.order, this.storeId);
}

class CustomerOrderDetailBottomSheet extends StatefulWidget {
  final OrderDTO order;
  final int storeId;
  const CustomerOrderDetailBottomSheet({
    Key key,
    this.order,
    this.storeId,
  }) : super(key: key);

  @override
  _OrderDetailBottomSheetState createState() => _OrderDetailBottomSheetState();
}

class _OrderDetailBottomSheetState
    extends State<CustomerOrderDetailBottomSheet> {
  final orderDetailModel = OrderHistoryViewModel();

  @override
  void initState() {
    super.initState();
    orderDetailModel.getCustomerOrderDetail(widget.storeId, widget.order.id);
  }

  @override
  Widget build(BuildContext context) {
    return ScopedModel<OrderHistoryViewModel>(
      model: orderDetailModel,
      child: Scaffold(
        appBar: DefaultAppBar(
          title: widget.order.invoiceId,
        ),
        bottomNavigationBar: bottomBar(),
        body: SingleChildScrollView(
          child: ScopedModelDescendant<OrderHistoryViewModel>(
            builder: (context, child, model) {
              final status = model.status;
              if (status == ViewStatus.Loading)
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Center(child: CircularProgressIndicator()),
                );

              final orderDetail = model.orderDetail;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        orderDetail.orderTime != null
                            ? DateFormat('dd/MM/yyy hh:mm')
                                .format(DateTime.parse(orderDetail.orderTime))
                            : '-',
                        style: TextStyle(
                            color: Colors.black45,
                            fontSize: 18,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  SizedBox(height: 8),
                  listStore(orderDetail),
                  SizedBox(height: 8),
                  buildOrderSummaryList(orderDetail),
                  layoutSubtotal(orderDetail),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget listStore(OrderDTO orderDetail) {
    List<Widget> listStores = List();
    orderDetail.stores?.forEach((element) {
      listStores.add(Container(
        width: Get.width,
        margin: EdgeInsets.only(top: 8, bottom: 8),
        padding: EdgeInsets.all(8),
        decoration: BoxDecoration(
            border: Border.all(),
            borderRadius: BorderRadius.all(Radius.circular(8))),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              element.invoice_id,
              style: TextStyle(
                  fontSize: 16,
                  color: Colors.black,
                  fontWeight: FontWeight.bold),
            ),
            SizedBox(
              height: 8,
            ),
            Text(
              "Nhà hàng: " + element.name,
              style: TextStyle(color: Colors.black45),
            ),
            SizedBox(
              height: 8,
            ),
            Text(
              "Địa chỉ: " + element.location,
              style: TextStyle(color: Colors.black45),
            ),
            SizedBox(
              height: 8,
            ),
            Text(
              "Liên hệ: " + element.phone,
              style: TextStyle(color: Colors.black45),
            ),
            SizedBox(
              height: 8,
            ),
            element.notes != null
                ? Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Text(
                      "Notes: " + element.notes,
                      style: TextStyle(color: Colors.red),
                    ),
                  )
                : SizedBox.shrink(),
          ],
        ),
      ));
    });
    return Container(
      color: kBackgroundGrey[0],
      padding: const EdgeInsets.all(8),
      child: Column(
        children: [
          Text(
            "Đơn từ nhà hàng:",
            style: TextStyle(color: Colors.deepOrange, fontSize: 17),
          ),
          ...listStores
        ],
      ),
    );
  }

  Widget buildOrderSummaryList(OrderDTO orderDetail) {
    return Container(
      margin: EdgeInsets.only(top: 8),
      padding: EdgeInsets.all(8),
      color: kBackgroundGrey[0],
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              "Chi tiết đơn hàng",
              style: TextStyle(color: Colors.deepOrange, fontSize: 17),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: ListView.separated(
              shrinkWrap: true,
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
                          style: TextStyle(color: Colors.grey, fontSize: 15),
                        ),
                        SizedBox(width: 4),
                        Expanded(
                          child: Container(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  orderMaster.masterProductName
                                          .contains("Extra")
                                      ? orderMaster.masterProductName
                                          .replaceAll("Extra", "+")
                                      : orderMaster.masterProductName,
                                  textAlign: TextAlign.start,
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                ...orderChilds
                                    .map(
                                      (child) => Padding(
                                        padding: const EdgeInsets.all(4.0),
                                        child: Text(
                                          child.masterProductName
                                                  .contains("Extra")
                                              ? child.masterProductName
                                                  .replaceAll("Extra", "+")
                                              : child.masterProductName,
                                          style: TextStyle(fontSize: 15),
                                        ),
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
            ),
          ),
        ],
      ),
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

  Widget bottomBar() {
    return ScopedModelDescendant<OrderHistoryViewModel>(
      builder: (context, child, model) {
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
                  await model.putOrder();
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
                    Text("Đã giao",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 15)),
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
      },
    );
  }
}
