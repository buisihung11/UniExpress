import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:uni_express/Model/DTO/index.dart';
import 'package:uni_express/ViewModel/batch_viewModel.dart';
import 'package:uni_express/acessories/appbar.dart';
import 'package:uni_express/acessories/drawer.dart';
import 'package:uni_express/acessories/loading.dart';
import 'package:uni_express/enums/view_status.dart';
import 'package:intl/intl.dart';
import '../../constraints.dart';
import 'package:get/get.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:flutter_svg/flutter_svg.dart';

class BatchScreen extends StatefulWidget {
  final String title;
  BatchScreen({Key key, this.title}) : super(key: key);

  @override
  _BatchScreenState createState() => _BatchScreenState();
}

class _BatchScreenState extends State<BatchScreen> {
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      new GlobalKey<RefreshIndicatorState>();
  BatchViewModel model;

  @override
  void initState() {
    super.initState();
    model = BatchViewModel();
    model.getBatches();
  }

  Future<void> refreshFetchOrder() async {
    await model.getBatches();
  }

  @override
  Widget build(BuildContext context) {
    List<String> messages = [
      "Cuộc đời là những chuyến đi phải không bạn hiền ",
      ""
    ];

    return ScopedModel<BatchViewModel>(
      model: model,
      child: Scaffold(
        backgroundColor: Colors.white,
        drawer: DrawerMenu(),
        appBar: DefaultAppBar(
          title: widget.title,
        ),
        body: Container(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTotalBatches(),
              SizedBox(
                height: 8,
              ),
              Container(
                padding: EdgeInsets.all(8),
                child: Text(
                  "📍 Các chuyến hàng sắp tới",
                  style: TextStyle(
                      fontSize: 16,
                      color: kSecondary,
                      fontWeight: FontWeight.bold),
                ),
              ),
              _buildFutureBatches(),
              Divider(),
              Container(
                child: Text(
                  "📑 Danh sách chuyến hàng",
                  style: TextStyle(
                      fontSize: 16,
                      color: kSecondary,
                      fontWeight: FontWeight.bold),
                ),
              ),
              filterStatus(),
              Expanded(
                flex: 2,
                child: RefreshIndicator(
                    key: _refreshIndicatorKey,
                    onRefresh: refreshFetchOrder,
                    child: _buildBatches()),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTotalBatches() {
    return ScopedModelDescendant<BatchViewModel>(
      builder: (context, child, model) {
        final status = model.status;
        switch (status) {
          case ViewStatus.Loading:
          case ViewStatus.Error:
            return SizedBox.shrink();
          default:
            if (model.listBatch != null && model.listBatch.isNotEmpty) {
              DateTime now = DateTime.now();
              List<BatchDTO> listFuture = model.listBatch.where((element) {
                if (now.day == element.startTime.day &&
                    now.month == element.startTime.month &&
                    now.year == element.startTime.year) {
                  return true;
                }
                return false;
              }).toList();
              if (listFuture != null && listFuture.isNotEmpty) {
                return Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: kPrimary,
                    gradient: LinearGradient(
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                        colors: [
                          Color(0xff0BAB64),
                          Color(0xff3BB78F),
                        ]),
                  ),
                  width: Get.width,
                  child: Text(
                    "Số chuyến hàng hôm nay: ${listFuture.length}",
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16),
                  ),
                );
              }
              return SizedBox.shrink();
            }
            return SizedBox.shrink();
        }
      },
    );
  }

  Widget _buildFutureBatches() {
    return ScopedModelDescendant<BatchViewModel>(
      builder: (context, child, model) {
        final status = model.status;
        switch (status) {
          case ViewStatus.Loading:
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: Center(child: CircularProgressIndicator()),
            );
          case ViewStatus.Error:
            return SizedBox.shrink();
          default:
            if (model.listBatch != null && model.listBatch.isNotEmpty) {
              DateTime now = DateTime.now();
              List<BatchDTO> listFuture = model.listBatch
                  .where((element) => now.compareTo(element.startTime) < 0)
                  .toList();
              if (listFuture != null && listFuture.isNotEmpty) {
                return Expanded(
                  flex: 1,
                  child: Stack(
                    children: [
                      Swiper(
                        loop: true,
                        fade: 0.2,
                        // itemWidth: MediaQuery.of(context).size.width - 60,
                        // itemHeight: 370,
                        scrollDirection: Axis.horizontal,
                        itemBuilder: (BuildContext context, index) =>
                            batchItem(listFuture[index]),
                        itemCount: listFuture.length,
                        pagination: new SwiperPagination(
                          builder: DotSwiperPaginationBuilder(color: Colors.grey),
                        ),

                        // viewportFraction: 0.85,
                      ),
                    Positioned(
                        height: 120,
                        width: 120,
                        bottom: -16,
                        right: -16,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Image(image: AssetImage("assets/images/backgroundForBatchs.png")),
                        ))
                    ],
                  ),
                );
              }
              return Container(
                  height: Get.height * 0.18,
                  child: Center(child: Image(image: AssetImage("assets/images/backgroundForBatchs.jpg"))));
            }
            return Container(
                height: Get.height * 0.18,
                child: Center(child: Image(image: AssetImage("assets/images/backgroundForBatchs.jpg"))));
        }
      },
    );
  }

  Widget batchItem(BatchDTO dto) {
    IconData status;
    Color statusColor;
    switch (dto.status) {
      case BatchStatus.PROCESSING:
        status = Icons.pending;
        statusColor = Colors.blue;
        break;
      case BatchStatus.FAIL:
        status = Icons.cancel;
        statusColor = Colors.red;
        break;
      case BatchStatus.SUCCESS:
        status = Icons.check_circle;
        statusColor = Colors.green;
        break;
      default:
        status = Icons.error;
        statusColor = Colors.yellow;
    }
    return Container(
      margin: EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
      ),
      child: Material(
        elevation: 2,
        child: InkWell(
          onTap: () {
            model.processBatch(dto);
          },
          child: Container(
            padding: EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: displayedTitle("Khu vực: ", dto.area.name,
                          size: 14,
                          titleColor: Colors.black54,
                          contentColor: Colors.orange),
                    ),
                    Icon(
                      status,
                      color: statusColor,
                    )
                  ],
                ),
                SizedBox(
                  height: 8,
                ),
                displayedTitle("Bắt đầu: ",
                    DateFormat("HH:mm dd/MM/yyyy").format(dto.startTime),
                    titleColor: Colors.black54, contentColor: Colors.black),
                SizedBox(
                  height: 8,
                ),
                displayedTitle("Kết thúc: ",
                    DateFormat("HH:mm dd/MM/yyyy").format(dto.endTime),
                    titleColor: Colors.black54, contentColor: Colors.black)
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBatches() {
    return ScopedModelDescendant<BatchViewModel>(
      builder: (context, child, model) {
        final status = model.status;
        switch (status) {
          case ViewStatus.Loading:
            return Center(child: LoadingBean());
          case ViewStatus.Error:
            return ListView(
              children: [
                AspectRatio(
                    aspectRatio: 1,
                    child: Padding(
                      padding: const EdgeInsets.all(32.0),
                      child: Center(
                        child: Image.asset("assets/images/error.png"),
                      ),
                    )),
              ],
            );
          default:
            if (model.listBatch != null && model.listBatch.isNotEmpty) {
              return ListView.builder(
                physics: AlwaysScrollableScrollPhysics(),
                controller: model.scrollController,
                itemBuilder: (context, index) =>
                    batchItem(model.listBatch[index]),
                itemCount: model.listBatch.length,
              );
            }
            return ListView(
              children: [
                Center(
                    child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    'Chưa có chuyến hàng nào!',
                    style: TextStyle(color: Colors.black54),
                  ),
                ))
              ],
            );
        }
      },
    );
  }

  Widget loadMoreIcon() {
    return ScopedModelDescendant<BatchViewModel>(
      builder: (context, child, model) {
        switch (model.status) {
          case ViewStatus.LoadMore:
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: Center(child: CircularProgressIndicator()),
            );
          default:
            return SizedBox(
              height: 8,
            );
        }
      },
    );
  }

  Widget filterStatus() {
    return ScopedModelDescendant<BatchViewModel>(
      builder: (BuildContext context, Widget child, BatchViewModel model) {
        return Container(
          decoration: BoxDecoration(),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Text(
                "Trạng thái:",
                style: TextStyle(color: kPrimary),
              ),
              SizedBox(
                width: 8,
              ),
              DropdownButton(
                hint: new Text("-------"),
                value: model.selectedStatus,
                items: model.batchStatus.map((e) {
                  String status;
                  switch (e) {
                    case BatchStatus.PROCESSING:
                      status = "Đang xử lý";
                      break;
                    case BatchStatus.SUCCESS:
                      status = "Thành công";
                      break;
                    default:
                      status = "Tất cả";
                  }
                  return DropdownMenuItem(
                      value: e,
                      child: Text(status,
                          style: TextStyle(fontSize: 13, color: Colors.black)));
                }).toList(),
                onChanged: (value) {
                  model.changeFilter(value);
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
