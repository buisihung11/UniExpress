

import 'package:uni_express/Model/DTO/index.dart';
import 'package:uni_express/utils/request.dart';

class StoreDAO {
  // 1. Get Product List from API


  Future<List<StoreDTO>> getVirtualStores() async {
    final res = await request.get('stores', queryParameters: {
      // "type": VIRTUAL_STORE_TYPE,
    });
    var jsonList = res.data["data"] as List;
    if(jsonList != null){
      List<StoreDTO> list = jsonList.map((e) => StoreDTO.fromJson(e)).toList();
      return list;
    }
    return null;
  }

}
