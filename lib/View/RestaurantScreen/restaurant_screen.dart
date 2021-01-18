import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:get/get.dart';
import 'package:swipe_to/swipe_to.dart';
// widgets
import 'package:uni_express/Model/DTO/OrderDTO.dart';
import 'package:uni_express/ViewModel/restaurant_order_viewModel.dart';
import 'package:uni_express/constraints.dart';
import 'package:uni_express/enums/view_status.dart';
import 'package:uni_express/utils/index.dart';

class RestaurantScreen extends StatefulWidget {
  final int storeId;
  final int supplierId;

  RestaurantScreen({Key key, this.storeId, this.supplierId}) : super(key: key);

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
              Expanded(flex: 3, child: _buildOrderSummary()),
              Expanded(
                flex: 7,
                child: Column(
                  children: [
                    Expanded(
                      flex: 8,
                      child: buildOrderDetail(),
                    ),
                    Expanded(
                      flex: 2,
                      child: buildActions(),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildActions() {
    return ScopedModelDescendant<RestaurantOrderViewModel>(
        rebuildOnChange: false,
        builder: (context, child, model) {
          // bool isLoading = model.status == ViewStatus.Loading;
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
                child: FlatButton(
                  color: kPrimary,
                  onPressed: () {},
                  child: Text(
                    "Hoàn thành",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
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
        return Card(
          margin: const EdgeInsets.fromLTRB(32, 16, 32, 16),
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
                          style: TextStyle(color: Colors.grey),
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
                                    fontSize: 14,
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
        return Container(
          padding: EdgeInsets.all(8),
          height: Get.height,
          color: Colors.white,
          child: Text("Summary Info: ${currentOrder.invoiceId}"),
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
