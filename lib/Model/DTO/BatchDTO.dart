import 'package:uni_express/Model/DTO/RouteDTO.dart';
import 'package:uni_express/Model/DTO/index.dart';

class BatchDTO {
  int id;
  String timeSlot;
  int areaId;
  int status;
  int routingBatchId;
  String startDepot;
  RouteDTO route;
  int totalLoad;
  DateTime createdDate;

  BatchDTO(
      {this.id,
      this.timeSlot,
      this.status,
      this.route,
      this.routingBatchId,
      this.areaId,
      this.startDepot,
      this.totalLoad, this.createdDate});

  factory BatchDTO.fromJson(dynamic json) {
    return BatchDTO(
        id: json['id'],
        timeSlot: json['time_slot'],
        areaId: json['area_id'],
        status: json['status'],
        totalLoad: json['total_load'],
        startDepot: json['start_depot_name'],
        routingBatchId: json['routing_batch_id'],
        createdDate: DateTime.parse(json['created_date'])
    );
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
