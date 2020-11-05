import 'package:flutter/foundation.dart';
import 'package:uni_express/Bussiness/BussinessHandler.dart';

import '../../constraints.dart';


class ProductDTO {
  int id;
  int productInMenuId;
  String name;
  String description;
  int type;
  String imageURL;
  List<ProductDTO> listChild;
  int catergoryId;
  // List<int> extraId;
  String supplierId;
  List<ProductDTO> extras;
  // update
  List<double> prices;
  bool hasExtra;
  Map attributes;
  int defaultQuantity;
  int min;
  int max;
  bool isAnd;
  int generalId;

  @override
  String toString() {
    return 'ProductDTO{id: $id, name: $name, description: $description, type: $type, imageURL: $imageURL, listChild: $listChild, catergoryId: $catergoryId, supplierId: $supplierId, extras: $extras, prices: $prices, hasExtra: $hasExtra, attributes: $attributes, defaultQuantity: $defaultQuantity, min: $min, max: $max, isAnd: $isAnd}';
  }

  ProductDTO(this.id,
      {this.name,
      this.productInMenuId,
      this.imageURL,
      this.description,
      this.type,
      this.listChild,
      this.catergoryId,
      this.prices,
      this.supplierId,
      this.attributes,
      this.hasExtra,
      this.defaultQuantity,
      this.isAnd,
      this.max,
      this.min,
      this.generalId}); // balance. point;

  factory ProductDTO.fromJson(dynamic json) {
    var type = json['product_type_id'] as int;
    var jsonExtra = json['extra_category_id'] as List;
    List<double> prices = List.filled(10, 0);
    // List<int> listExtra = jsonExtra.cast<int>().toList();

    ProductDTO product = ProductDTO(json["product_id"],
        name: json['product_name'] as String,
        productInMenuId: json['product_in_menu_id'],
        // price: double.parse(json['price'].toString()),
        description: json['description'] as String,
        type: type,
        imageURL: json['pic_url'] as String,
        catergoryId: json['category_id'],
        supplierId: json['supplier_id'] as String,
        // prices: prices,
        // extraId: listExtra,
        hasExtra: json['has_extra'] as bool,
        attributes: json["attributes"] as Map,
        defaultQuantity: json["default"] ?? 0,
        min: json["min"] ?? 0,
        max: json["max"] ?? 0,
        generalId: json['general_product_id']);

    // prices
    for (int i = 0; i < BussinessHandler.PRICE_QUANTITY; i++) {
      prices[i] = (json["price${i + 1}"] as double) ?? json["price"] as double;
    }
    product.prices = prices;

    switch (type) {
      case ProductType.MASTER_PRODUCT:
        var listChildJson = json['child_products'] as List;

        List<ProductDTO> listChild =
            listChildJson.map((e) => ProductDTO.fromJson(e)).toList();

        product.listChild = listChild;
        break;
      case ProductType.COMPLEX_PRODUCT:
        if (product.hasExtra != null && product.hasExtra) {
          var listExtraJson = json['extras'] as List;

          List<ProductDTO> listExtra =
              listExtraJson?.map((e) => ProductDTO.fromJson(e))?.toList();

          product.extras = listExtra;
        }
        break;
      default:
        break;
    }

    return product;
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> prodJson = {
      "product_id": id,
      "product_in_menu_id": productInMenuId,
      "product_name": name,
      // price: double.parse(json['price'].toString()),
      "description": description,
      "product_type_id": type,
      "pic_url": imageURL,
      "catergory_id": catergoryId,
      "child_products": listChild,
      "supplier_id": supplierId,
      "hasExtra": hasExtra,
      "attributes": attributes,
      "default": defaultQuantity,
      "min": min,
      "max": max,
      "extras": extras,
      "general_product_id": generalId
    };

    Map<String, dynamic> pricesMap = new Map();

    for (var i = 0; i < prices.length; i++) {
      pricesMap.addAll({"price${i + 1}": prices[i]});
    }

    return prodJson..addAll(pricesMap);
  }

  static List<ProductDTO> fromList(dynamic jsonList) {
    var list = jsonList as List;
    return list.map((map) => ProductDTO.fromJson(map)).toList();
  }

  ProductDTO getChildByAttributes(Map attributes) {
    return this
        .listChild
        .firstWhere((child) => mapEquals(child.attributes, attributes));
  }
}

class ProductChild {
  String attribute;
  List<ProductDTO> list;

  ProductChild({this.attribute, this.list});

  Map<String, dynamic> toJson() {
    List listProducts = list.map((e) => e.toJson()).toList();
    return {"attribute_name": attribute, "products": listProducts};
  }

  factory ProductChild.fromJson(dynamic json) {
    List<ProductDTO> listProducts = ProductDTO.fromList(json['products']);
    return ProductChild(
      attribute: json["attribute_name"] as String,
      list: listProducts,
    );
  }
}
