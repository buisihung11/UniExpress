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
    request.options.baseUrl = "http://13.212.101.182:8088/api/v1/";
    if(status != -1){
      res = await request.get('driver/5/batchs', queryParameters: {
        "size": size ?? DEFAULT_SIZE,
        "page": page ?? 1,
        "status": status
      });
    }else{
      res = await request.get('drivers/5/batchs', queryParameters: {
        "size": size ?? DEFAULT_SIZE,
        "page": page ?? 1
      });
    }
    request.options.baseUrl = "https://beanapi.unibean.net/api/";
    var jsonList = res.data["data"] as List;
    if(jsonList != null){
      List<BatchDTO> list = jsonList.map((e) => BatchDTO.fromJson(e)).toList();
      metaDataDTO = MetaDataDTO.fromJson(res.data["metadata"]);
      return list;
    }
    return null;
  }

  Future<PackageDTO> getPackage(int batchId, int packageId) async {
    final res = await request.get('batchs/${batchId}/packages/${packageId}', );
    return PackageDTO.fromJson(res.data);
  }
}