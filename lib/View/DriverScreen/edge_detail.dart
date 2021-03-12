import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:uni_express/Model/DTO/BatchDTO.dart';
import 'package:uni_express/Model/DTO/index.dart';
import 'package:uni_express/View/DriverScreen/package_detail.dart';
import 'package:uni_express/acessories/appbar.dart';
import 'package:uni_express/acessories/dialog.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../constraints.dart';
import 'package:get/get.dart';

import '../../route_constraint.dart';

class EdgeScreen extends StatefulWidget {
  final int batchId;
  final AreaDTO area;
  final List<ActionDTO> actions;
  final List<PackageDTO> packages;

  EdgeScreen({Key key, this.area, this.actions, this.packages, this.batchId}) : super(key: key);

  @override
  _EdgeScreenState createState() => _EdgeScreenState();
}

class _EdgeScreenState extends State<EdgeScreen> {

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    List<String> messages = [
      "Cuộc đời là những chuyến đi phải không bạn hiền ",
      ""
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: DefaultAppBar(
        title: "${widget.area.id} - Chuyến hàng ${widget.batchId}",
      ),
      bottomNavigationBar: bottomBar(),
      body: Column(
        children: [
          areaInfo(),
          Divider(color: Colors.grey,),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(left: 8, right: 8, top: 8),
              child: _buildPackages(),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildPackages() {
    List<ActionDTO> listPick = widget.actions.where((element) => element.actionType == ActionType.PICKUP).toList();
    List<ActionDTO> listDeli = widget.actions.where((element) => element.actionType == ActionType.DELIVERY).toList();
    List<Widget> list = List();
    if(listPick.isNotEmpty && listPick != null){
      list.add(SizedBox(height: 8,));
      list.add(displayedTitle("Danh sách túi phải ", "LẤY", titleColor: Colors.black, contentColor: Colors.red));
      listPick.forEach((element) {
        list.add(_buildPackageDetail(element, "Đã lấy"));
      });
    }

    if(listDeli.isNotEmpty && listDeli != null){
      list.add(SizedBox(height: 8,));
      list.add(displayedTitle("Danh sách túi phải ", "GIAO", titleColor:  Colors.black, contentColor: Colors.red));
      listDeli.forEach((element) {
        list.add(_buildPackageDetail(element, "Đã giao"));
      });
    }
    return ListView(
      children: [
        ...list
      ],
    );
  }

 Widget _buildPackageDetail(ActionDTO actionDTO, String type){
    PackageDTO package = widget.packages.where((element) => element.packageId == actionDTO.packageId).first;
    return Container(
      margin: EdgeInsets.only(top: 8),
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: kBackgroundGrey[3],
      ),
      child: InkWell(
        onTap: () async {
          await Get.toNamed(
              RouteHandler.PACAKGE,
              arguments: PackageDetailScreen(package: package, batchId: widget.batchId,)
          );
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  displayedTitle("Mã túi: ", package.packageId.toString(), titleColor: Colors.black54, contentColor: kSecondary),
                  SizedBox(height: 8,),
                  displayedTitle("Số đơn: ", package.items.length.toString(), titleColor: Colors.black54, contentColor: kSecondary)
                ],
              ),
              Column(
                children: [
                  FlatButton(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                    color: kPrimary,
                    child: Text(
                      type,
                      style: TextStyle(color: Colors.white),
                    ),
                    onPressed: () async {
                      await showOptionDialog("Xác nhận ${type.toLowerCase()} túi ✔");
                    },
                  ),
                  // FlatButton(
                  //   shape: RoundedRectangleBorder(
                  //       borderRadius: BorderRadius.circular(8)),
                  //   color: Colors.grey[400],
                  //   child: Text(
                  //     "Hủy",
                  //     style: TextStyle(color: Colors.white),
                  //   ),
                  //   onPressed: () async {
                  //     await showOptionDialog("Xác nhân hủy túi ❌");
                  //   },
                  // ),
                ],
              )
            ],
            ),
      ),
    );
 }

  Widget areaInfo() {
    return Container(
      color: Colors.white,
      width: Get.width,
      padding: const EdgeInsets.fromLTRB(8, 16, 8, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "🔎 Thông tin điểm đến",
            style: TextStyle(color: kSecondary, fontSize: 16, fontWeight: FontWeight.bold),
          ),
          SizedBox(
            height: 12,
          ),
          RichText(
            text: TextSpan(
              text: 'Tên cửa hàng: ',
              style: TextStyle(color: Colors.black54, fontSize: 14),
              children: <TextSpan>[
                TextSpan(
                    text: '${widget.area.name}',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    )),
              ],
            ),
          ),
          SizedBox(height: 8,),
          RichText(
            text: TextSpan(
              text: 'Địa chỉ: ',
              style: TextStyle(color: Colors.black54, fontSize: 14),
              children: <TextSpan>[
                TextSpan(
                    text: '123/35, Lê Văn Việt, q9, HCM',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    )),
              ],
            ),
          ),
          SizedBox(height: 8,),
          RichText(
            text: TextSpan(
              text: 'Liên hệ: ',
              style: TextStyle(color: Colors.black54, fontSize: 14),
              children:[
                WidgetSpan(
                  child: InkWell(
                    onTap: () async {
                      final url = 'tel:+84123456789';
                      if (await canLaunch(url)) {
                        await launch(url);
                      } else {
                        throw 'Could not launch $url';
                      }
                    },
                    child: new Text("+84123456789",
                        style: TextStyle(
                          decoration: TextDecoration.underline,
                          color: Colors.blue,
                        )),
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget bottomBar() {
    return Container(
      padding: const EdgeInsets.only(left: 8, right: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey,
            offset: Offset(0.0, 1.0), //(x,y)
            blurRadius: 6.0,
          ),
        ],
      ),
      child: ListView(
        shrinkWrap: true,
        children: [
          SizedBox(
            height: 16,
          ),
          FlatButton(
            onPressed: () async {
              await showOptionDialog("Xác nhận hoàn tất mọi túi?");
            },
            padding: EdgeInsets.only(left: 8.0, right: 8.0),
            textColor: Colors.white,
            color: kPrimary,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(8))),
            child: Column(
              children: [
                SizedBox(
                  height: 16,
                ),
                Text(
                    "Đã hoàn tất mọi túi",
                    style: TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 15)),
                SizedBox(
                  height: 16,
                )
              ],
            ),
          ),
          SizedBox(
            height: 8,
          )
        ],
      ),
    );
  }
}
