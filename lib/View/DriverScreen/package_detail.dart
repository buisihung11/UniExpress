import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:uni_express/Model/DTO/index.dart';
import 'package:uni_express/ViewModel/index.dart';
import 'package:uni_express/ViewModel/package_viewModel.dart';
import 'package:uni_express/acessories/appbar.dart';
import 'package:uni_express/acessories/loading.dart';
import 'package:uni_express/enums/view_status.dart';
import 'package:uni_express/utils/index.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../constraints.dart';

class PackageDetailScreen extends StatefulWidget {
  PackageDetailScreen({Key key, @required this.package, this.batchId})
      : super(key: key);
  PackageDTO package;
  int batchId;

  @override
  _PackageDetailScreenState createState() => _PackageDetailScreenState();
}

class _PackageDetailScreenState extends State<PackageDetailScreen> {
  PackageViewModel model = PackageViewModel();
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      new GlobalKey<RefreshIndicatorState>();

  @override
  void initState() {
    super.initState();
    model.getPackageDetail(widget.batchId, widget.package.packageId);
  }

  Future<void> refreshFetchOrder() async {
    await model.getPackageDetail(widget.batchId, widget.package.packageId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: DefaultAppBar(
        title: "Túi #${widget.package.packageId}",
      ),
      body: RefreshIndicator(
        key: _refreshIndicatorKey,
        onRefresh: refreshFetchOrder,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ScopedModel<PackageViewModel>(
              model: model,
              child: Expanded(child: _buildOrders()),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrders() {
    return ScopedModelDescendant<PackageViewModel>(
        builder: (context, child, model) {
      final status = model.status;
      if (status == ViewStatus.Loading)
        return Padding(
          padding: const EdgeInsets.only(top: 32.0),
          child: Center(
            child: LoadingBean(),
          ),
        );
      else if (model.package == null)
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

      return ListView(
        shrinkWrap: true,
        children: [
          Container(
            padding: EdgeInsets.all(8),
            width: Get.width,
            child: Text(
              "Tổng số đơn: ${model.package.items.length.toString()}",
              style: TextStyle(
                  color: kPrimary, fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
          ...model.package.items
              .map((item) => _buildOrderItem(item))
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
      );
    });
  }

  Widget _buildOrderItem(ItemDTO item) {
    return Container(
      padding: EdgeInsets.fromLTRB(0, 16, 0, 8),
      margin: EdgeInsets.all(8),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(8)),
          color: Colors.white
          // color: Colors.grey,
          ),
      child: Column(
        children: <Widget>[
          Container(
            width: Get.width,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: EdgeInsets.only(left: 8),
                  child: Divider(),
                ),
                Column(
                  children: [
                    Text(
                      '${item.code} - ${item.orders.length} món',
                      style: TextStyle(color: kPrimary),
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                    ),
                  ],
                ),
                Padding(
                  padding: EdgeInsets.only(right: 8),
                  child: Divider(),
                ),
              ],
            ),
          ),
          SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: buildOrderSummaryList(item),
          ),
          layoutSubtotal(item),
          _buildBottomBar(),
        ],
      ),
    );
  }

  Container _buildBottomBar() {
    return Container(
      width: Get.width,
      padding: const EdgeInsets.only(left: 8, right: 8),
      child: FlatButton(
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
              height: 8,
            ),
            Text("${!false ? 'Đã nhận đơn' : 'Đã hoàn thành'}",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            SizedBox(
              height: 8,
            )
          ],
        ),
      ),
    );
  }

  Widget buildOrderSummaryList(ItemDTO item) {
    return Container(
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(8)),
          border: Border.all(color: Colors.grey)),
      child: ListView.separated(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        itemBuilder: (context, index) {
          final orderMaster = item.orders[index];
          final orderChilds = orderMaster.productChilds;

          double orderItemPrice = orderMaster.amount;
          orderChilds?.forEach((element) {
            orderItemPrice += element.amount;
          });
          // orderItemPrice *= orderMaster.quantity;
          Widget displayName = Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  orderMaster.masterProductName.contains("Extra")
                      ? orderMaster.masterProductName.replaceAll("Extra", "+")
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
                            ? child.masterProductName.replaceAll("Extra", "+")
                            : child.masterProductName,
                        style: TextStyle(fontSize: 12),
                      ),
                    )
                    .toList(),
              ],
            ),
          );

          if (orderMaster.type == ProductType.GIFT_PRODUCT) {
            displayName = Flexible(
              child: Text(
                "🎁 ${orderMaster.masterProductName} 🎁",
                textAlign: TextAlign.start,
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.orange),
              ),
            );
          }
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Row(
                      children: [
                        Text(
                          "${orderMaster.quantity}x",
                          style: TextStyle(color: Colors.grey),
                        ),
                        SizedBox(width: 4),
                        displayName,
                      ],
                    ),
                  ),
                  Flexible(child: Text("${formatPrice(orderItemPrice)}")),
                ],
              ),
            ],
          );
        },
        separatorBuilder: (context, index) => Divider(),
        itemCount: item.orders.length,
      ),
    );
  }

  Widget layoutSubtotal(ItemDTO item) {
    return Container(
      width: Get.width,
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
              Text("Tên K/H: "),
              Text(
                "${item.customer.name}",
                style: TextStyle(color: Colors.orange),
              )
            ],
          ),
          SizedBox(
            height: 8,
          ),
          Row(
            children: [
              Text("DT: "),
              InkWell(
                onTap: () async {
                  final url = 'tel:${item.customer.phone}';
                  if (await canLaunch(url) && item.customer.phone != null) {
                    await launch(url);
                  } else {
                    throw 'Could not launch $url';
                  }
                },
                child: new Text("${item.customer.phone}",
                    style: TextStyle(
                        color: Colors.blue,
                        fontWeight: FontWeight.bold,
                        decoration: TextDecoration.underline)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
