import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:uni_express/Model/DTO/index.dart';
import 'package:uni_express/View/DriverScreen/edge_detail.dart';
import 'package:uni_express/View/store_order_detail.dart';
import 'package:uni_express/ViewModel/route_viewModel.dart';
import 'package:uni_express/acessories/appbar.dart';
import 'package:uni_express/acessories/loading.dart';
import 'package:uni_express/enums/view_status.dart';
import 'package:uni_express/route_constraint.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../constraints.dart';

// STORE = SUPPLIER
class RouteScreen extends StatefulWidget {
  final BatchDTO batch;
  RouteScreen({Key key, this.batch}) : super(key: key);

  @override
  _RouteScreenState createState() => _RouteScreenState();
}

class _RouteScreenState extends State<RouteScreen> {
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      new GlobalKey<RefreshIndicatorState>();

  @override
  void initState() {
    super.initState();
    RouteViewModel.getInstance().getRoutes(widget.batch.id);
  }

  Future<void> refreshFetchOrder() async {
    await RouteViewModel.getInstance().getRoutes(widget.batch.id);
  }

  @override
  Widget build(BuildContext context) {
    return ScopedModel<RouteViewModel>(
      model: RouteViewModel.getInstance(),
      child: Scaffold(
        appBar: DefaultAppBar(
          title: "Chuyến hàng ${widget.batch.id}",
        ),
        body: Column(
          children: [
            _buildMap(),
            _buildTitle(),
            _buildSupplier(),
          ],
        ),
      ),
    );
  }

  Widget _buildTitle(){
    return ScopedModelDescendant<RouteViewModel>(
      builder: (context, child, model) {
        if(model.mapHeight != Get.height){
          return Container(
            width: Get.width,
            padding: EdgeInsets.all(8),
            color: Colors.red,
            child: Text(
              "Danh sách điểm đến",
              style: TextStyle(
                  fontSize: 16,
                  color: Colors.white,
                  fontWeight: FontWeight.bold),
            ),
          );
        }
        return SizedBox.shrink();
      },
    );
  }

  Widget _buildSupplier() {
    return Expanded(
      child: RefreshIndicator(
        key: _refreshIndicatorKey,
        onRefresh: refreshFetchOrder,
        child: ScopedModelDescendant<RouteViewModel>(
          builder: (context, child, model) {
            final status = model.status;
            if (status == ViewStatus.Loading)
              return AspectRatio(
                aspectRatio: 1,
                child: Center(child: LoadingBean()),
              );
            else if (status == ViewStatus.Error) {
              return ListView(
                children: [
                  AspectRatio(
                      aspectRatio: 1,
                      child: Center(
                        child: Text("Đã có sự cố xảy ra :)"),
                      )),
                ],
              );
            }
            if (model.route != null && model.mapHeight != Get.height) {
              List<Widget> list = List();
              list.add(Container(
                margin: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: model.route.listPaths[0].isSelected ? kPrimary : Colors.white,
                  borderRadius: BorderRadius.all(Radius.circular(8)),
                ),
                child: ListTile(
                    onTap: () {
                      model.tapPath(model.route.listPaths[0]);
                    },
                    contentPadding: EdgeInsets.fromLTRB(16, 8, 16, 8),
                    title: Text(
                      "${model.route.listPaths[0].name}",
                      style: TextStyle(
                        fontSize: 14,
                        color: model.route.listPaths[0].isSelected
                            ? Colors.white
                            : Colors.black,
                      ),
                    ),
                    trailing: Text(
                      "Bắt đầu 🚩",
                      style: TextStyle(color: model.route.listPaths[0].isSelected
                          ? Colors.white
                          : Colors.black,),
                    )),
              ));
              model.route.listEdges.forEach((element) {
                AreaDTO area = model.route.listPaths
                    .where((area) => area.id == element.toId)
                    .first;

                list.add(Container(
                  margin: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: area.isSelected ? kPrimary : Colors.white,
                    borderRadius: BorderRadius.all(Radius.circular(8)),
                  ),
                  child: ListTile(
                      onTap: () {
                        model.tapPath(area);
                      },
                      contentPadding: EdgeInsets.fromLTRB(16, 8, 16, 8),
                      title: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "${area.name}",
                            style: TextStyle(
                              fontSize: 14,
                              color: area.isSelected
                                  ? Colors.white
                                  : Colors.black,
                            ),
                          ),
                          SizedBox(
                            height: 8,
                          ),

                          Text("📦 ${element.packages.length}",
                              style: TextStyle(
                                fontSize: 14,
                                color: area.isSelected
                                    ? Colors.white
                                    : Colors.black,
                              ))
                        ],
                      ),
                      trailing: FlatButton(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                        padding: EdgeInsets.all(4),
                        color: Colors.orange,
                        child: Text(
                          "Chi tiết",
                          style: TextStyle(color: Colors.white),
                        ),
                        onPressed: () {
                          Get.toNamed(RouteHandler.EDGE, arguments: EdgeScreen(area: area, pakages: element.packages,));
                        },
                      )),
                ));
              });
              return ListView(
                children: [
                  ...list
                ],
              );
            }
            print("expand map");
            return SizedBox.shrink();
          },
        ),
      ),
    );
  }

  Widget _buildMap() {
    return ScopedModelDescendant<RouteViewModel>(
      builder: (context, child, model) {
        switch (model.status) {
          case ViewStatus.Completed:
            return AnimatedContainer(
              duration: Duration(milliseconds: 300),
              child: Container(
                  height: model.mapHeight - 80,
                  width: Get.width,
                  decoration: BoxDecoration(
                      border: Border(
                          bottom: BorderSide(color: kBackgroundGrey[4]))),
                  child: Stack(
                    children: <Widget>[
                      // Map View
                      GoogleMap(
                        markers: model.markers,
                        initialCameraPosition: model.initialLocation,
                        myLocationEnabled: true,
                        myLocationButtonEnabled: false,
                        mapType: MapType.normal,
                        zoomGesturesEnabled: true,
                        zoomControlsEnabled: false,
                        polylines: model.polylines,
                        onMapCreated: (GoogleMapController controller) {
                          model.mapController = controller;
                          model.mapController.animateCamera(
                            CameraUpdate.newCameraPosition(
                              CameraPosition(
                                target: LatLng(model.currentLocation.latitude,
                                    model.currentLocation.longitude),
                                zoom: 18.0,
                              ),
                            ),
                          );
                        },
                      ),
                      // Show zoom buttons
                      SafeArea(
                        child: Padding(
                          padding: const EdgeInsets.only(left: 10.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              ClipOval(
                                child: Material(
                                  color: Colors.blue[100], // button color
                                  child: InkWell(
                                    splashColor: Colors.blue, // inkwell color
                                    child: SizedBox(
                                      width: 30,
                                      height: 30,
                                      child: Icon(Icons.add),
                                    ),
                                    onTap: () {
                                      model.mapController.animateCamera(
                                        CameraUpdate.zoomIn(),
                                      );
                                    },
                                  ),
                                ),
                              ),
                              SizedBox(height: 20),
                              ClipOval(
                                child: Material(
                                  color: Colors.blue[100], // button color
                                  child: InkWell(
                                    splashColor: Colors.blue, // inkwell color
                                    child: SizedBox(
                                      width: 30,
                                      height: 30,
                                      child: Icon(Icons.remove),
                                    ),
                                    onTap: () {
                                      model.mapController.animateCamera(
                                        CameraUpdate.zoomOut(),
                                      );
                                    },
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                      SafeArea(
                        child: Align(
                          alignment: Alignment.topRight,
                          child: Padding(
                            padding:
                                const EdgeInsets.only(right: 8.0, top: 8.0),
                            child: ClipOval(
                              child: Material(
                                color: Colors.green[200], // button color
                                child: InkWell(
                                  splashColor: Colors.green, // inkwell color
                                  child: SizedBox(
                                    width: 40,
                                    height: 40,
                                    child: model.expandIcon,
                                  ),
                                  onTap: () {
                                    model.expandHeight();
                                  },
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  )),
            );
          default:
            return Container();
        }
      },
    );
  }

  Future<void> _onTapSupplier(SupplierDTO supplierDTO) async {
    // get orderDetail

    bool result = await Get.toNamed(RouteHandler.STORE_ORDER_DETAIL,
        arguments: StoreOrderDetailScreen(
          supplier: supplierDTO,
          storeId: widget.batch.area.id,
        ));
    if (result != null && result) {
      await refreshFetchOrder();
    }
  }


}
