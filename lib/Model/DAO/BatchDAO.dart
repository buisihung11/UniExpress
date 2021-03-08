import 'dart:io';

import 'package:uni_express/Model/DAO/BaseDAO.dart';
import 'package:uni_express/Model/DTO/BatchDTO.dart';
import 'package:uni_express/Model/DTO/index.dart';
import 'package:uni_express/utils/request.dart';
import 'package:dio/dio.dart';
import '../../constraints.dart';

class BatchDAO extends BaseDAO{
  Future<List<BatchDTO>> getBatches(int status, {int page, int size}) async {
    Response res;
    if(status != -1){
      res = await request.get('driver/batchs', queryParameters: {
        "size": size ?? DEFAULT_SIZE,
        "page": page ?? 1,
        "status": status
      });
    }else{
      res = await request.get('driver/batchs', queryParameters: {
        "size": size ?? DEFAULT_SIZE,
        "page": page ?? 1
      });
    }
    var jsonList = res.data["data"] as List;
    if(jsonList != null){
      List<BatchDTO> list = jsonList.map((e) => BatchDTO.fromJson(e)).toList();
      metaDataDTO = MetaDataDTO.fromJson(res.data["metadata"]);
      return list;
    }
    return null;
  }
}