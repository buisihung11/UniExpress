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
import 'package:url_launcher/url_launcher.dart';

import '../constraints.dart';

class CustomerOrderDetailArguments {
  final OrderDTO order;
  final int storeId;

  CustomerOrderDetailArguments(this.order, this.storeId);
}

class CustomerOrderDetail extends StatefulWidget {
  final OrderDTO order;
  final int storeId;
  const CustomerOrderDetail({
    Key key,
    this.order,
    this.storeId,
  }) : super(key: key);

  @override
  _OrderDetailState createState() => _OrderDetailState();
}

class _OrderDetailState extends State<CustomerOrderDetail> {
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
                  customerInfo(widget.order.customer),
                  SizedBox(height: 8),
                  listStore(model.listSuppliers),
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

  Widget listStore(List<String> suppliers) {
    List<Widget> listStores = List();
    suppliers.forEach((element) {
      listStores.add(Container(
        width: Get.width,
        //margin: EdgeInsets.only(top: 8, bottom: 8),
        padding: EdgeInsets.all(8),
        child: Text(
          element,
          style: TextStyle(
              color: Colors.black, fontSize: 15, fontWeight: FontWeight.bold),
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
          SizedBox(
            height: 8,
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
          orderDetail.paymentType == PaymentType.WALLET
              ? Text(
                  'KHÁCH HÀNG ĐÃ THANH TOÁN',
                  style: TextStyle(
                    color: Colors.lightBlue,
                    fontSize: 14,
                  ),
                )
              : SizedBox.shrink(),
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: ListView.separated(
              physics: NeverScrollableScrollPhysics(),
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
          SizedBox(
            height: 8,
          ),
          RichText(
            text: TextSpan(
                text: "P.Thức: ",
                style: TextStyle(fontSize: 14, color: Colors.black),
                children: <TextSpan>[
                  TextSpan(
                    text:
                        "${PaymentType.getPaymentName(orderDetail.paymentType)}",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontStyle: FontStyle.italic,
                      fontSize: 16,
                      color: orderDetail.paymentType == PaymentType.CASH
                          ? kPrimary
                          : Colors.deepOrange,
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
        final status = widget.order.status;
        bool isOrderDone = status != OrderFilter.ORDERING;
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
                  if (!isOrderDone) await model.putOrder(widget.storeId);
                },
                padding: EdgeInsets.only(left: 8.0, right: 8.0),
                textColor: Colors.white,
                color: !isOrderDone ? kPrimary : Colors.grey,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(8))),
                child: Column(
                  children: [
                    SizedBox(
                      height: 16,
                    ),
                    Text(
                        "${!isOrderDone ? 'Hoàn tất đơn hàng' : 'Đã hoàn thành'}",
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

  Widget customerInfo(CustomerInfoDTO customer) {
    return Container(
      color: kBackgroundGrey[0],
      width: Get.width,
      padding: const EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Align(
            alignment: Alignment.center,
            child: Text(
              "Thông tin khách hàng:",
              style: TextStyle(color: Colors.deepOrange, fontSize: 17),
            ),
          ),
          SizedBox(
            height: 8,
          ),
          RichText(
            text: TextSpan(
              text: 'Tên khách hàng: ',
              style: TextStyle(color: Colors.grey, fontSize: 14),
              children: <TextSpan>[
                TextSpan(
                    text: '${customer.name}',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    )),
              ],
            ),
          ),
          SizedBox(
            height: 8,
          ),
          Row(
            children: [
              Text(
                "SDT: ",
                style: TextStyle(color: Colors.grey, fontSize: 14),
              ),
              FlatButton(
                onPressed: () async {
                  final url = 'tel:${customer.phone}';
                  if (await canLaunch(url) && customer.phone != null) {
                    await launch(url);
                  } else {
                    throw 'Could not launch $url';
                  }
                },
                child: new Text("${customer.phone}",
                    style: TextStyle(
                      color: Colors.blue,
                      fontWeight: FontWeight.bold,
                    )),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
