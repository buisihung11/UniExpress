class SupplierDTO {
  int id;
  String name;
  String location;
  DateTime createDate;
  int brand_id;
  String brand_name;
  String contact_name;
  String phone_number;

  SupplierDTO(
      {this.id,
      this.name,
      this.location,
      this.createDate,
      this.brand_id,
      this.brand_name,
      this.contact_name,
      this.phone_number});

  factory SupplierDTO.fromJson(dynamic json) {
    return SupplierDTO(
        id: json['supplier_id'],
        name: json['name'],
        location: json['address'],
        createDate: DateTime.parse(json['create_date']),
        brand_id: json['brand_id'],
        brand_name: json['brand_name'],
        contact_name: json['contact_person'],
        phone_number: json['phone_number']);
  }

  Map<String, dynamic> toJson() {
    return {
      "supplier_id": id,
      "name": name,
      "address": location,
      "create_date": createDate.toIso8601String(),
      "brand_id": brand_id,
      "brand_name": brand_name,
      "contact_person": contact_name,
      "phone_number": phone_number
    };
  }
}
