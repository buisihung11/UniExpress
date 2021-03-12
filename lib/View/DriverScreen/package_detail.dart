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
        title: "Túi ${widget.package.packageId}",
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(height: 16),
          Expanded(
            child: ScopedModel<PackageViewModel>(
              model: model,
              child: Container(
                child: _buildOrders(),
                color: Color(0xffefefef),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrders() {
    return ScopedModelDescendant<PackageViewModel>(
        builder: (context, child, model) {
      final status = model.status;
      if (status == ViewStatus.Loading)
        return Center(
          child: LoadingBean(),
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

      return RefreshIndicator(
        key: _refreshIndicatorKey,
        onRefresh: refreshFetchOrder,
        child: Container(
          child: ListView(
            padding: EdgeInsets.all(8),
            children: [
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
                child: Text(
                  "Tổng số đơn: ${model.package.items.length.toString()}",
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16),
                ),
              ),
              SizedBox(height: 8,),
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
          ),
        ),
      );
    });
  }

  Widget _buildOrderItem(ItemDTO item) {
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
        child: ListTile(
          onTap: () {
            _settingModalBottomSheet(item);
          },
          contentPadding: EdgeInsets.fromLTRB(16, 8, 16, 8),
          title: Text(
            "${item.code}",
            style: TextStyle(
              fontSize: 16,
              color: kPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          trailing: Text(
            "${item.orders.fold(0, (previousValue, element) => previousValue + element.quantity)} món",
            style: TextStyle(
              color: Colors.grey,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
      ),
    );
  }

  void _settingModalBottomSheet(ItemDTO itemDTO) {
    // get orderDetail
    Get.bottomSheet(
      OrderDetailBottomSheet(item: itemDTO),
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
  final ItemDTO item;
  const OrderDetailBottomSheet({
    Key key,
    this.item,
  }) : super(key: key);

  @override
  _OrderDetailBottomSheetState createState() => _OrderDetailBottomSheetState();
}

class _OrderDetailBottomSheetState extends State<OrderDetailBottomSheet> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        width: Get.width,
        padding: EdgeInsets.fromLTRB(0, 16, 0, 0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
          ),
          // color: Colors.grey,
        ),
        height: 500,
        child: Scaffold(
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
                              '${widget.item.code}',
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
                    ],
                  ),
                ),
                SizedBox(height: 8),
                SizedBox(height: 8),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: buildOrderSummaryList(),
                  ),
                ),
                layoutSubtotal()
              ],
            ),
          ),
        ));
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

  ListView buildOrderSummaryList() {
    return ListView.separated(
      itemBuilder: (context, index) {
        final orderMaster = widget.item.orders[index];
        final orderChilds = orderMaster.productChilds;

        double orderItemPrice = orderMaster.amount;
        orderChilds?.forEach((element) {
          orderItemPrice += element.amount;
        });
        // orderItemPrice *= orderMaster.quantity;
        Widget displayPrice = Text("${formatPrice(orderItemPrice)}");
        if (orderMaster.type == ProductType.GIFT_PRODUCT) {
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
                Flexible(child: displayPrice),
              ],
            ),
          ],
        );
      },
      separatorBuilder: (context, index) => Divider(),
      itemCount: widget.item.orders.length,
    );
  }

  Widget layoutSubtotal() {
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
              Text("Tên K/H: ${widget.item.customer.name}"),
            ],
          ),
          Row(
            children: [
              Text("SDT:"),
              FlatButton(
                height: 12,
                onPressed: () async {
                  final url = 'tel:${widget.item.customer.phone}';
                  if (await canLaunch(url) &&
                      widget.item.customer.phone != null) {
                    await launch(url);
                  } else {
                    throw 'Could not launch $url';
                  }
                },
                child: new Text("${widget.item.customer.phone}",
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
