import 'package:uni_express/Model/DTO/index.dart';

class RouteDTO {
  List<EdgeDTO> listEdges;
  List<AreaDTO> listPaths;

  RouteDTO({this.listEdges, this.listPaths,});

  factory RouteDTO.fromJson(dynamic json, List<PackageDTO> packages) {
    return RouteDTO(
      listEdges: (json["edges"] as List)
          .map((e) => EdgeDTO.fromJson(e, packages))
          .toList(),
      listPaths:
          (json["path"] as List).map((e) => AreaDTO.fromJson(e)).toList(),
    );
  }
}

class EdgeDTO {
  int fromId;
  int toId;
  List<PackageDTO> packages;

  EdgeDTO({this.fromId, this.toId, this.packages});

  factory EdgeDTO.fromJson(dynamic json, List<PackageDTO> packages) {
    List<PackageDTO> edgePackages = List();
    (json["package_actions"] as List).forEach((action) {
      List<PackageDTO> tmp = packages.map((e) => PackageDTO.clone(e)).toList();
      PackageDTO dto = tmp
          .where((element) => element.packageId == action['p_id'])
          .first;
      dto.actionType = action['action_type'];
      edgePackages.add(dto);
    });

    return EdgeDTO(
        fromId: json["from_s_id"],
        toId: json["to_s_id"],
        packages: edgePackages);
  }
}
