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

  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
  new GlobalKey<RefreshIndicatorState>();

  @override
  void initState() {
    super.initState();
    RootViewModel.getInstance().getSuppliers();
  }

  Future<void> refreshFetchOrder() async {
    await RootViewModel.getInstance().getSuppliers();
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
              Text(
                "Danh sách nhà cung cấp",
                style: TextStyle(
                    fontSize: 18,
                    color: Colors.deepOrange,
                    fontWeight: FontWeight.bold),
              ),
              _buildSupplier()
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSupplier() {
    return ScopedModelDescendant<RootViewModel>(
      builder: (context, child, model) {
        final status = model.status;
        if (status == ViewStatus.Loading)
          return AspectRatio(
            aspectRatio: 1,
            child: Center(child: CircularProgressIndicator()),
          );
        else if(status == ViewStatus.Error){
          return AspectRatio(
            aspectRatio: 1,
            child: Center(child: Text("Đã có sự cố xảy ra :)"),)
          );
        }
        if(model.listSupplier != null){
          List<Widget> list = List();
          model.listSupplier.forEach((element) {
            list.add(Container(
              margin: EdgeInsets.only(top: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.all(Radius.circular(8)),
              ),
              child: ListTile(
                onTap: () {
                  _settingModalBottomSheet(element.id);
                },
                contentPadding: EdgeInsets.fromLTRB(16, 8, 16, 8),
                title: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Brand ID: " + element.brand_id.toString(),
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.black,
                      ),
                    ),
                    SizedBox(
                      height: 8,
                    ),
                    Text(
                      "Brand name: " + element.brand_name,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.black,
                      ),
                    ),
                    SizedBox(
                      height: 8,
                    ),
                    Text(
                      "Địa chỉ: " + element.location,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.black,
                      ),
                    ),
                    SizedBox(
                      height: 8,
                    ),
                    Text(
                      "Liên hệ: " + element.contact_name,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.black,
                      ),
                    ),
                    SizedBox(
                      height: 8,
                    ),
                    Row(
                      children: [
                        Icon(Icons.phone),
                        SizedBox(width: 8,),
                        Text(
                          element.phone_number,
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ));
          });
          return RefreshIndicator(
            key: _refreshIndicatorKey,
            onRefresh: refreshFetchOrder,
            child: Column(
              children: [
                ...list
              ],
            ),
          );
        }
        return Container();

      },
    );
  }

  void _settingModalBottomSheet(int id) {
    // get orderDetail
    RootViewModel.getInstance().getStores(id);
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
            else if(status == ViewStatus.Error){
              return AspectRatio(
                  aspectRatio: 1,
                  child: Center(child: Text("Đã có sự cố xảy ra :)"),)
              );
            }

            List<Widget> list = new List();
            model.listStore.forEach((element) {
              list.add(
                Container(
                  margin: EdgeInsets.only(top: 8),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(8)),
                      color: kPrimary),
                  child: ListTile(
                      onTap: () {
                        Get.toNamed(RouteHandler.STORE_ORDER_DETAIL, arguments: element);
                      },
                      contentPadding: EdgeInsets.all(8),
                      title: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "ID: " + element.id.toString(),
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(
                            height: 4,
                          ),
                          Text(
                            "Tên: " + element.name,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(
                            height: 4,
                          ),
                          Text(
                            "Địa chỉ: " + element.location,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      )),
                ),
              );
            });

            return Container(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  SizedBox(height: 8),
                  Text(
                    "Danh sách cửa hàng",
                    style: TextStyle(
                        color: Colors.orange,
                        fontSize: 18,
                        fontWeight: FontWeight.bold),
                  ),
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
