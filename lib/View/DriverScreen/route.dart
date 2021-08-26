import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:uni_express/Model/DTO/index.dart';
import 'package:uni_express/View/DriverScreen/edge_detail.dart';
import 'package:uni_express/ViewModel/batch_viewModel.dart';
import 'package:uni_express/ViewModel/driver_route_viewModel.dart';
import 'package:uni_express/acessories/appbar.dart';
import 'package:uni_express/acessories/loading.dart';
import 'package:uni_express/enums/view_status.dart';
import 'package:uni_express/route_constraint.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../constraints.dart';
import 'package:flutter_icons/flutter_icons.dart';

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

  RouteViewModel model;

  @override
  void initState() {
    super.initState();
    model = RouteViewModel();
    model.getRoutes(widget.batch.routingBatchId);
  }

  Future<void> refreshFetchOrder() async {
    await model.getRoutes(widget.batch.routingBatchId);
  }

  @override
  Widget build(BuildContext context) {
    List<String> timeSlot = widget.batch.timeSlot.split(";");
    return ScopedModel<RouteViewModel>(
      model: model,
      child: Scaffold(
        appBar: DefaultAppBar(
          title: "Chuyến hàng #${widget.batch.id}",
          subTitle:
              " ${timeSlot[0].substring(0, 5)} - ${timeSlot[1].substring(0, 5)}",
        ),
        body: Column(
          children: [
            _buildMap(),
            _buildTitle(),
            _buildSupplier(),
          ],
        ),
        bottomNavigationBar: _bottomBar(),
      ),
    );
  }

  Widget _buildTitle() {
    return ScopedModelDescendant<RouteViewModel>(
      builder: (context, child, model) {
        if (model.mapHeight != Get.height &&
            model.status == ViewStatus.Completed) {
          return Container(
            padding: EdgeInsets.all(8),
            width: Get.width,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(32), topRight: Radius.circular(32)),
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
                        image: AssetImage("assets/icons/shipper_motorbike.png"),
                      ),
                      SizedBox(
                        width: 8,
                      ),
                      Text(
                        "Lộ trình",
                        style: TextStyle(
                            fontSize: 16,
                            color: kSecondary,
                            fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
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
                  EdgeDTO edge = model.route.listEdges.firstWhere(
                    (element) => element.toId == area.id,
                    orElse: () => null,
                  );
                  List<PackageDTO> listPick, listDeli;
                  Widget pickPackage = SizedBox.shrink();
                  Widget deliPackage = SizedBox.shrink();
                  if (edge != null) {
                    print(edge.packages[0].actionType.toString() +
                        " - " +
                        edge.toId.toString());
                    listPick = edge.packages
                        .where((element) =>
                            element.actionType == ActionType.PICKUP)
                        .toList();
                    if (listPick != null && listPick.isNotEmpty) {
                      List<PackageDTO> complete = listPick
                          .where((element) =>
                              (element.status == PackageStatus.PICKEDUP ||
                                  element.status == PackageStatus.DELIVERIED))
                          .toList();
                      pickPackage = Row(
                        children: [
                          Text.rich(
                              TextSpan(text: "${complete.length}", children: [
                                TextSpan(
                                    text: "/${listPick.length}",
                                    style: TextStyle(
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
                          SizedBox(
                            width: 8,
                          ),
                          Icon(
                            AntDesign.upcircleo,
                            color:
                                area.isSelected ? Colors.white : Colors.green,
                          ),
                        ],
                      );
                    }
                    listDeli = edge.packages
                        .where((element) =>
                            element.actionType == ActionType.DELIVERY)
                        .toList();
                    if (listDeli != null && listDeli.isNotEmpty) {
                      List<PackageDTO> complete = listDeli
                          .where(
                            (element) =>
                                element.status == PackageStatus.DELIVERIED,
                          )
                          .toList();
                      pickPackage = Row(
                        children: [
                          Text.rich(
                              TextSpan(text: "${complete.length}", children: [
                                TextSpan(
                                    text: "/${listDeli.length}",
                                    style: TextStyle(
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
                          SizedBox(
                            width: 8,
                          ),
                          Icon(
                            AntDesign.downcircleo,
                            color: area.isSelected
                                ? Colors.white
                                : Colors.redAccent,
                          ),
                        ],
                      );
                    }
                  }
                  return Container(
                    decoration: BoxDecoration(
                        color: area.isSelected ? kPrimary : Colors.white,
                        border: Border(
                            bottom: BorderSide(color: kBackgroundGrey[3]))),
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
                            "${index + 1}. ${area.name.toUpperCase()}",
                            style: TextStyle(
                                fontSize: 14,
                                color:
                                    area.isSelected ? Colors.white : kPrimary,
                                fontWeight: FontWeight.bold),
                          ),
                          SizedBox(
                            height: 8,
                          ),
                          edge != null
                              ? Row(
                                  children: [
                                    pickPackage,
                                    SizedBox(
                                      width: 8,
                                    ),
                                    deliPackage
                                  ],
                                )
                              : SizedBox.shrink()
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
                                onTap: () async {
                                  bool result =
                                      await Get.toNamed(RouteHandler.EDGE,
                                          arguments: EdgeScreen(
                                            area: area,
                                            edge: edge,
                                            batch: widget.batch,
                                          ));
                                  if (result != null && result) {
                                    model.getRoutes(widget.batch.routingBatchId,
                                        routeOnly: true);
                                  }
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
                              SizedBox(height: 16),
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
                        child: Padding(
                          padding:
                              const EdgeInsets.only(right: 8.0, top: 8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              ClipOval(
                                child: Material(
                                  color: Colors.blue[200], // button color
                                  child: InkWell(
                                    splashColor: Colors.blue, // inkwell color
                                    child: SizedBox(
                                      width: 40,
                                      height: 40,
                                      child: Icon(Icons.my_location),
                                    ),
                                    onTap: () {
                                      model.animateToLocation(model.currentLocation.latitude, model.currentLocation.longitude);
                                    },
                                  ),
                                ),
                              ),
                              SizedBox(width: 16),
                              ClipOval(
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

                            ],
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

  Widget _bottomBar() {
    return ScopedModelDescendant<RouteViewModel>(
      builder: (context, child, model) {
        if (model.mapHeight != Get.height &&
            model.status == ViewStatus.Completed) {
          int totalPick = model.route.listEdges.fold(
              0,
              (previousValue, edge) =>
                  edge.packages.fold(0, (previousValue, element) {
                    if (element.actionType == ActionType.PICKUP) {
                      return previousValue + 1;
                    }
                    return previousValue;
                  }) +
                  previousValue);
          int currentPick = model.route.listEdges.fold(
              0,
              (previousValue, edge) =>
                  edge.packages.fold(0, (previousValue, element) {
                    if (element.actionType == ActionType.PICKUP &&
                        (element.status == PackageStatus.PICKEDUP ||
                            element.status == PackageStatus.DELIVERIED)) {
                      return previousValue + 1;
                    }
                    return previousValue;
                  }) +
                  previousValue);
          int totalDeli = model.route.listEdges.fold(
              0,
              (previousValue, edge) =>
                  edge.packages.fold(0, (previousValue, element) {
                    if (element.actionType == ActionType.DELIVERY) {
                      return previousValue + 1;
                    }
                    return previousValue;
                  }) +
                  previousValue);
          int currentDeli = model.route.listEdges.fold(
              0,
              (previousValue, edge) =>
                  edge.packages.fold(0, (previousValue, element) {
                    if (element.actionType == ActionType.DELIVERY &&
                        element.status == PackageStatus.DELIVERIED) {
                      return previousValue + 1;
                    }
                    return previousValue;
                  }) +
                  previousValue);
          return Container(
            padding: const EdgeInsets.only(left: 8, right: 8),
            decoration: BoxDecoration(
              color: (currentPick == totalPick && currentDeli == totalDeli && widget.batch.status == BatchStatus.DRIVER_NOT_COMPLETED)
                  ? kPrimary
                  : Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey,
                  offset: Offset(0.0, 1.0), //(x,y)
                  blurRadius: 6.0,
                ),
              ],
            ),
            child: (currentPick == totalPick && currentDeli == totalDeli)
                ? ListView(
                    shrinkWrap: true,
                    children: [
                      SizedBox(
                        height: 8,
                      ),
                      (widget.batch.status == BatchStatus.DRIVER_NOT_COMPLETED) ? FlatButton(
                        onPressed: () async {
                          await BatchViewModel.getInstance().updateBatch();
                        },
                        child: Center(
                          child: Text("Hoàn tất chuyến hàng",
                              style: kDescriptionTextSyle.copyWith(
                                  fontSize: 16, color: Colors.white)),
                        ),
                      ) : Center(
                        child: Text("Chuyến hàng đã hoàn tất 👍",
                            style: kDescriptionTextSyle.copyWith(
                                fontSize: 16, color: kPrimary)),
                      ),
                      SizedBox(
                        height: 8,
                      )
                    ],
                  )
                : ListView(
                    shrinkWrap: true,
                    children: [
                      SizedBox(
                        height: 8,
                      ),
                      Text("Hoàn thành tất cả túi để hiển thị",
                          style: kDescriptionTextSyle.copyWith()),
                      FlatButton(
                        onPressed: () async {
                          //await showOptionDialog("Xác nhận hoàn tất mọi túi?");
                        },
                        padding: EdgeInsets.only(left: 8.0, right: 8.0),
                        textColor: Colors.white,
                        color: Colors.grey[300],
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(Radius.circular(8))),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              height: 8,
                            ),
                            // Center(child: Text("Túi đã lấy 4/10, túi đã giao 4/10", style: kTitleTextStyle.copyWith(fontSize: 16),)),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Text(
                                      "${currentPick}/$totalPick",
                                      style: kTitleTextStyle.copyWith(
                                          fontSize: 16),
                                    ),
                                    Text(
                                      "Túi đã lấy",
                                      style: kTitleTextStyle.copyWith(
                                          fontSize: 14),
                                    ),
                                  ],
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Text(
                                      "${currentDeli}/$totalDeli",
                                      style: kTitleTextStyle.copyWith(
                                          fontSize: 16),
                                    ),
                                    Text(
                                      "Túi đã giao",
                                      style: kTitleTextStyle.copyWith(
                                          fontSize: 14),
                                    ),
                                  ],
                                ),
                              ],
                            ),
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
        }
        return SizedBox.shrink();
      },
    );
  }
}
