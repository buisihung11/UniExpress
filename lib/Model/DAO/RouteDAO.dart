import 'package:uni_express/Model/DTO/RouteDTO.dart';
import 'package:uni_express/utils/request.dart';

class RouteDAO{
  Future<RouteDTO> getRoutes(int id) async {
    final res = await request.get('driver/batchs/$id',);
    var jsonList = res.data["routes"] as List;
    if(jsonList != null){
      List<RouteDTO> routes = jsonList.map((e) => RouteDTO.fromJson(e)).toList();
      return routes[0];
    }
    return null;
  }
}