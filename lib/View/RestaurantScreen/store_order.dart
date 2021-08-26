import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:uni_express/Model/DTO/index.dart';
import 'package:uni_express/View/RestaurantScreen/store_order_detail.dart';
import 'package:uni_express/ViewModel/index.dart';
import 'package:uni_express/acessories/appbar.dart';
import 'package:uni_express/acessories/drawer.dart';
import 'package:uni_express/enums/view_status.dart';
import 'package:uni_express/route_constraint.dart';

// STORE = SUPPLIER
class StoreOrderScreen extends StatefulWidget {
  final StoreDTO store;
  StoreOrderScreen({Key key, this.store}) : super(key: key);

  @override
  _StoreOrderScreenState createState() => _StoreOrderScreenState();
}

class _StoreOrderScreenState extends State<StoreOrderScreen> {
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      new GlobalKey<RefreshIndicatorState>();

  @override
  void initState() {
    super.initState();
    RootViewModel.getInstance().getSuppliersFromStore(widget.store.id);
  }

  Future<void> refreshFetchOrder() async {
    await RootViewModel.getInstance().getSuppliersFromStore(widget.store.id);
  }

  @override
  Widget build(BuildContext context) {
    return ScopedModel<RootViewModel>(
      model: RootViewModel.getInstance(),
      child: SafeArea(
        child: Scaffold(
          body: Container(
            margin: EdgeInsets.only(left: 16, right: 16),
            child: Column(
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
                Expanded(child: _buildSupplier())
              ],
            ),
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
        else if (status == ViewStatus.Error) {
          return AspectRatio(
              aspectRatio: 1,
              child: Center(
                child: Text("Đã có sự cố xảy ra :)"),
              ));
        }
        if (model.listSupplier != null) {
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
                  _settingModalBottomSheet(element);
                },
                contentPadding: EdgeInsets.fromLTRB(16, 8, 16, 8),
                title: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      height: 8,
                    ),
                    Text(
                      "Name: ${element.name}",
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.black,
                      ),
                    ),
                    SizedBox(
                      height: 8,
                    ),
                    Text(
                      "Địa chỉ: ${element.location ?? "..."}",
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.black,
                      ),
                    ),
                    SizedBox(
                      height: 8,
                    ),
                    Text(
                      "Liên hệ: ${element.contact_name ?? "..."}",
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.black,
                      ),
                    ),
                    SizedBox(
                      height: 8,
                    ),
                  ],
                ),
              ),
            ));
          });
          return RefreshIndicator(
            key: _refreshIndicatorKey,
            onRefresh: refreshFetchOrder,
            child: ListView(
              shrinkWrap: true,
              children: [...list],
            ),
          );
        }
        return Container();
      },
    );
  }

  Future<void> _settingModalBottomSheet(SupplierDTO supplierDTO) async {
    // get orderDetail

    bool result = await Get.toNamed(RouteHandler.STORE_ORDER_DETAIL,
        arguments: StoreOrderDetailScreen(
          supplier: supplierDTO,
          storeId: widget.store.id,
        ));
    if (result != null && result) {
      await refreshFetchOrder();
    }
  }
}
