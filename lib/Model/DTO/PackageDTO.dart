import 'package:uni_express/Model/DTO/index.dart';

class PackageDTO {
  int packageId;
  int capacity;
  List<ItemDTO> items;

  PackageDTO({this.packageId, this.capacity, this.items});

  factory PackageDTO.fromJson(dynamic json) {
    return PackageDTO(
        packageId: json['id'],
        capacity: json['cap'],
        items:
            (json['items'] as List).map((e) => ItemDTO.fromJson(e)).toList());
  }
}

class ItemDTO {
  int id;
  String code;
  List<OrderItemDTO> orders;
  CustomerInfoDTO customer;

  ItemDTO({this.id, this.code, this.orders, this.customer});

  factory ItemDTO.fromJson(dynamic json) {
    return ItemDTO(id: json['id'], code: json['code'], orders: (json['orders'] as List)?.map((e) => OrderItemDTO.fromJSON(e))?.toList(), customer: json['customer'] != null ? CustomerInfoDTO.fromJSON(json['customer']) : null);
  }
}
