import 'package:uni_express/Model/DTO/index.dart';
import 'package:uni_express/utils/request.dart';

class PackageDAO{
  Future<PackageDTO> getPackage(int batchId, int packageId) async {
    final res = await request.get(
      'batchs/${batchId}/packages/${packageId}',
    );
    return PackageDTO.fromJson(res.data["data"]);
  }

  Future<void> updatePackagesForDriver(List<int> packages) async {
    List<Map<String, dynamic>> list = List();
    packages.forEach((element) {
      list.add({"package_id" : element});
    });
    final res = await request.put(
      'driver/packages', data: list.toString()
    );
  }

  Future<void> updatePackagesForBeaner(List<int> packages) async {
    List<Map<String, dynamic>> list = List();
    packages.forEach((element) {
      list.add({"package_id" : element});
    });
    final res = await request.put(
        'beaner/packages', data: list.toString()
    );
  }


}