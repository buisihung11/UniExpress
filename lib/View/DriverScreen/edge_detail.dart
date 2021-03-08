import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:uni_express/Model/DTO/BatchDTO.dart';
import 'package:uni_express/Model/DTO/index.dart';
import 'package:uni_express/acessories/appbar.dart';
import 'package:uni_express/acessories/dialog.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../constraints.dart';
import 'package:get/get.dart';

class EdgeScreen extends StatefulWidget {
  final AreaDTO area;
  final List<ActionDTO> pakages;
  EdgeScreen({Key key, this.area, this.pakages}) : super(key: key);

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
      appBar: DefaultAppBar(
        title: widget.area.name,
      ),
      body: Column(
        children: [
          areaInfo(),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(left: 8, right: 8),
              child: _buildPakages(),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildPakages() {
    List<ActionDTO> listPick = widget.pakages.where((element) => element.actionType == ActionType.PICKUP).toList();
    List<ActionDTO> listDeli = widget.pakages.where((element) => element.actionType == ActionType.DELIVERY).toList();
    List<Widget> list = List();
    if(listPick.isNotEmpty && listPick != null){
      list.add(SizedBox(height: 8,));
      list.add(Text(
        "Danh sách túi phải lấy:",
        style: TextStyle(
            fontSize: 16,
            color: Colors.orange,
          fontWeight: FontWeight.bold
        ),));
      listPick.forEach((element) {
        list.add(_buildPackageDetail(element, "Đã lấy"));
      });
    }

    if(listDeli.isNotEmpty && listDeli != null){
      list.add(SizedBox(height: 8,));
      list.add(Text(
        "Danh sách túi phải giao:",
        style: TextStyle(
          fontSize: 16,
          color: Colors.orange,
          fontWeight: FontWeight.bold
        ),));
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
    return Container(
      margin: EdgeInsets.all(8),
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.all(Radius.circular(8))
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "${actionDTO.packageId}",
              style: TextStyle(
                fontSize: 15,
                color: kSecondary,
                fontWeight: FontWeight.bold
              ),
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
                FlatButton(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                  color: Colors.grey[400],
                  child: Text(
                    "Hủy",
                    style: TextStyle(color: Colors.white),
                  ),
                  onPressed: () async {
                    await showOptionDialog("Xác nhân hủy túi ❌");
                  },
                ),
              ],
            )
          ],
          ),
    );
 }

  Widget areaInfo() {
    return Container(
      color: Colors.yellow[100],
      width: Get.width,
      padding: const EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Thông tin điểm đến",
            style: TextStyle(color: Colors.deepOrange, fontSize: 17),
          ),
          SizedBox(height: 32,),
          SizedBox(
            height: 8,
          ),
          RichText(
            text: TextSpan(
              text: 'Tên cửa hàng: ',
              style: TextStyle(color: Colors.grey, fontSize: 14),
              children: <TextSpan>[
                TextSpan(
                    text: '${widget.area.name}',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    )),
              ],
            ),
          ),
          SizedBox(
            height: 8,
          ),
          Row(
            children: [
              Text(
                "Liên hệ: ",
                style: TextStyle(color: Colors.grey, fontSize: 14),
              ),
              FlatButton(
                onPressed: () async {
                  final url = 'tel:+84123456789';
                  if (await canLaunch(url)) {
                    await launch(url);
                  } else {
                    throw 'Could not launch $url';
                  }
                },
                child: new Text("+84123456789",
                    style: TextStyle(
                      color: Colors.blue,
                      fontWeight: FontWeight.bold,
                    )),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
