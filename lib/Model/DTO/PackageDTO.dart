import 'package:uni_express/Model/DTO/index.dart';

class PackageDTO {
  int packageId;
  int capacity;
  List<ItemDTO> items;
  int actionType;
  bool isSelected;
  int status;
  AreaDTO fromLocation;
  AreaDTO toLocation;
  String driver;

  PackageDTO(
      {this.packageId,
      this.capacity,
      this.items,
      this.actionType,
      this.isSelected = false,
      this.status,
      this.fromLocation,
      this.toLocation,
      this.driver});

  PackageDTO.clone(PackageDTO dto) {
    this.packageId = dto.packageId;
    this.capacity = dto.capacity;
    this.items = dto.items;
    this.actionType = dto.actionType;
    this.isSelected = dto.isSelected;
    this.status = dto.status;
    this.fromLocation = dto.fromLocation;
    this.toLocation = dto.toLocation;
    this.driver = dto.driver;
  }

  factory PackageDTO.fromJson(dynamic json, {int type}) {
    return PackageDTO(
        packageId: json['id'],
        capacity: json['cap'],
        items: (json['items'] as List).map((e) => ItemDTO.fromJson(e)).toList(),
        status: json['status'],
        fromLocation: AreaDTO.fromJson(json['from_s']),
        toLocation: AreaDTO.fromJson(json['to_s']),
        driver: json['driver'] != null ? json['driver']['name'] : "");
  }
}

class ItemDTO {
  int id;
  String code;
  List<DetailDTO> details;
  CustomerInfoDTO customer;

  ItemDTO({this.id, this.code, this.details, this.customer});

  factory ItemDTO.fromJson(dynamic json) {
    return ItemDTO(
        id: json['id'],
        code: json['code'],
        details: (json['details'] as List)
            ?.map((e) => DetailDTO.fromJson(e))
            ?.toList(),
        customer: json['customer'] != null
            ? CustomerInfoDTO.fromJSON(json['customer'])
            : null);
  }
}

class DetailDTO {
  String productName;
  int quantity;

  DetailDTO({this.productName, this.quantity});

  factory DetailDTO.fromJson(dynamic json) {
    return DetailDTO(
        productName: json['product_name'], quantity: json['quantity']);
  }
}
