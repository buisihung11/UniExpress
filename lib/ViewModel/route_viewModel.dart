import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:uni_express/Model/DAO/index.dart';
import 'package:uni_express/Model/DTO/index.dart';
import 'package:uni_express/ViewModel/base_model.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:uni_express/acessories/dialog.dart';
import 'package:uni_express/enums/view_status.dart';
import 'package:get/get.dart';
import 'package:uni_express/utils/request.dart';

import '../constraints.dart';

class RouteViewModel extends BaseModel {
  static RouteViewModel _instance;
  static RouteViewModel getInstance() {
    if (_instance == null) {
      _instance = RouteViewModel();
    }
    return _instance;
  }

  static void destroyInstance() {
    _instance = null;
  }

  RouteDTO route;
  RouteDAO _routeDAO;
  double mapHeight;
  CameraPosition initialLocation;
  GoogleMapController mapController;
  // the user's initial location and current location
// as it moves
  LocationData currentLocation;
// wrapper around the location API
  Location location;
  Set<Marker> markers = {};
  Set<Polyline> polylines = {};
  PolylinePoints polylinePoints = PolylinePoints();
  final String KEY = "AIzaSyBkc6Z-nPWsEfH58A0A0dKf5gF_ccRGtF0";
  Icon expandIcon;

  RouteViewModel() {
    _routeDAO = RouteDAO();
    initialLocation = CameraPosition(target: LatLng(0.0, 0.0));
    location = Location();
    location.onLocationChanged().listen((LocationData cLoc) {
      currentLocation = cLoc;
    });
  }

  Future<void> getRoutes(int id) async {
    try {
      setState(ViewStatus.Loading);
      mapHeight = Get.height * 0.45;
      expandIcon = Icon(Icons.open_in_full);
      route = await _routeDAO.getRoutes(id);

      if (route != null) {
        print("Base url: " + request.options.baseUrl);
        await _getCurrentLocation();
        await setMarkers();
        await setMapPin();
        setState(ViewStatus.Completed);
      }
    } catch (e) {
      print(e.toString());
      bool result = await showErrorDialog();
      if (result) {
        await getRoutes(id);
      } else
        setState(ViewStatus.Error);
    }
  }

  Future<void> setMarkers() async {
    if (markers.isNotEmpty) {
      markers.clear();
    }
    for (int i = 0; i < route.listPaths.length; i++) {
      final Uint8List desiredMarker =
          await getBytesFromCanvas((i + 1).toString());

      markers.add(Marker(
        markerId: MarkerId(route.listPaths[i].name),
        position: LatLng(route.listPaths[i].lat, route.listPaths[i].long),
        icon: BitmapDescriptor.fromBytes(desiredMarker),
        onTap: () {
          tapPath(route.listPaths[i]);
        },
      ));
    }
  }

  Future<void> setMapPin() async {
    if (polylines.isNotEmpty) {
      polylines.clear();
    }

    AreaDTO firstStation = route.listPaths
        .where((element) => element.id == route.listEdges[0].fromId)
        .first;
    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
      KEY,
      PointLatLng(currentLocation.latitude, currentLocation.longitude),
      PointLatLng(firstStation.lat, firstStation.long),
    );
    if (result.points.isNotEmpty) {
      polylines.add(Polyline(
        polylineId: PolylineId("first"),
        points:
            result.points.map((e) => LatLng(e.latitude, e.longitude)).toList(),
        color: kSecondary,
        width: 3,
      ));
    }

    for (int i = 0; i < route.listEdges.length; i++) {
      List<LatLng> path = [];
      AreaDTO fromStation = route.listPaths
          .where((element) => element.id == route.listEdges[i].fromId)
          .first;
      AreaDTO toStation = route.listPaths
          .where((element) => element.id == route.listEdges[i].toId)
          .first;

      if (fromStation.id != toStation.id) {
        PolylineResult rs = await polylinePoints.getRouteBetweenCoordinates(
          KEY,
          PointLatLng(fromStation.lat, fromStation.long),
          PointLatLng(toStation.lat, toStation.long),
        );
        if (rs.points.isNotEmpty) {
          rs.points.forEach((element) {
            path.add(LatLng(element.latitude, element.longitude));
          });
        }

        Polyline polyLine = Polyline(
          polylineId: PolylineId(i.toString()),
          points: path,
          color: kPrimary,
          width: 3,
        );
        polylines.add(polyLine);
      }
    }
  }

  void expandHeight() {
    if (mapHeight != Get.height) {
      mapHeight = Get.height;
      expandIcon = Icon(Icons.close_fullscreen);
    } else {
      mapHeight = Get.height * 0.45;
      expandIcon = Icon(Icons.open_in_full);
    }
    notifyListeners();
  }

  Future<void> _getCurrentLocation() async {
    currentLocation = await location.getLocation();
  }

  Future<Uint8List> getBytesFromCanvas(String text) async {
    final ui.PictureRecorder pictureRecorder = ui.PictureRecorder();
    final Canvas canvas = Canvas(pictureRecorder);
    final Paint paint1 = Paint()..color = Colors.orange;
    final int size = 80; //change this according to your app
    canvas.drawCircle(Offset(size / 2, size / 2), size / 2.0, paint1);
    TextPainter painter = TextPainter(textDirection: TextDirection.ltr);
    painter.text = TextSpan(
      text: text, //you can write your own text here or take from parameter
      style: TextStyle(
          fontSize: size / 4, color: Colors.white, fontWeight: FontWeight.bold),
    );
    painter.layout();
    painter.paint(
      canvas,
      Offset(size / 2 - painter.width / 2, size / 2 - painter.height / 2),
    );

    final img = await pictureRecorder.endRecording().toImage(size, size);
    final data = await img.toByteData(format: ui.ImageByteFormat.png);
    return data.buffer.asUint8List();
  }

  void tapPath(AreaDTO path) {
    route.listPaths.forEach((element) {
      if (element.id != path.id) {
        element.isSelected = false;
      }
    });
    path.isSelected = !path.isSelected;
    if (path.isSelected) {
      if (mapHeight == Get.height) {
        expandHeight();
      }
    }
    mapController.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: LatLng(path.lat, path.long),
          zoom: 16.0,
        ),
      ),
    );
    notifyListeners();
  }
}
