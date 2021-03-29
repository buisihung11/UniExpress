import 'package:uni_express/Model/DTO/RouteDTO.dart';
import 'package:uni_express/Model/DTO/index.dart';

class BatchDTO {
  int id;
  DateTime startTime;
  DateTime endTime;
  AreaDTO area;
  int status;
  RouteDTO route;
  int totalDistance;

  BatchDTO(
      {this.id,
      this.startTime,
      this.endTime,
      this.area,
      this.status,
      this.route,
      this.totalDistance});

  factory BatchDTO.fromJson(dynamic json) {
    RouteDTO route;
    var jsonList = json["routes"] as List;
    if (jsonList != null) {
      List<RouteDTO> routes =
          jsonList.map((e) => RouteDTO.fromJson(e)).toList();
      routes[0].listPackages = (json['packages'] as List)
          .map((e) => PackageDTO.fromJson(e))
          .toList();
      route = routes[0];
    }
    return BatchDTO(
        id: json['id'],
        startTime: DateTime.parse(json['start_time']),
        endTime: DateTime.parse(json['end_time']),
        area: AreaDTO.fromJson(json['area']),
        status: json['status'],
        route: route,
        totalDistance: json['total_distance']);
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "start_time": startTime.toIso8601String(),
      "end_time": endTime.toIso8601String(),
      "area": area.toJson(),
      "status": status
    };
  }
}

class AreaDTO {
  int id;
  String name;
  double lat;
  double long;
  bool isSelected;

  AreaDTO({this.id, this.name, this.lat, this.long, this.isSelected = false});

  factory AreaDTO.fromJson(dynamic json) {
    return AreaDTO(
        id: json['id'],
        name: json['name'],
        long: json['long'],
        lat: json['lat']);
    ;
  }

  Map<String, dynamic> toJson() {
    return {"id": id, "name": name, "long": long, "lat": lat};
  }
}
