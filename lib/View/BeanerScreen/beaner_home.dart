import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:uni_express/Model/DTO/index.dart';
import 'file:///D:/FPTU/Fall2020/Uni_Delivery/uni_express/lib/View/package_detail.dart';
import 'package:uni_express/ViewModel/batch_viewModel.dart';
import 'package:uni_express/ViewModel/beaner_package_viewModel.dart';
import 'package:uni_express/acessories/loading.dart';
import 'package:uni_express/enums/view_status.dart';
import '../../constraints.dart';
import 'package:get/get.dart';
import 'package:uni_express/acessories/appbar.dart';

import '../../route_constraint.dart';

class BeanerHomeScreen extends StatefulWidget {
  final int batchId;
  BeanerHomeScreen({this.batchId});

  @override
  _BeanerHomeScreenState createState() => _BeanerHomeScreenState();
}

class _BeanerHomeScreenState extends State<BeanerHomeScreen> {
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      new GlobalKey<RefreshIndicatorState>();

  BeanerPackageViewModel model;

  @override
  void initState() {
    super.initState();
    model = BeanerPackageViewModel();
    model.getPackages();
  }

  Future<void> refreshFetchOrder() async {
    await model.getPackages();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ScopedModel(
        model: model,
        child: Scaffold(
          floatingActionButton: scanQRButton(),
          backgroundColor: Colors.white,
          body: RefreshIndicator(
            key: _refreshIndicatorKey,
            onRefresh: refreshFetchOrder,
            child: Container(
              child: ScopedModelDescendant<BeanerPackageViewModel>(
                builder: (context, child, model) {
                  switch (model.status) {
                    case ViewStatus.Loading:
                      return Center(child: LoadingBean());
                    case ViewStatus.Completed:
                      return Column(
                        children: [
                          batchInfo(),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              filterStatus(),
                              Flexible(
                                child: Padding(
                                  padding: const EdgeInsets.only(right: 8.0),
                                  child: InkWell(
                                      onTap: () async {
                                        bool result = await Get.toNamed(
                                          RouteHandler.CUSTOMER_ORDER,
                                        );
                                        if (result != null && result) {
                                          await BatchViewModel.getInstance()
                                              .getIncomingBatch();
                                          await model.getPackages();
                                        }
                                      },
                                      child: Text(
                                        "Xem đơn hàng",
                                        style: kTitleTextStyle.copyWith(
                                            fontSize: 14, color: kPrimary),
                                      )),
                                ),
                              )
                            ],
                          ),
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.only(
                                  left: 8, right: 8, top: 8),
                              decoration: BoxDecoration(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(8)),
                                color: Colors.white,
                              ),
                              child: _buildPackages(model.displayedPackages),
                            ),
                          )
                        ],
                      );
                    default:
                      return ListView(
                        shrinkWrap: true,
                        children: [
                          Text(
                            "Chuyến hàng hiện tại:",
                            style:
                            kTitleTextStyle.copyWith(fontSize: 22, color: kPrimary),
                          ),
                          Image.asset(
                            "assets/images/backgroundForBatchs.jpg",
                            width: Get.width,
                            fit: BoxFit.fill,
                          ),
                          Center(
                            child: Text(
                              "Chưa có chuyến hàng nào, vui lòng quay lại sau",
                              style:
                              kDescriptionTextSyle.copyWith(fontSize: 16),
                            ),
                          )
                        ],
                      );
                  }
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPackages(List<PackageDTO> list) {
    if (list == null || list.isEmpty) {
      return Text(
        "Chưa có túi nào!",
        style: kSubtitleTextStyle.copyWith(color: Colors.grey),
      );
    }
    return ListView.separated(
      itemBuilder: (context, index) => _buildPackageDetail(list[index]),
      itemCount: list.length,
      separatorBuilder: (context, index) => SizedBox(height: 8),
    );
  }

  Widget _buildPackageDetail(PackageDTO dto) {
    String status;
    Color color, backgroundColor;

    switch (dto.status) {
      case PackageStatus.NEW:
        status = "Tài xế chưa lấy";
        color = Colors.orange;
        backgroundColor = Colors.yellow[100];
        break;
      case PackageStatus.PICKEDUP:
        status = "Tài xế đang giao";
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
          color: kBackgroundGrey[2], borderRadius: BorderRadius.circular(8)),
      child: InkWell(
        onTap: () {
          Get.toNamed(RouteHandler.PACAKGE,
              arguments: PackageDetailScreen(
                packageId: dto.packageId,
                batchId: BatchViewModel.getInstance()
                    .incomingBatch
                    .routingBatchId,
              ));
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                displayedTitle("Mã túi: ", "#" + dto.packageId.toString(),
                    titleColor: Colors.black54,
                    contentColor: kSecondary,
                    size: 16),
                SizedBox(
                  height: 4,
                ),
                displayedTitle("Số đơn: ", dto.items.length.toString(),
                    titleColor: Colors.black54,
                    contentColor: kSecondary,
                    size: 16),
                SizedBox(
                  height: 4,
                ),
                displayedTitle("Tài xế: ", dto.driver.toUpperCase(),
                    titleColor: Colors.black54,
                    contentColor: Colors.black54,
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
                      style: TextStyle(color: color, fontSize: 12),
                    )),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    "Chi tiết",
                    style: TextStyle(
                        color: Colors.orange, fontWeight: FontWeight.bold),
                  ),
                )
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget batchInfo() {
    List<PackageDTO> totalPackages;
    if (model.selectedAreaIndex == -1) {
      totalPackages = List();
      model.packagesOfArea.values.forEach((element) {
        totalPackages.addAll(element);
      });
    } else {
      totalPackages = model.packagesOfArea.values
          .elementAt(model.selectedAreaIndex)
          .toList();
    }
    int currentDeli = totalPackages.fold(0, (previousValue, element) {
      if (element.status == PackageStatus.DELIVERIED) {
        return previousValue + 1;
      }
      return previousValue;
    });

    return Container(
      width: Get.width,
      padding: const EdgeInsets.all(0),
      decoration: BoxDecoration(
        color: Color(0xFFF5F4EF),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(4),
            width: Get.width,
            child: Column(
              children: [
                Text(
                  "Chuyến hàng hiện tại #${BatchViewModel.getInstance().incomingBatch.id}",
                  style:
                      kTitleTextStyle.copyWith(fontSize: 22, color: kPrimary),
                ),
                filterArea()
              ],
            ),
            decoration: BoxDecoration(
              color: Color(0xFFF5F4EF),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                text: '${currentDeli}',
                style: TextStyle(
                  color: Colors.orange,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                children: [
                  TextSpan(
                    text: '/${totalPackages.length} ',
                    style: kSubtitleTextStyle.copyWith(fontSize: 16),
                  ),
                  TextSpan(
                    text: 'Túi đã nhận',
                    style: kSubtitleTextStyle.copyWith(
                        fontSize: 16, fontWeight: FontWeight.normal),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget filterArea() {
    return Container(
      width: Get.width,
      padding: EdgeInsets.only(left: 8, right: 8),
      decoration: BoxDecoration(),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Image(
            width: 25,
            height: 25,
            image: AssetImage("assets/icons/location.png"),
          ),
          SizedBox(
            width: 4,
          ),
          Text(
            "Nơi nhận: ",
            style: kDescriptionTextSyle.copyWith(fontSize: 14),
          ),
          SizedBox(
            width: 8,
          ),
          DropdownButton(
            hint: new Text("-------"),
            value: model.selectedAreaIndex,
            items: [
              DropdownMenuItem(
                  value: -1,
                  child: Text("Tất cả",
                      style: TextStyle(fontSize: 13, color: Colors.black))),
              ...model.packagesOfArea.keys.map((e) {
                int index = model.packagesOfArea.keys.toList().indexOf(e);
                List<PackageDTO> packages =
                    model.packagesOfArea.values.elementAt(index);
                return DropdownMenuItem(
                    value: index,
                    child: Text(packages[0].toLocation.name,
                        style: TextStyle(fontSize: 13, color: Colors.black)));
              }).toList()
            ],
            onChanged: (value) {
              model.changeArea(value);
            },
          ),
        ],
      ),
    );
  }

  Widget filterStatus() {
    return Container(
      margin: EdgeInsets.only(top: 8, bottom: 8),
      height: 30,
      padding: EdgeInsets.only(left: 8, right: 8),
      decoration: BoxDecoration(
        color: Colors.white,
      ),
      child: ListView.separated(
        shrinkWrap: true,
        scrollDirection: Axis.horizontal,
        itemBuilder: (context, index) {
          String status;
          switch (model.packageStatus[index]) {
            case PackageStatus.NEW:
              status = "Chưa lấy";
              break;
            case PackageStatus.DELIVERIED:
              status = "Đã nhận";
              break;
            default:
              status = "Tất cả";
          }
          if (model.packageStatus[index] == model.selectedStatus) {
            return Container(
                padding: EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.orange,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                    child: Text(
                  status,
                  style: TextStyle(color: Colors.white, fontSize: 14),
                )));
          }
          return InkWell(
              onTap: () {
                model.changeStatus(model.packageStatus[index]);
              },
              child: Center(
                  child: Text(
                status,
                style: TextStyle(color: Colors.black, fontSize: 12),
              )));
        },
        itemCount: model.packageStatus.length,
        separatorBuilder: (context, index) => SizedBox(
          width: 8,
        ),
      ),
    );
  }

  Widget scanQRButton() {
    return ScopedModelDescendant<BeanerPackageViewModel>(
      builder: (context, child, model) {
        if (model.status == ViewStatus.Completed) {
          return FloatingActionButton(
            backgroundColor: Colors.white,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            onPressed: () async {
              await model.scanQR();
            },
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Icon(
                Icons.qr_code_scanner,
                color: kPrimary,
                size: 32,
              ),
            ),
          );
        }
        return Container();
      },
    );
  }
}
