import 'package:uni_express/Model/DTO/BatchDTO.dart';
class RouteDTO{
  List<EdgeDTO> listEdges;
  List<AreaDTO> listPaths;

  RouteDTO({this.listEdges, this.listPaths});

  factory RouteDTO.fromJson(dynamic json) {
    return RouteDTO(
      listEdges: (json["edges"] as List).map((e) => EdgeDTO.fromJson(e)).toList(),
        listPaths: (json["path"] as List).map((e) => AreaDTO.fromJson(e)).toList(),
    );
  }
}


class EdgeDTO {
  int fromId;
  int toId;
  List<ActionDTO> packages;

  EdgeDTO({this.fromId, this.toId, this.packages});

  factory EdgeDTO.fromJson(dynamic json) {
    return EdgeDTO(
      fromId: json["from_s_id"],
      toId: json["to_s_id"],
        packages: (json["package_actions"] as List).map((e) => ActionDTO.fromJson(e)).toList()
    );
  }
}

class ActionDTO {
  int packageId;
  int actionType;

  ActionDTO({this.packageId, this.actionType});

  factory ActionDTO.fromJson(dynamic json) {
    return ActionDTO(packageId: json['p_id'], actionType: json['action_type']);
  }
}
