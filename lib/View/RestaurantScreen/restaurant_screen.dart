import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:get/get.dart';

import 'package:uni_express/ViewModel/restaurant_order_viewModel.dart';
import 'package:uni_express/constraints.dart';
import 'package:uni_express/enums/view_status.dart';
import 'package:uni_express/utils/index.dart';
import 'package:url_launcher/url_launcher.dart';

class RestaurantScreen extends StatefulWidget {
  final int storeId;
  final int supplierId;
  final String supplierName;

  RestaurantScreen({Key key, this.storeId, this.supplierId, this.supplierName})
      : super(key: key);

  @override
  _RestaurantScreenState createState() => _RestaurantScreenState();
}

class _RestaurantScreenState extends State<RestaurantScreen> {
  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIOverlays([]);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
    ]);
  }

  @override
  dispose() {
    SystemChrome.setEnabledSystemUIOverlays(SystemUiOverlay.values);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
    ]);
    return ScopedModel<RestaurantOrderViewModel>(
      model: RestaurantOrderViewModel(widget.storeId, widget.supplierId),
      child: Scaffold(
        body: Container(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildOrderSummary(),
              Expanded(
                flex: 7,
                child: Container(
                  padding: const EdgeInsets.fromLTRB(32, 16, 32, 0),
                  child: Column(
                    children: [
                      Expanded(
                        flex: 1,
                        child: _buildCount(),
                      ),
                      Expanded(
                        flex: 7,
                        child: buildOrderDetail(),
                      ),
                      Expanded(
                        flex: 2,
                        child: buildActions(),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCount() {
    return ScopedModelDescendant<RestaurantOrderViewModel>(
        // rebuildOnChange: false,
        builder: (context, child, model) {
      return Container(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            ScopedModelDescendant<RestaurantOrderViewModel>(
                builder: (context, child, model) {
              return Container(
                  child: Text("Còn lại ${model.orderLeftQuanitity} "));
            }),
            Text("/ ${model.orderList?.orders?.length ?? '...'} đơn"),
          ],
        ),
      );
    });
  }

  Widget buildActions() {
    return ScopedModelDescendant<RestaurantOrderViewModel>(
        rebuildOnChange: true,
        builder: (context, child, model) {
          // bool isLoading = model.status == ViewStatus.Loading;

          final orderQuantityLeft = model.orderLeftQuanitity;
          if (orderQuantityLeft == 0) return Container();

          return Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FlatButton(
                onPressed: () {
                  model.preOrder();
                },
                child: Text("Trước"),
              ),
              Container(
                margin: EdgeInsets.only(left: 8, right: 8),
                child: ScopedModelDescendant<RestaurantOrderViewModel>(
                    builder: (context, child, model) {
                  if (model.status == ViewStatus.Loading)
                    return CircularProgressIndicator();
                  else {
                    final isComplete = model.currentOrderSummary.isCompleted;
                    return FlatButton(
                      color: isComplete ? Colors.grey : kPrimary,
                      onPressed: () {
                        if (!isComplete) {
                          model.completeOrder();
                        }
                      },
                      child: Container(
                        child: Text(
                          "${!isComplete ? 'Hoàn thành' : 'Đã hoàn tất'}",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    );
                  }
                }),
              ),
              FlatButton(
                onPressed: () {
                  model.nextOrder();
                },
                child: Text("Sau"),
              ),
            ],
          );
        });
  }

  Widget buildOrderDetail() {
    return ScopedModelDescendant<RestaurantOrderViewModel>(
      builder: (context, child, model) {
        final status = model.status;
        if (status == ViewStatus.Loading)
          return AspectRatio(
            aspectRatio: 1,
            child: Center(child: CircularProgressIndicator()),
          );
        else if (status == ViewStatus.Error) {
          return AspectRatio(
              aspectRatio: 1,
              child: Center(
                child: Text("Đã có sự cố xảy ra :)"),
              ));
        }
        final currentOrderDetail = model.currentOrderDetail;
        if (currentOrderDetail?.orderItems == null ||
            currentOrderDetail?.orderItems?.length == 0) {
          return Container();
        }
        if (model.orderLeftQuanitity == 0) {
          return Center(
            child: Container(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Đã hoàn thành tất cả các món!!!"),
                  Container(
                    margin: EdgeInsets.only(top: 16, bottom: 16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      color: Colors.white,
                    ),
                    child: Icon(
                      Icons.check,
                      color: kPrimary,
                      size: 40,
                    ),
                  ),
                  FlatButton(
                    color: Colors.blueAccent,
                    onPressed: () {
                      Get.back();
                    },
                    child: Text("Quay lại", style: kTextPrimary),
                  )
                ],
              ),
            ),
          );
        }
        return Card(
          child: Container(
            padding: const EdgeInsets.all(8),
            child: ListView.separated(
              itemBuilder: (context, index) {
                final orderMaster = currentOrderDetail.orderItems[index];
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
                          style: TextStyle(color: Colors.grey, fontSize: 16),
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
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                ...orderChilds
                                    .map(
                                      (child) => Text(
                                        child.masterProductName
                                                .contains("Extra")
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
              itemCount: currentOrderDetail?.orderItems?.length,
            ),
          ),
        );
      },
    );
  }

  Widget _buildOrderSummary() {
    return ScopedModelDescendant<RestaurantOrderViewModel>(
        builder: (context, child, model) {
      final status = model.status;
      final currentOrder = model.currentOrderSummary;
      final orderLeftQuantity = model.orderLeftQuanitity;

      if (orderLeftQuantity == 0) return Container();

      if (status == ViewStatus.Loading)
        return AspectRatio(
          aspectRatio: 1,
          child: Center(child: CircularProgressIndicator()),
        );
      else if (status == ViewStatus.Error) {
        return AspectRatio(
            aspectRatio: 1,
            child: Center(
              child: Text("Đã có sự cố xảy ra :)"),
            ));
      }
      if (model.orderList != null) {
        return Expanded(
          flex: 3,
          child: Container(
            color: Colors.white,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Container(
                      padding: EdgeInsets.fromLTRB(16, 8, 16, 8),
                      decoration: BoxDecoration(
                        color: kPrimary,
                        borderRadius: BorderRadius.only(
                          bottomRight: Radius.circular(16),
                        ),
                      ),
                      child: Text(widget.supplierName, style: kTextPrimary),
                    ),
                    SizedBox(width: 12)
                  ],
                ),
                SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      decoration: const BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                              width: 1.0, color: Color(0xFFFF000000)),
                        ),
                      ),
                      child: Text(
                        "${currentOrder.invoiceId}",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 20),
                      ),
                    ),
                  ],
                ),
                Expanded(
                  child: SingleChildScrollView(
                    child: Container(
                      padding: EdgeInsets.all(8),
                      height: Get.height,
                      color: Colors.white,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            height: 16,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Tổng số món: ",
                                style: TextStyle(color: Colors.grey),
                              ),
                              Text(
                                "${currentOrder.itemQuantity} món",
                                style: kTextSecondary.copyWith(fontSize: 18),
                              ),
                            ],
                          ),
                          SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Tổng tiền: ",
                                style: TextStyle(color: Colors.grey),
                              ),
                              Text(
                                "${formatPrice(currentOrder.finalAmount)}",
                                style: kTextSecondary.copyWith(fontSize: 18),
                              ),
                            ],
                          ),
                          SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Text(
                                "Tên K/H: ",
                                style: TextStyle(color: Colors.grey),
                              ),
                              Text(
                                "${currentOrder.customer.name}",
                                style: kTextSecondary.copyWith(
                                  fontSize: 14,
                                  color: Colors.grey,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          Container(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Text(
                                  "SDT: ",
                                  style: TextStyle(color: Colors.grey),
                                ),
                                FlatButton(
                                  // height: 12,
                                  padding: EdgeInsets.all(0),
                                  onPressed: () async {
                                    final url =
                                        'tel:${currentOrder.customer.phone}';
                                    if (await canLaunch(url) &&
                                        currentOrder.customer.phone != null) {
                                      await launch(url);
                                    } else {
                                      throw 'Could not launch $url';
                                    }
                                  },
                                  child: new Text(
                                    "${currentOrder.customer.phone}",
                                    style: TextStyle(
                                      color: Colors.grey,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Ghi chú: ",
                                  style: TextStyle(color: Colors.grey),
                                ),
                                currentOrder.notes != null
                                    ? Text(
                                        currentOrder.notes?.first?.content ??
                                            '-')
                                    : Text('-')
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
                FlatButton.icon(
                  icon: Icon(Icons.arrow_back),
                  onPressed: () {
                    Get.back();
                  },
                  label: Text("Trở về"),
                )
              ],
            ),
          ),
        );
      }
      return Container(
        padding: EdgeInsets.all(8),
        height: Get.height,
        color: Colors.white,
      );
    });
  }
}
