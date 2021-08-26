import 'package:uni_express/Model/DAO/BaseDAO.dart';
import 'package:uni_express/Model/DTO/BatchDTO.dart';
import 'package:uni_express/Model/DTO/index.dart';
import 'package:uni_express/ViewModel/batch_viewModel.dart';
import 'package:uni_express/utils/request.dart';
import 'package:dio/dio.dart';
import 'package:uni_express/utils/shared_pref.dart';
import '../../constraints.dart';

class BatchDAO extends BaseDAO {
  Future<List<BatchDTO>> getBatches(int status, int role, {int id, int page, int size}) async {
    String url;
    if (role == StaffRole.DRIVER) {
      BatchViewModel.getInstance().batchStatus = [
        -1,
        BatchStatus.DRIVER_NOT_COMPLETED,
        BatchStatus.DRIVER_COMPLETED
      ];
      url = "driver/batchs";
    } else {
      BatchViewModel.getInstance().batchStatus = [
        -1,
        BatchStatus.BEANER_NEW,
        BatchStatus.BEANER_COMPLETED
      ];
      url = "beaner/batchs";
    }
    Map<String, dynamic> query = {  "size": size ?? DEFAULT_SIZE,
      "page": page ?? 1,};
    if(status != -1){
      query["status"] = status;
    }
    if(id != null){
      query["routing-batch-id"]= id;
    }

    Response res = await request.get(url,
        queryParameters: query);
    //request.options.baseUrl = "https://beanapi.unibean.net/api/";
    var jsonList = res.data["data"] as List;
    if (jsonList != null) {
      List<BatchDTO> list = jsonList.map((e) => BatchDTO.fromJson(e)).toList();
      metaDataDTO = MetaDataDTO.fromJson(res.data["metadata"]);
      return list;
    }
    return null;
  }

  Future<RouteDTO> getRoutes(int id) async {
    //request.options.baseUrl = "http://13.212.101.182:8089/api/v1/";
    final res = await request.get(
      'driver/batchs/$id',
    );
    //request.options.baseUrl = "https://beanapi.unibean.net/api/";
    var jsonList = res.data["data"]["routes"] as List;
    if (jsonList != null) {
      List<PackageDTO> packages = (res.data["data"]['packages'] as List)
          .map((e) => PackageDTO.fromJson(e))
          .toList();
      List<RouteDTO> routes =
          jsonList.map((e) => RouteDTO.fromJson(e, packages)).toList();
      return routes[0];
    }
    return null;
  }

  Future<List<PackageDTO>> getPackages(int id) async {
    //request.options.baseUrl = "http://13.212.101.182:8089/api/v1/";
    final res = await request.get(
      'beaner/batchs/$id/packages',
    );
    //request.options.baseUrl = "https://beanapi.unibean.net/api/";
    var jsonList = res.data["data"] as List;
    if (jsonList != null) {
      List<PackageDTO> packages =
          jsonList.map((e) => PackageDTO.fromJson(e)).toList();
      return packages;
    }
    return null;
  }

  Future<void> putBatch(int batchId, int role) async {
    if (role == StaffRole.DRIVER) {
      await request.put('driver/batchs/${batchId}');
    } else {
      await request.put('beaner/batchs/${batchId}');
    }
  }
}
