

import 'package:uni_express/Model/DTO/SupplierDTO.dart';
import 'package:uni_express/utils/request.dart';

class SupplierDAO{

  // 1. Get Product List from API
  Future<List<SupplierDTO>> getSuppliers() async {
    final res = await request.get('/suppliers');
    var jsonList = res.data["data"] as List;
    if(jsonList != null){
      List<SupplierDTO> list = jsonList.map((e) => SupplierDTO.fromJson(e)).toList();
      return list;
    }
    return null;
  }

}