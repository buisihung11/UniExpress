import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:uni_express/Model/DTO/index.dart';
import 'package:uni_express/View/DriverScreen/edge_detail.dart';
import 'package:uni_express/ViewModel/route_viewModel.dart';
import 'package:uni_express/acessories/appbar.dart';
import 'package:uni_express/acessories/dialog.dart';
import 'package:uni_express/acessories/loading.dart';
import 'package:uni_express/enums/view_status.dart';
import 'package:uni_express/route_constraint.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../constraints.dart';
import 'package:intl/intl.dart';

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
          title: "Chuyến hàng #${widget.batch.id}",
          subTitle: " ${DateFormat("HH:mm").format(widget.batch.startTime)} - ${DateFormat("HH:mm").format(widget.batch.endTime)}",
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

  Widget _buildTitle() {
    return ScopedModelDescendant<RouteViewModel>(
      builder: (context, child, model) {
        if (model.mapHeight != Get.height && model.status == ViewStatus.Completed) {
          return Container(
            padding: EdgeInsets.all(8),
            width: Get.width,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.only(topLeft: Radius.circular(32), topRight: Radius.circular(32)),
            ),
            child: Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Image(
                        width: 25,
                        height: 25,
                        image: AssetImage(
                            "assets/icons/shipper_motorbike.png"),
                      ),
                      SizedBox(width: 8,),
                      Text(
                        "Lộ trình",
                        style: TextStyle(
                            fontSize: 16,
                            color: kSecondary,
                            fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  FlatButton(onPressed: () async {
                    await showOptionDialog("Xác nhận hoàn tất chuyến hàng 🏁");
                  }, child: Text("Hoàn tất", style: TextStyle(color: Colors.white),), color: kPrimary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),)
                ],
              ),
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
              return ListView.builder(
                itemBuilder: (context, index) {
                  AreaDTO area = model.route.listPaths[index];
                  EdgeDTO edge = model.route.listEdges.firstWhere((element) => element.toId == area.id, orElse: () => null,);
                  return Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Container(
                          width: 8,
                          color: Colors.blue,
                          height: 64,
                          child: Center(
                            child: Container(
                              width: 8,
                              height: 8,
                              child: Material(
                                color: Colors.white,
                                shape: CircleBorder(),
                              ),
                            ),
                          ),
                        ),
                        Flexible(
                          child: Container(
                            decoration: BoxDecoration(
                                color: area.isSelected ? kPrimary : Colors.white,
                                border: Border(bottom: BorderSide(color: kBackgroundGrey[3]))
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
                                    "${area.name.toUpperCase()}",
                                    style: TextStyle(
                                        fontSize: 14,
                                        color: area.isSelected
                                            ? Colors.white
                                            : kPrimary,
                                        fontWeight: FontWeight.bold
                                    ),
                                  ),
                                  SizedBox(
                                    height: 8,
                                  ),
                                  edge != null ? Row(
                                    children: [
                                      Image(
                                        width: 20,
                                        height: 20,
                                        image: AssetImage("assets/icons/package.png"),
                                      ),
                                      SizedBox(width: 8,),
                                      Text.rich(TextSpan(text: "0", children: [
                                        TextSpan(text: "/${edge.actions.length}", style: TextStyle(
                                          fontSize: 14,
                                          color: area.isSelected
                                              ? Colors.white
                                              : Colors.black,
                                        ))
                                      ]),
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: area.isSelected
                                                ? Colors.yellow
                                                : Colors.orange,
                                          )),
                                    ],
                                  ) : SizedBox.shrink()
                                ],
                              ),
                              trailing: Material(
                                color: Colors.transparent,
                                child: index != 0
                                    ? InkWell(
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(
                                      "${index == model.route.listPaths.length - 1 ? '🎌' : ""} Chi tiết",
                                      style: TextStyle(
                                          color: area.isSelected
                                              ? Colors.white
                                              : Colors.orange,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  onTap: () {
                                    Get.toNamed(RouteHandler.EDGE,
                                        arguments: EdgeScreen(
                                          area: area,
                                          packages: model.route.listPackages,
                                          actions: edge.actions,
                                          batchId: widget.batch.id,
                                        ));
                                  },
                                )
                                    : Text(
                                  "🚩 Bắt đầu",
                                  style: TextStyle(
                                      color: area.isSelected
                                          ? Colors.white
                                          : Colors.orange,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),

                          ),
                        ),
                      ],
                    ),
                  );
                },
                itemCount: model.route.listPaths.length,
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
                  decoration: BoxDecoration(),
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
}
