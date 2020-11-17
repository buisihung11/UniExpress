class StoreDTO{
  int id;
  String name;
  String location;
  String invoice_id;
  String notes;
  String phone;


  StoreDTO({this.id, this.name, this.location, this.invoice_id, this.notes,
      this.phone});

  factory StoreDTO.fromJson(dynamic json){
    return StoreDTO(
      id: json['id'],
      name: json['name'],
      location: json['address'],
      invoice_id: json["invoice_id"],
      notes: json["notes"],
      phone: json["phone"]
    );
  }

  Map<String, dynamic> toJson(){
    return {
      "id" : id,
      "name" : name,
      "address": location,
      "invoice_id": invoice_id,
      "notes": notes,
      "phone": phone
    };
  }

  static List<StoreDTO> fromList(List list) =>
      list?.map((e) => StoreDTO.fromJson(e))?.toList();
}