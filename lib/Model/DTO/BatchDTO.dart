class BatchDTO {
  int id;
  DateTime startTime;
  DateTime endTime;
  AreaDTO area;
  int status;

  BatchDTO({this.id, this.startTime, this.endTime, this.area, this.status});

  factory BatchDTO.fromJson(dynamic json) {
    return BatchDTO(
      id: json['id'],
      startTime: DateTime.parse(json['start_time']),
      endTime: DateTime.parse(json['end_time']),
      area: AreaDTO.fromJson(json['area']),
      status: json['status']
    );
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

class AreaDTO{
  int id;
  String name;
  double lat;
  double long;
  bool isSelected;


  AreaDTO({this.id, this.name, this.lat, this.long, this.isSelected = false});

  factory AreaDTO.fromJson(dynamic json){
    return AreaDTO(
        id: json['id'],
        name: json['name'],
        long: json['long'],
        lat: json['lat']
    );;
  }

  Map<String, dynamic> toJson(){
    return {
      "id" : id,
      "name" : name,
      "long" : long,
      "lat" : lat
    };
  }

}