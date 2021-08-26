import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:uni_express/Model/DTO/index.dart';
import 'package:uni_express/ViewModel/batch_viewModel.dart';
import 'package:uni_express/ViewModel/driver_route_viewModel.dart';
import 'package:uni_express/ViewModel/index.dart';
import 'package:uni_express/acessories/appbar.dart';
import 'package:uni_express/acessories/loading.dart';
import 'package:uni_express/enums/view_status.dart';
import 'package:uni_express/route_constraint.dart';
import 'package:uni_express/route_constraint.dart';
import 'package:uni_express/utils/index.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../constraints.dart';
import 'customer_order_detail.dart';

class CustomerOrderScreen extends StatefulWidget {
  CustomerOrderScreen();

  @override
  _CustomerOrderScreenState createState() => _CustomerOrderScreenState();
}

class _CustomerOrderScreenState extends State<CustomerOrderScreen> {
  OrderHistoryViewModel model;
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      new GlobalKey<RefreshIndicatorState>();
  TextEditingController _editingController = new TextEditingController();

  @override
  void initState() {
    super.initState();
    model = OrderHistoryViewModel();
    orderHandler();
  }

  Future<void> refreshFetchOrder() async {
    _editingController.clear();
    await model.getCustomerOrders();
  }

  Future<void> orderHandler() async {
    _editingController.clear();
    model.getCustomerOrders();
  }

  @override
  Widget build(BuildContext context) {
    return ScopedModel<OrderHistoryViewModel>(
      model:model,
      child: Scaffold(
        appBar: DefaultAppBar(title: "Danh sách đơn hàng",),
        floatingActionButton: _buildUpdateButton(),
        body: Container(
          color: Colors.white,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _searchBar(),

              Expanded(
                child: RefreshIndicator(
                  key: _refreshIndicatorKey,
                  onRefresh: refreshFetchOrder,
                  child: Container(
                    child: _buildOrders(),
                    color: Color(0xffefefef),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _searchBar() {
    return ScopedModelDescendant<OrderHistoryViewModel>(builder:
        (BuildContext context, Widget child, OrderHistoryViewModel model) {
      String hintText;
      switch (model.selectedFilter) {
        case SearchFilter.ID:
          hintText = "mã hóa đơn";
          break;
        case SearchFilter.NAME:
          hintText = "tên khách hàng";
          break;
        case SearchFilter.PHONE:
          hintText = "số điện thoại";
          break;
        default:
          hintText = "cái gì đó";
      }
      if(model.status == ViewStatus.Completed){
        return Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: TextFormField(
                      controller: _editingController,
                      decoration: InputDecoration(
                        border: new OutlineInputBorder(
                          borderRadius: const BorderRadius.all(
                            const Radius.circular(16),
                          ),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: Color(0xfff6f6f6),
                        suffixIcon: IconButton(
                          icon: Icon(Icons.clear, color: Colors.grey),
                          onPressed: () {
                            _editingController.clear();
                            model.searchOrderBy(_editingController.text);
                          },
                        ),
                        contentPadding: EdgeInsets.only(left: 15.0, top: 15.0),
                        hintText: 'Nhập $hintText để tìm',
                        hintStyle: TextStyle(color: Colors.grey),
                      ),
                      onChanged: (String input) {
                        model.searchOrderBy(input);
                      },
                    ),
                  ),
                ),
                Material(
                  color: Colors.transparent,
                  child: IconButton(
                    icon: Icon(Icons.filter_list),
                    onPressed: () async {
                      model.prepareFilter();
                      bool result = await Get.bottomSheet(_ListFilter(
                        model: model,
                      ));
                      if (result != null && result) {
                        await model.updateFilter(_editingController.text);
                      }
                    },
                  ),
                )
              ],
            ),
            (model.cacheOrderThumbnail != null && model.cacheOrderThumbnail.isNotEmpty) ? Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Text("Nơi nhận:", style: kTitleTextStyle.copyWith(fontSize: 14),),
                  SizedBox(width: 16,),
                  Text("${ model.selectedLocationIndex != -1 ? model.cacheOrderThumbnail.values.elementAt(model.selectedLocationIndex)[0].location.address : "Tất cả"}")
                ],
              ),
            ): SizedBox.shrink()
          ],
        );
      }return SizedBox.shrink();
    });
  }

  Widget _buildOrders() {
    return ScopedModelDescendant<OrderHistoryViewModel>(
        builder: (context, child, model) {
      final status = model.status;
      final orderSummaryList = model.orderThumbnail;
      if (status == ViewStatus.Loading)
        return Center(
          child: LoadingBean(),
        );
      else if (status == ViewStatus.Empty || orderSummaryList == null)
        return Container(
          child: SvgPicture.asset(
            'assets/images/order_history.svg',
            semanticsLabel: 'Acme Logo',
            fit: BoxFit.cover,
          ),
        );
      if (status == ViewStatus.Error)
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

      return ListView(
        padding: EdgeInsets.all(8),
        children: [
          _buildOrderSummary(orderSummaryList),
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

  Widget _buildOrderSummary(List<OrderDTO> orderSummary) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Text(
            "${model.isFilterDone ? 'Số đơn hoàn thành' : 'Số đơn còn lại'}: " +
                orderSummary.length.toString(),
            style: TextStyle(
              color: Colors.red,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
        ),
        // Padding(
        //   padding: const EdgeInsets.only(left: 24, bottom: 16),
        //   child: Text(
        //     DateFormat('dd/MM/yyyy').format(orderDate),
        //     style: TextStyle(
        //       color: kSecondary,
        //       fontWeight: FontWeight.bold,
        //       fontSize: 18,
        //     ),
        //   ),
        // ),
        ...orderSummary.map((order) => _buildOrderItem(order)).toList(),
      ],
    );
  }

  Widget _buildOrderItem(OrderDTO order) {
    return Container(
      // height: 80,
      margin: EdgeInsets.fromLTRB(0, 0, 0, 16),
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
        child: Column(
          children: [
            ListTile(
              onTap: () async {
                await _settingModalBottomSheet(order);
              },
              contentPadding: EdgeInsets.fromLTRB(8, 8, 8, 8),
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "${order.invoiceId}",
                    style: TextStyle(
                        fontSize: 16,
                        color: Colors.black,
                        fontWeight: FontWeight.bold),
                  ),
                  SizedBox(
                    height: 8,
                  ),
                  Text(
                    "KH: " + order.customer.name,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  SizedBox(
                    height: 4,
                  ),
                  Text(
                    order.customer.phone,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
              trailing: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "${formatPrice(order.finalAmount)}",
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      color: kPrimary,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
            // Text("Chi tiết", style: TextStyle(color: Colors.blue)),
          ],
        ),
      ),
    );
  }

  Future<void> _settingModalBottomSheet(order) async {
    // get orderDetail
    bool result = await Get.toNamed(
      RouteHandler.CUSTOMER_ORDER_DETAIL,
      arguments: CustomerOrderDetail(
        order: order,
      ),
    );
    if (result != null && result) {
      await refreshFetchOrder();
    }
  }

  Widget _buildUpdateButton(){
    return ScopedModelDescendant<OrderHistoryViewModel>(builder:(context, child, model) {
      if(model.status == ViewStatus.Completed){
        return FloatingActionButton(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          onPressed: () async {
            await BatchViewModel.getInstance().updateBatch();
          },
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Icon(Icons.check_circle, color: kPrimary, size: 32,),
          ),
        );
      }return Container();
    },);
  }
}

class _ListFilter extends StatefulWidget {
  OrderHistoryViewModel model;

  _ListFilter({this.model});

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _ListFilterState();
  }
}

class _ListFilterState extends State<_ListFilter> {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return ClipRRect(
      borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20), topRight: Radius.circular(20)),
      child: ScopedModel(
        model: widget.model,
        child: Scaffold(
          bottomNavigationBar: bottomBar(),
          body: Container(
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                    topRight: Radius.circular(32),
                    topLeft: Radius.circular(32))),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Color(0xffe8f2fb),
                        spreadRadius: 2,
                        blurRadius: 7,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.fromLTRB(8, 0, 0, 0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Chọn chức năng để lọc",
                        style: TextStyle(
                            color: Colors.grey,
                            fontSize: 18,
                            fontWeight: FontWeight.bold),
                      ),
                      Material(
                        color: Colors.transparent,
                        child: IconButton(
                          icon: Icon(Icons.close_rounded),
                          onPressed: () {
                            Get.back(result: false);
                          },
                        ),
                      )
                    ],
                  ),
                ),
                Expanded(
                  child: Material(
                    color: Colors.transparent,
                    child: ListView(
                      children: [filterType(), filterStatus(), filterLocation()],
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget filterType() {
    return ScopedModelDescendant<OrderHistoryViewModel>(
        builder: (context, child, model) {
      return Column(
        children: [
          Container(
            padding: EdgeInsets.all(8),
            color: Colors.grey[300],
            width: Get.width,
            child: Text(
              "Tìm kiếm theo:",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
          ListView.builder(
            physics: NeverScrollableScrollPhysics(),
            itemBuilder: (context, index) {
              return RadioListTile(
                title: Text(model.list[index].name),
                onChanged: (value) {
                  model.onChangeFilter(filter: value);
                },
                value: model.list[index].filter,
                groupValue: model.tmpFilter,
              );
            },
            itemCount: model.list.length,
            shrinkWrap: true,
          )
        ],
      );
    });
  }

  Widget filterStatus() {
    return ScopedModelDescendant<OrderHistoryViewModel>(
        builder: (context, child, model) {
      return Column(
        children: [
          Container(
            padding: EdgeInsets.all(8),
            color: Colors.grey[300],
            width: Get.width,
            child: Text(
              "Trạng thái đơn:",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
          CheckboxListTile(
            value: model.tmpStatus,
            onChanged: (value) {
              model.onChangeFilter(status: value);
            },
            title: Text('Đã hoàn thành'),
            controlAffinity: ListTileControlAffinity.leading,
          )
        ],
      );
    });
  }

  Widget filterLocation() {
    return ScopedModelDescendant<OrderHistoryViewModel>(
        builder: (context, child, model) {
          if(model.cacheOrderThumbnail != null && model.cacheOrderThumbnail.isNotEmpty){
            return Column(
              children: [
                Container(
                  padding: EdgeInsets.all(8),
                  color: Colors.grey[300],
                  width: Get.width,
                  child: Text(
                    "Khu vực:",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
                RadioListTile(
                  title: Text("Tất cả"),
                  onChanged: (value) {
                    model.onChangeFilter(location: value);
                  },
                  value: -1,
                  groupValue: model.tmpLocationIndex,
                ),
                ListView.builder(
                  physics: NeverScrollableScrollPhysics(),
                  itemBuilder: (context, index) {
                    List<OrderDTO> orders = model.cacheOrderThumbnail.values.elementAt(index);
                    return RadioListTile(
                      title: Text(orders[0].location.address),
                      onChanged: (value) {
                        model.onChangeFilter(location: value);
                      },
                      value: index,
                      groupValue: model.tmpLocationIndex,
                    );
                  },
                  itemCount: model.cacheOrderThumbnail.keys.length,
                  shrinkWrap: true,
                )
              ],
            );
          }return SizedBox.shrink();
        });
  }

  Widget bottomBar() {
    return ScopedModelDescendant<OrderHistoryViewModel>(
      builder: (context, child, model) {
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
                height: 8,
              ),
              FlatButton(
                onPressed: () async {
                  Get.back(result: true);
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
                    Text("Áp dụng",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16)),
                    SizedBox(
                      height: 8,
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
}
