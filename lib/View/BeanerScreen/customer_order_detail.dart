import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';
import 'package:uni_express/Model/DTO/index.dart';
import 'file:///D:/FPTU/Fall2020/Uni_Delivery/uni_express/lib/View/package_detail.dart';
import 'package:uni_express/ViewModel/batch_viewModel.dart';
import 'package:uni_express/ViewModel/index.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:uni_express/acessories/appbar.dart';
import 'package:uni_express/acessories/dash_border.dart';
import 'package:uni_express/enums/view_status.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:uni_express/utils/index.dart';
import 'package:url_launcher/url_launcher.dart';
import "package:collection/collection.dart";
import '../../constraints.dart';
import '../../route_constraint.dart';

class CustomerOrderDetail extends StatefulWidget {
  final OrderDTO order;
  const CustomerOrderDetail({
    Key key,
    this.order,
  }) : super(key: key);

  @override
  _OrderDetailState createState() => _OrderDetailState();
}

class _OrderDetailState extends State<CustomerOrderDetail> {
  final orderDetailModel = OrderHistoryViewModel();

  @override
  void initState() {
    super.initState();
    orderDetailModel.getCustomerOrderDetail(widget.order.id);
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
                  customerInfo(orderDetail),
                  SizedBox(height: 8),
                  packages(orderDetail),
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

  Widget buildOrderSummaryList(OrderDTO orderDetail) {
    Map<int, List<OrderItemDTO>> map = groupBy(
        orderDetail.orderItems, (OrderItemDTO item) => item.supplierStoreId);
    return Container(
      padding: EdgeInsets.all(8),
      color: kBackgroundGrey[0],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Chi tiết đơn hàng",
            style: TextStyle(
                color: Colors.black, fontSize: 17, fontWeight: FontWeight.bold),
          ),
          Divider(),
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
                List<OrderItemDTO> items = map.values.elementAt(index);
                SupplierNoteDTO note = orderDetail.notes?.firstWhere(
                    (element) =>
                        element.supplierStoreId == items[0].supplierStoreId,
                    orElse: () => null);
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      items[0].supplierStoreName,
                      style: TextStyle(
                          fontWeight: FontWeight.bold, color: kPrimary),
                    ),
                    (note != null)
                        ? Container(
                            width: Get.width,
                            color: Colors.yellow[100],
                            margin: EdgeInsets.only(top: 4),
                            padding: const EdgeInsets.all(4),
                            child: Text.rich(TextSpan(
                                text: "Ghi chú:\n",
                                style:
                                    TextStyle(color: Colors.red, fontSize: 12),
                                children: [
                                  TextSpan(
                                      text: "- " + note.content,
                                      style: TextStyle(color: Colors.grey))
                                ])),
                          )
                        : SizedBox.shrink(),
                    SizedBox(
                      height: 8,
                    ),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                          border: Border.all(color: kBackgroundGrey[4]),
                          borderRadius: BorderRadius.all(Radius.circular(8))),
                      child: ListView.separated(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemBuilder: (context, index) {
                            return buildOrderItem(items[index]);
                          },
                          separatorBuilder: (context, index) => Container(
                              margin: EdgeInsets.only(top: 8, bottom: 8),
                              child: MySeparator()),
                          itemCount: items.length),
                    ),
                    SizedBox(
                      height: 8,
                    ),
                  ],
                );
              },
              separatorBuilder: (context, index) => Divider(),
              itemCount: map.keys.length,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildOrderItem(OrderItemDTO item) {
    final orderChilds = item.productChilds;

    double orderItemPrice = item.amount;
    orderChilds?.forEach((element) {
      orderItemPrice += element.amount;
    });
    // orderItemPrice *= orderMaster.quantity;
    Widget displayPrice = Text("${formatPrice(orderItemPrice)}");
    if (item.type == ProductType.GIFT_PRODUCT) {
      displayPrice = RichText(
          text: TextSpan(
              style: TextStyle(color: Colors.black),
              text: orderItemPrice.toString() + " ",
              children: [
            WidgetSpan(
                alignment: PlaceholderAlignment.bottom,
                child: Image(
                  image: AssetImage("assets/images/icons/bean_coin.png"),
                  width: 20,
                  height: 20,
                ))
          ]));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              width: Get.width * 0.6,
              child: Wrap(
                //mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    "${item.quantity}x ",
                    style: TextStyle(color: Colors.grey),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Container(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        item.type != ProductType.MASTER_PRODUCT
                            ? Text(
                                item.masterProductName,
                                textAlign: TextAlign.start,
                                style: TextStyle(
                                  fontSize: 14,
                                ),
                              )
                            : SizedBox.shrink(),
                        ...orderChilds
                            .map(
                              (child) => Text(
                                child.type == ProductType.EXTRA_PRODUCT
                                    ? "+ " + child.masterProductName
                                    : child.masterProductName,
                                style: TextStyle(fontSize: 14),
                              ),
                            )
                            .toList(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Flexible(child: displayPrice)
          ],
        ),
      ],
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
          Container(
            margin: EdgeInsets.only(top: 8),
            padding: const EdgeInsets.all(8),
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
        ],
      ),
    );
  }

  List<Widget> _buildOtherAmount(List<OtherAmount> otherAmounts) {
    var f = new NumberFormat("###.#");
    if (otherAmounts == null) return [SizedBox.shrink()];
    return otherAmounts
        .map((amountObj) => Padding(
              padding: const EdgeInsets.only(top: 5, bottom: 5),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("${amountObj.name}", style: TextStyle()),
                  Text("${f.format(amountObj.amount)} ${amountObj.unit}",
                      style: TextStyle()),
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
                  if (!isOrderDone) await model.putOrder();
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

  Widget packages(OrderDTO orderDetail) {
    return Container(
      color: kBackgroundGrey[0],
      width: Get.width,
      padding: const EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Danh sách túi hàng",
            style: TextStyle(
                color: Colors.black, fontSize: 17, fontWeight: FontWeight.bold),
          ),
          SizedBox(
            height: 16,
          ),
          Container(
            width: Get.width,
            height: 30,
            child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemBuilder: (context, index) {
                  return InkWell(
                    onTap: () {
                      Get.toNamed(RouteHandler.PACAKGE,
                          arguments: PackageDetailScreen(
                            packageId: orderDetail.packageIds[index],
                            batchId: BatchViewModel.getInstance()
                                .incomingBatch
                                .routingBatchId,
                          ));
                    },
                    child: Container(
                      padding: EdgeInsets.only(left: 8, right: 8),
                      decoration: BoxDecoration(
                        color: kPrimary,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                          child: Text(
                        "#" + orderDetail.packageIds[index].toString(),
                        style: TextStyle(color: Colors.white),
                      )),
                    ),
                  );
                },
                separatorBuilder: (context, index) => SizedBox(
                      width: 8,
                    ),
                itemCount: orderDetail.packageIds.length),
          )
        ],
      ),
    );
  }

  Widget customerInfo(OrderDTO orderDetail) {
    return Container(
      color: kBackgroundGrey[0],
      width: Get.width,
      padding: const EdgeInsets.all(8),
      child: ExpandablePanel(
        theme: const ExpandableThemeData(
          tapHeaderToExpand: true,
          tapBodyToCollapse: true,
          iconColor: kPrimary,
        ),
        header: Text(
          "Thông tin đơn hàng",
          style: TextStyle(
              color: Colors.black, fontSize: 17, fontWeight: FontWeight.bold),
        ),
        expanded: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            buildTitle(
                "Tên khách hàng",
                Text(
                  orderDetail.customer.name.toUpperCase(),
                  style: TextStyle(fontSize: 14, color: Colors.black),
                )),
            SizedBox(
              height: 8,
            ),
            buildTitle(
                "Điện thoại",
                InkWell(
                  onTap: () async {
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
                        decoration: TextDecoration.underline,
                        color: Colors.blue,
                      )),
                )),
            SizedBox(
              height: 8,
            ),
            buildTitle(
                "Thời gian đặt",
                Text(
                  DateFormat('dd/MM/yyyy HH:mm')
                      .format(DateTime.parse(orderDetail.orderTime)),
                  style: TextStyle(fontSize: 14, color: Colors.black),
                )),
            SizedBox(
              height: 8,
            ),
            buildTitle(
                "Trạng thái đơn",
                Text(
                  "${orderDetail.status == OrderFilter.ORDERING ? "Mới" : "Đã hoàn thành"}",
                  style: TextStyle(fontSize: 14, color: Colors.black),
                )),
            SizedBox(
              height: 8,
            ),
            buildTitle(
                "Nhận đơn tại",
                Text(
                  "${orderDetail.location.address}",
                  style: TextStyle(fontSize: 14, color: Colors.black),
                )),
          ],
        ),
        collapsed: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            buildTitle(
                "Tên khách hàng",
                Text(
                  orderDetail.customer.name.toUpperCase(),
                  style: TextStyle(fontSize: 14, color: Colors.black),
                )),
            SizedBox(
              height: 8,
            ),
            buildTitle(
                "Điện thoại",
                InkWell(
                  onTap: () async {
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
                        decoration: TextDecoration.underline,
                        color: Colors.blue,
                      )),
                )),
          ],
        ),
      ),
    );
  }

  Widget buildTitle(String title, Widget content) {
    return Row(
      children: [
        Expanded(
            flex: 4,
            child: Text(
              title,
              style: kTitleTextStyle.copyWith(fontSize: 14),
            )),
        //SizedBox(width: 16,),
        Expanded(flex: 6, child: content)
      ],
    );
  }
}
