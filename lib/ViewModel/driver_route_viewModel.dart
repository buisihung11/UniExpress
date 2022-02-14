import 'package:flutter/material.dart';
import 'package:uni_express/Model/DAO/index.dart';
import 'package:uni_express/Model/DTO/index.dart';
import 'package:uni_express/ViewModel/base_model.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:uni_express/enums/view_status.dart';
import 'package:get/get.dart';
import '../constraints.dart';

class RouteViewModel extends BaseModel {
  RouteDTO route;
  BatchDAO _batchDAO;
  double mapHeight;
  CameraPosition initialLocation;
  GoogleMapController mapController;
  // the user's initial location and current location
// as it moves
  LocationData currentLocation;
// wrapper around the location API
  Location locationController;
  Set<Marker> markers = {};
  Set<Polyline> polylines = {};
  PolylinePoints polylinePoints = PolylinePoints();
  Icon expandIcon;

  RouteViewModel() {
    _batchDAO = BatchDAO();
    initialLocation = CameraPosition(target: LatLng(0.0, 0.0));
    locationController = Location();
    // locationController.onLocationChanged().listen((LocationData cLoc) {
    //   currentLocation = cLoc;
    //   notifyListeners();
    // });
  }

  Future<void> getRoutes(int id, {bool routeOnly = false}) async {
    try {
      setState(ViewStatus.Loading);
      mapHeight = Get.height * 0.45;
      expandIcon = Icon(Icons.open_in_full);
      route = await _batchDAO.getRoutes(id);

      if (route != null) {
        if (!routeOnly) {
          await _getCurrentLocation();
          await setMarkers();
          await setMapPin();
        }
        setState(ViewStatus.Completed);
      }
    } catch (e, stacktrace) {
      print(stacktrace.toString());
      setState(ViewStatus.Error);
    }
  }

  Future<void> setMarkers() async {
    try {
      if (markers.isNotEmpty) {
        markers.clear();
      }
      for (int i = 0; i < route.listPaths.length; i++) {
        BitmapDescriptor bitmap = await BitmapDescriptor.fromAssetImage(
            ImageConfiguration(
              size: Size(16, 16),
            ),
            "assets/icons/location.png");

        markers.add(Marker(
          infoWindow: InfoWindow(
            title: '${i + 1}. ${route.listPaths[i].name}',
          ),
          markerId: MarkerId("store: ${i + 1}"),
          position: LatLng(route.listPaths[i].lat, route.listPaths[i].long),
          icon: bitmap,
          onTap: () {
            tapPath(route.listPaths[i]);
          },
        ));
      }
    } catch (e, stacktrace) {
      print("Error: " + e.toString() + stacktrace.toString());
    }
  }

  Future<void> setMapPin() async {
    if (polylines.isNotEmpty) {
      polylines.clear();
    }

    List<AreaDTO> midPolyline =
        route.listPaths.sublist(1, route.listPaths.length - 1);

    AreaDTO beginStation = route.listPaths.first;
    AreaDTO endStation = route.listPaths.last;

    PolylineResult rs = await polylinePoints.getRouteBetweenCoordinates(
        MAP_KEY,
        PointLatLng(beginStation.lat, beginStation.long),
        PointLatLng(endStation.lat, endStation.long),
        wayPoints: midPolyline
            .map(
              (e) => PolylineWayPoint(
                  location: "${e.lat},${e.long}", stopOver: true),
            )
            .toList());

    Polyline polyLine = Polyline(
      polylineId: PolylineId("POLYLINE"),
      points: rs.points.map((e) => LatLng(e.latitude, e.longitude)).toList(),
      color: kPrimary,
      width: 5,
    );
    polylines.add(polyLine);
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
    currentLocation = await locationController.getLocation();
  }

  // Future<Uint8List> addLabelToImage(String imagePath, String label) async {
  //   try{
  //     String path = await rootBundle.loadString(imagePath);
  //     print("Path: " + path);
  //     final image = decodeImage(File(path).readAsBytesSync());
  //     drawString(image, arial_14, 0, 0, label);
  //     return encodePng(image);
  //   }catch (e, stacktrace){
  //     print("Error" + e.toString() + stacktrace.toString());
  //   }
  // }

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
    animateToLocation(path.lat, path.long);
  }

  void animateToLocation(double lat, double long) {
    mapController.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: LatLng(lat, long),
          zoom: 16.0,
        ),
      ),
    );
    notifyListeners();
  }
}
