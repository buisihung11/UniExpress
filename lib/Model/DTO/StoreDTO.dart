class StoreDTO{
  int id;
  String name;
  String invoice_id;
  String notes;
  String phone;
  List<LocationDTO> locations;
  List<TimeSlot> timeSlots;


  StoreDTO({this.id, this.name, this.locations, this.invoice_id, this.notes,
      this.phone, this.timeSlots});

  factory StoreDTO.fromJson(dynamic json){

    StoreDTO dto = StoreDTO(
        id: json['id'],
        name: json['name'],
        invoice_id: json["invoice_id"],
        notes: json["notes"],
        phone: json["phone"]
    );

    if (json['locations'] != null) {
      var list = json['locations'] as List;
      dto.locations = list.map((e) => LocationDTO.fromJson(e)).toList();
    }

    if (json['time_slots'] != null) {
      var list = json['time_slots'] as List;
      dto.timeSlots = list.map((e) {
        return TimeSlot.fromJson(e);
      }).toList();
    }
    return dto;
  }

  Map<String, dynamic> toJson(){
    return {
      "id" : id,
      "name" : name,
      "locations": locations.map((e) => e.toJson()).toList(),
      "invoice_id": invoice_id,
      "notes": notes,
      "phone": phone,
      "time_slots": timeSlots.map((e) => e.toJson()).toList()
    };
  }

  static List<StoreDTO> fromList(List list) =>
      list?.map((e) => StoreDTO.fromJson(e))?.toList();
}


class LocationDTO {
  int id;
  String address;
  String lat;
  String long;
  bool isSelected;

  LocationDTO({this.id, this.address, this.lat, this.long, this.isSelected});

  factory LocationDTO.fromJson(dynamic json) {
    return LocationDTO(
        id: json['location_id'],
        address: json['address'],
        lat: json['lat'],
        long: json['long'],
        isSelected: json['isSelected'] ?? false);
  }

  Map<String, dynamic> toJson() {
    return {
      "location_id": id,
      "address": address,
      "lat": lat,
      "long": long,
      "isSelected": isSelected
    };
  }
}

class TimeSlot {
  int menuId;
  String from;
  String to;
  bool available;

  TimeSlot({this.menuId, this.from, this.to, this.available});

  factory TimeSlot.fromJson(dynamic json) {
    return TimeSlot(
        menuId: json['menu_id'],
        from: json['from'],
        to: json['to'].toString(),
        available: json['available'] ?? false);
  }

  Map<String, dynamic> toJson() {
    return {"menu_id": menuId, "from": from, "to": to, "available": available};
  }
}