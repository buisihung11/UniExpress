import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:uni_express/Model/DTO/BatchDTO.dart';
import 'package:uni_express/Model/DTO/index.dart';
import 'package:uni_express/ViewModel/package_viewModel.dart';
import 'package:uni_express/acessories/appbar.dart';
import 'package:uni_express/acessories/dialog.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../constraints.dart';
import 'package:get/get.dart';

import '../../route_constraint.dart';
import '../index.dart';

class EdgeScreen extends StatefulWidget {
  final BatchDTO batch;
  final AreaDTO area;
  final EdgeDTO edge;

  EdgeScreen({Key key, this.area, this.edge, this.batch}) : super(key: key);

  @override
  _EdgeScreenState createState() => _EdgeScreenState();
}

class _EdgeScreenState extends State<EdgeScreen> with TickerProviderStateMixin{
  PackageViewModel model;
  TabController tabController;

  @override
  void initState() {
    super.initState();
    model = PackageViewModel(edge: widget.edge);
    tabController = TabController(vsync: this, length: model.actions.keys.length);
  }

  @override
  Widget build(BuildContext context) {
    return ScopedModel(
      model: model,
      child: Scaffold(
        appBar: DefaultAppBar(
          title: "${widget.area.id} - Chuyến hàng #${widget.batch.id}",
        ),
        bottomNavigationBar: bottomBar(),
        body: Column(
          children: [
            areaInfo(),
            Expanded(
              child: Container(
                padding: const EdgeInsets.only(left: 8, right: 8, top: 8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(8)),
                  color: Colors.white,
                ),
                child: _buildPackageTypeTab(),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildPackageTypeTab() {
    return ScopedModelDescendant<PackageViewModel>(
      builder: (context, child, model) {
        return ListView(
          shrinkWrap: true,
          children: [
            TabBar(
              labelStyle: TextStyle(fontSize: 20),
              labelColor: kPrimary,
              controller: tabController,
              tabs: model.actions.values
                  .map((e) => Tab(
                        text: e,
                      ))
                  .toList(),
              onTap: (value) {
                if(tabController.indexIsChanging){
                  model.changeDisplayPackages(value);
                }

              },
            ),
            ...model.displayPackages.map((e) {
              String status;
              Color color, backgroundColor;
              switch (e.status) {
                case PackageStatus.NEW:
                  status = "Chưa lấy";
                  color = Colors.orange;
                  backgroundColor = Colors.yellow[100];
                  break;
                case PackageStatus.PICKEDUP:
                  status = "Đang giao";
                  color = Colors.blue;
                  backgroundColor = Colors.blue[100];
                  break;
                case PackageStatus.DELIVERIED:
                  status = "Đã nhận";
                  color = Colors.green;
                  backgroundColor = Colors.green[100];
                  break;
                default:
                  status = "";
              }
              return Container(
                margin: EdgeInsets.only(top: 8),
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                    color: kBackgroundGrey[2],
                    borderRadius: BorderRadius.circular(8)),
                child: model.enableUpdate(e)
                    ? CheckboxListTile(
                  contentPadding: EdgeInsets.all(0),
                  controlAffinity: ListTileControlAffinity.leading,
                  value: e.isSelected,
                  onChanged: (value) {
                    model.selectPackage(value, e);
                  },
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          displayedTitle(
                              "Mã túi: ", "#" + e.packageId.toString(),
                              titleColor: Colors.black54,
                              contentColor: kSecondary,
                              size: 16),
                          SizedBox(
                            height: 4,
                          ),
                          displayedTitle(
                              "Số đơn: ", e.items.length.toString(),
                              titleColor: Colors.black54,
                              contentColor: kSecondary,
                              size: 16)
                        ],
                      ),
                      Column(
                        children: [
                          Container(
                              padding: EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                  color: backgroundColor,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: color)),
                              child: Text(
                                status,
                                style:
                                TextStyle(color: color, fontSize: 12),
                              )),
                          InkWell(
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                "Chi tiết",
                                style: TextStyle(
                                    color: Colors.orange,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                            onTap: () {
                              Get.toNamed(RouteHandler.PACAKGE,
                                  arguments: PackageDetailScreen(
                                    packageId: e.packageId,
                                    batchId: widget.batch.routingBatchId,
                                  ));
                            },
                          )
                        ],
                      )
                    ],
                  ),
                )
                    : Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        displayedTitle(
                            "Mã túi: ", "#" + e.packageId.toString(),
                            titleColor: Colors.black54,
                            contentColor: kSecondary,
                            size: 16),
                        SizedBox(
                          height: 4,
                        ),
                        displayedTitle(
                            "Số đơn: ", e.items.length.toString(),
                            titleColor: Colors.black54,
                            contentColor: kSecondary,
                            size: 16)
                      ],
                    ),
                    Column(
                      children: [
                        Container(
                            padding: EdgeInsets.all(4),
                            decoration: BoxDecoration(
                                color: backgroundColor,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: color)),
                            child: Text(
                              status,
                              style:
                              TextStyle(color: color, fontSize: 12),
                            )),
                        InkWell(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              "Chi tiết",
                              style: TextStyle(
                                  color: Colors.orange,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                          onTap: () {
                            Get.toNamed(RouteHandler.PACAKGE,
                                arguments: PackageDetailScreen(
                                  packageId: e.packageId,
                                  batchId: widget.batch.routingBatchId,
                                ));
                          },
                        )
                      ],
                    )
                  ],
                ),
              );
            }).toList()
          ],
        );
      },
    );
  }

  Widget areaInfo() {
    return Container(
      width: Get.width,
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
      margin: EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
              bottomRight: Radius.circular(8), bottomLeft: Radius.circular(8))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Text(
              "Thông tin điểm đến 🏪",
              style: TextStyle(
                  color: Colors.orange,
                  fontSize: 18,
                  fontWeight: FontWeight.bold),
            ),
          ),
          Divider(),
          RichText(
            text: TextSpan(
              text: 'Tên cửa hàng: ',
              style: TextStyle(color: Colors.black54, fontSize: 16),
              children: <TextSpan>[
                TextSpan(
                    text: '${widget.area.name.toUpperCase()}',
                    style: TextStyle(
                      color: Colors.black54,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    )),
              ],
            ),
          ),
          SizedBox(
            height: 8,
          ),
          // RichText(
          //   text: TextSpan(
          //     text: 'Địa chỉ: ',
          //     style: TextStyle(color: Colors.black54, fontSize: 16),
          //     children: <TextSpan>[
          //       TextSpan(
          //           text: '123/35, Lê Văn Việt, q9, HCM',
          //           style: TextStyle(
          //             color: Colors.black54,
          //             fontSize: 16,
          //             //fontWeight: FontWeight.bold,
          //           )),
          //     ],
          //   ),
          // ),
          // SizedBox(
          //   height: 8,
          // ),
          // RichText(
          //   text: TextSpan(
          //     text: 'Liên hệ: ',
          //     style: TextStyle(color: Colors.black54, fontSize: 16),
          //     children: [
          //       WidgetSpan(
          //         child: InkWell(
          //           onTap: () async {
          //             final url = 'tel:+84123456789';
          //             if (await canLaunch(url)) {
          //               await launch(url);
          //             } else {
          //               throw 'Could not launch $url';
          //             }
          //           },
          //           child: new Text("+84123456789",
          //               style: TextStyle(
          //                   decoration: TextDecoration.underline,
          //                   color: Colors.blue,
          //                   fontSize: 16)),
          //         ),
          //       )
          //     ],
          //   ),
          // ),
          // SizedBox(
          //   height: 8,
          // ),
        ],
      ),
    );
  }

  Widget bottomBar() {
    return ScopedModelDescendant<PackageViewModel>(
      builder: (context, child, model) {
        if (model.displayPackages.any((element) => element.isSelected)) {
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
                    int result =
                    await showOptionDialog("Xác nhận hoàn tất túi?");
                    if(result != 1){
                      return;
                    }
                    if (model.displayPackages.every(
                        (element) => element.actionType == ActionType.PICKUP)) {
                      List<int> packages = List();
                      model.displayPackages.forEach((element) {
                        if (element.isSelected) {
                          packages.add(element.packageId);
                        }
                      });
                      model.updatedPackagesForDriver(packages);
                    } else if (model.displayPackages.every((element) =>
                        element.actionType == ActionType.DELIVERY)) {
                      List<int> packages = List();
                      model.displayPackages.forEach((element) {
                        if (element.isSelected) {
                          packages.add(element.packageId);
                        }
                      });
                      model.generateQr(packages);
                    }
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
                      Text("Hoàn tất túi",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16)),
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
        return SizedBox.shrink();
      },
    );
  }
}
