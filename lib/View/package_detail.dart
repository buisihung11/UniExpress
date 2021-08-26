import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:uni_express/Model/DTO/index.dart';
import 'package:uni_express/ViewModel/index.dart';
import 'package:uni_express/acessories/appbar.dart';
import 'package:uni_express/acessories/loading.dart';
import 'package:uni_express/enums/view_status.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:url_launcher/url_launcher.dart';
import '../constraints.dart';

class PackageDetailScreen extends StatefulWidget {
  PackageDetailScreen(
      {Key key, @required this.packageId, this.batchId, this.driver})
      : super(key: key);
  int packageId;
  int batchId;
  String driver;

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
    model.getPackageDetail(widget.batchId, widget.packageId);
  }

  Future<void> refreshFetchOrder() async {
    await model.getPackageDetail(widget.batchId, widget.packageId);
  }

  @override
  Widget build(BuildContext context) {
    return ScopedModel(
      model: model,
      child: Scaffold(
        appBar: DefaultAppBar(
          title: "Túi #${widget.packageId}",
        ),
        body: RefreshIndicator(
          key: _refreshIndicatorKey,
          onRefresh: refreshFetchOrder,
          child: _buildOrders()
        ),
      ),
    );
  }

  Widget _buildOrders() {
    return ScopedModelDescendant<PackageViewModel>(
        builder: (context, child, model) {
      if (model.status == ViewStatus.Loading)
        return ListView(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 32.0),
              child: Center(
                child: LoadingBean(),
              ),
            ),
          ],
        );
      else if (model.package == null)
        return ListView(
          children: [
            Container(
              child: SvgPicture.asset(
                'assets/images/order_history.svg',
                semanticsLabel: 'Acme Logo',
                fit: BoxFit.cover,
              ),
            )
          ],
        );
      if (model.status == ViewStatus.Error)
        return ListView(
          children: [
            Center(
              child: AspectRatio(
                aspectRatio: 1 / 4,
                child: Image.asset(
                  'assets/images/error.png',
                  width: 24,
                ),
              ),
            ),
          ],
        );
      String status;
      Color color, backgroundColor;

      switch(model.package.status){
        case PackageStatus.NEW:
          status = "Tài xế chưa lấy";
          color = Colors.orange;
          backgroundColor = Colors.yellow[100];
          break;
        case PackageStatus.PICKEDUP:
          status = "Tài xế đang giao";
          color = Colors.blue;
          backgroundColor = Colors.blue[100];
          break;
        case PackageStatus.DELIVERIED:
          status = "Đã nhận";
          color = Colors.green;
          backgroundColor = Colors.green[100];
          break;
        default:
          status = "";
          color = Colors.red;
          backgroundColor = Colors.red[100];
      }
      return Column(
        children: [
          Container(
            padding: EdgeInsets.all(8),
            width: Get.width,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Tổng số đơn: ${model.package.items.length}",
                  style: TextStyle(
                      color: kPrimary,
                      fontWeight: FontWeight.bold,
                      fontSize: 16),
                ),
                Container(
                    padding: EdgeInsets.all(4),
                    decoration: BoxDecoration(
                        color: backgroundColor,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: color)),
                    child: Text(
                      status,
                      style:
                      TextStyle(color: color, fontSize: 12),
                    )),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              shrinkWrap: true,
              children: [
                ...model.package.items.map((item) => _buildOrderItem(item)).toList(),
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
                      '${item.code} - ${item.details.length} món',
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
          //_buildBottomBar(),
        ],
      ),
    );
  }

  // Container _buildBottomBar() {
  //   return Container(
  //     width: Get.width,
  //     padding: const EdgeInsets.only(left: 8, right: 8),
  //     child: FlatButton(
  //       onPressed: () async {
  //         // if (!isOrderDone) await model.putOrder(widget.storeId);
  //       },
  //       padding: EdgeInsets.only(left: 8.0, right: 8.0),
  //       textColor: Colors.white,
  //       color: kPrimary,
  //       shape: RoundedRectangleBorder(
  //           borderRadius: BorderRadius.all(Radius.circular(8))),
  //       child: Column(
  //         children: [
  //           SizedBox(
  //             height: 8,
  //           ),
  //           Text("${!false ? 'Đã nhận đơn' : 'Đã hoàn thành'}",
  //               style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
  //           SizedBox(
  //             height: 8,
  //           )
  //         ],
  //       ),
  //     ),
  //   );
  // }

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
          // orderItemPrice *= orderMaster.quantity;
          Widget displayName = Flexible(
            child: Text(item.details[index].productName,
              textAlign: TextAlign.start,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          );

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  displayName,
                  Flexible(
                    child: Text(
                      "x${item.details[index].quantity}",
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                ],
              ),
            ],
          );
        },
        separatorBuilder: (context, index) => Divider(),
        itemCount: item.details.length,
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
