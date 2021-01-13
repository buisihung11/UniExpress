import 'package:dio/dio.dart';
import 'package:uni_express/Model/DTO/index.dart';
import 'package:uni_express/utils/request.dart';

import '../../constraints.dart';


class ProductDAO {
  // 1. Get Product List from API
  Future<List<ProductDTO>> getProducts(int store_id) async {
    final res = await request.get('products', queryParameters: {
      "brand-id": UNIBEAN_BRAND,
      "store-id": store_id,
      "fields": "ChildProducts",
      "size": 100
    });
    //final res = await Dio().get("http://api.dominos.reso.vn/api/v1/products");
    final products = ProductDTO.fromList(res.data["data"]);
    return products;
  }

  Future<List<ProductDTO>> getExtraProducts(
      int cat_id, String sup_id, int store_id) async {
    print("Category id: " + cat_id.toString());
    final res = await request.get('/extra-products', queryParameters: {
      "brand-id": UNIBEAN_BRAND,
      "cat-id": cat_id,
      "store-id": store_id,
      "supplier-id": sup_id,
    });
    final products = ProductDTO.fromList(res.data['data']);
    return products;
  }

  // dynamic normalizeProducts(dynamic data) {
  //   final products = data["products"];
  //   final storeId = data["id"];
  //   final storename = data["name"];
  //
  //   return products.map((e) {
  //     e['storeId'] = storeId;
  //     e['storeName'] = storename;
  //     return e;
  //   }).toList();
  // }
}
