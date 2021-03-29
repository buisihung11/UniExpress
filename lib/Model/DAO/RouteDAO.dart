import 'package:uni_express/Model/DTO/index.dart';
import 'package:uni_express/utils/request.dart';

class RouteDAO {
  Future<RouteDTO> getRoutes(int id) async {
    //request.options.baseUrl = "http://13.212.101.182:8089/api/v1/";
    final res = await request.get(
      'driver/batchs/$id',
    );
    //request.options.baseUrl = "https://beanapi.unibean.net/api/";
    var jsonList = res.data["data"]["routes"] as List;
    if (jsonList != null) {
      List<RouteDTO> routes =
          jsonList.map((e) => RouteDTO.fromJson(e)).toList();
      routes[0].listPackages = (res.data["data"]['packages'] as List)
          .map((e) => PackageDTO.fromJson(e))
          .toList();
      return routes[0];
    }
    return null;
  }
}
