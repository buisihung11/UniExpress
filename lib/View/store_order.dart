import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:uni_express/ViewModel/index.dart';
import 'package:uni_express/acessories/appbar.dart';
import 'package:uni_express/acessories/drawer.dart';
import 'package:uni_express/enums/view_status.dart';
import 'package:uni_express/route_constraint.dart';

import '../constraints.dart';

class StoreOrderScreen extends StatefulWidget {
  StoreOrderScreen({Key key}) : super(key: key);

  @override
  _StoreOrderScreenState createState() => _StoreOrderScreenState();
}

class _StoreOrderScreenState extends State<StoreOrderScreen> {
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
    return ScopedModel<RootViewModel>(
      model: RootViewModel.getInstance(),
      child: Scaffold(
        drawer: DrawerMenu(),
        appBar: DefaultAppBar(
          title: "Lấy hàng",
        ),
        body: Container(
          margin: EdgeInsets.only(left: 16, right: 16),
          child: ListView(
            shrinkWrap: true,
            children: [
              SizedBox(
                height: 16,
              ),
              Text("Danh sách nhà cung cấp", style: TextStyle(
                fontSize: 18,
                color: Colors.deepOrange,
                fontWeight: FontWeight.bold
              ),),
              SizedBox(
                height: 16,
              ),
              _buildSupplier("Hung Bui"),
              SizedBox(
                height: 16,
              ),
              _buildSupplier("Dat Bui"),
              SizedBox(
                height: 16,
              ),
              _buildSupplier("Quoc Bui"),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSupplier(String name) {
    return Material(
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
        // side: BorderSide(color: Colors.red),
      ),
      child: ListTile(
        onTap: () {
          _settingModalBottomSheet();
        },
        contentPadding: EdgeInsets.fromLTRB(16, 8, 16, 8),
        title: Text(
          name,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: kPrimary,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
    );
  }

  void _settingModalBottomSheet() {
    // get orderDetail
    RootViewModel.getInstance().getStore();
    Get.bottomSheet(
      OrderDetailBottomSheet(),
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
  @override
  void initState() {
    super.initState();
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
      child: ScopedModel<RootViewModel>(
        model: RootViewModel.getInstance(),
        child: ScopedModelDescendant<RootViewModel>(
          builder: (context, child, model) {
            final status = model.status;
            if (status == ViewStatus.Loading)
              return AspectRatio(
                aspectRatio: 1,
                child: Center(child: CircularProgressIndicator()),
              );

            List<Widget> list = new List();
            model.list.forEach((element) {
              list.add(
                Container(
                  margin: EdgeInsets.only(top: 8),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(8)),
                      color: kPrimary),
                  child: ListTile(
                    onTap: () {
                      Get.toNamed(RouteHandler.STORE_ORDER_DETAIL);
                    },
                    contentPadding: EdgeInsets.all(8),
                    title: Text(
                      element.name + " - " + element.location,
                      textAlign: TextAlign.left,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              );
            });

            return Container(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  SizedBox(height: 8),
                  Text("Danh sách cửa hàng",style: TextStyle(
                    color: Colors.orange,
                    fontSize: 18,
                    fontWeight: FontWeight.bold
                  ),),
                  SizedBox(height: 8),
                  ...list
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
