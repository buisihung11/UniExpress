import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:uni_express/Model/DTO/index.dart';
import 'package:uni_express/ViewModel/batch_viewModel.dart';
import 'package:uni_express/acessories/appbar.dart';
import 'package:uni_express/acessories/loading.dart';
import 'package:uni_express/acessories/separator.dart';
import 'package:uni_express/enums/view_status.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../constraints.dart';
import '../route_constraint.dart';
import 'DriverScreen/edge_detail.dart';

class BatchHistoryScreen extends StatefulWidget {
  final String title;
  BatchHistoryScreen({Key key, this.title}) : super(key: key);

  @override
  _BatchHistoryScreenState createState() => _BatchHistoryScreenState();
}

class _BatchHistoryScreenState extends State<BatchHistoryScreen> {
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
        // drawer: DrawerMenu(),
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
              filterTime(),
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
                    "Tổng số chuyến hàng: ${model.listBatch.length}",
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
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Color(0xffe8f2fb),
            spreadRadius: 2,
            blurRadius: 7,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("#${dto.id}",
                  style: kTitleTextStyle.copyWith(
                    color: Color(0xff7986a1),
                  )),
              Icon(
                status,
                color: statusColor,
              ),
            ],
          ),
          SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SizedBox(
                width: 65,
                child: Text(
                  dto.route.listPaths.first.name,
                  textAlign: TextAlign.left,
                  maxLines: 2,
                  overflow: TextOverflow.visible,
                  style: kTitleTextStyle.copyWith(fontSize: 14),
                ),
              ),
              SizedBox(width: 5),
              Expanded(
                child: MySeparator(color: Colors.blueAccent),
              ),
              Padding(
                padding: const EdgeInsets.only(
                  left: 8.0,
                  right: 8.0,
                ),
                child: Image(
                  width: 25,
                  height: 25,
                  image: AssetImage("assets/icons/shipper_motorbike.png"),
                ),
              ),
              Expanded(
                child: MySeparator(color: Colors.blueAccent),
              ),
              SizedBox(width: 5),
              SizedBox(
                width: 65,
                child: Text(
                  dto.route.listPaths.last.name,
                  textAlign: TextAlign.left,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: kTitleTextStyle.copyWith(fontSize: 14),
                ),
              ),
            ],
          ),
          SizedBox(height: 8,),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Thời gian: ${DateFormat("dd/MM/yyyy").format(dto.startTime)}',
                    style: kDescriptionTextSyle,
                  ),
                  Text(
                    'Từ ${DateFormat("HH:mm").format(dto.startTime)} đến ${DateFormat("HH:mm").format(dto.endTime)}',
                    style: kTitleTextStyle.copyWith(fontSize: 12),
                  )
                ],
              ),
              SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Quãng đường: ',
                    style: kDescriptionTextSyle,
                  ),
                  Text(
                    '~ ${dto.totalDistance} m',
                    style: kTitleTextStyle.copyWith(fontSize: 12),
                  )
                ],
              ),
            ],
          ),
          Container(
            width: Get.width,
            margin: EdgeInsets.only(top: 16, bottom: 0),
            padding: EdgeInsets.all(4),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4),
              color: kPrimary,
              boxShadow: [
                BoxShadow(
                  color: Color(0xffe8f2fb),
                  spreadRadius: 2,
                  blurRadius: 7,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  Get.bottomSheet(
                      _BatchDetail(
                        batch: dto,
                      ),
                      isScrollControlled: true);
                },
                child: Text(
                  'Chi tiết',
                  textAlign: TextAlign.center,
                  style: kTitleTextStyle.copyWith(
                    fontSize: 20,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
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
              return ListView.separated(
                physics: AlwaysScrollableScrollPhysics(),
                controller: model.scrollController,
                itemBuilder: (context, index) =>
                    batchItem(model.listBatch[index]),
                itemCount: model.listBatch.length,
                separatorBuilder: (context, index) => SizedBox(height: 8,),
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

  Widget filterTime() {
    return ScopedModelDescendant<BatchViewModel>(
      builder: (BuildContext context, Widget child, BatchViewModel model) {
        return Container(
          decoration: BoxDecoration(),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Text(
                "Thời gian:",
                style: TextStyle(color: kPrimary),
              ),
              SizedBox(
                width: 8,
              ),
              Expanded(
                child: Material(
                  color: Colors.grey[200],
                  child: InkWell(
                    onTap: () async {
                      await model.changeFilterTime();
                    },
                    child: Center(
                      child: Text((model.timeRange != null)
                          ? "${DateFormat("dd/MM/yyyy").format(model.timeRange.start)} - ${DateFormat("dd/MM/yyyy").format(model.timeRange.end)}"
                          : ""),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _BatchDetail extends StatefulWidget {
  BatchDTO batch;

  _BatchDetail({this.batch});

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _BatchDetailState();
  }
}

class _BatchDetailState extends State<_BatchDetail> {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Container(
      height: Get.height * 0.8,
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
              topRight: Radius.circular(32), topLeft: Radius.circular(32))),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Center(
                child: Text(
              "Chuyến hàng #${widget.batch.id}",
              style: TextStyle(
                  color: Colors.grey,
                  fontSize: 16,
                  fontWeight: FontWeight.bold),
            )),
          ),
          Divider(),
          Expanded(
            child: ListView.builder(
              itemBuilder: (context, index) {
                AreaDTO area = widget.batch.route.listPaths[index];
                EdgeDTO edge = widget.batch.route.listEdges.firstWhere(
                  (element) => element.toId == area.id,
                  orElse: () => null,
                );
                return Container(
                  decoration: BoxDecoration(
                      color: area.isSelected ? kPrimary : Colors.white,
                      border: Border(
                          bottom: BorderSide(color: kBackgroundGrey[3]))),
                  child: ListTile(
                    contentPadding: EdgeInsets.fromLTRB(16, 8, 16, 8),
                    title: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "${area.name.toUpperCase()}",
                          style: TextStyle(
                              fontSize: 14,
                              color: area.isSelected ? Colors.white : kPrimary,
                              fontWeight: FontWeight.bold),
                        ),
                        SizedBox(
                          height: 8,
                        ),
                        edge != null
                            ? Row(
                                children: [
                                  Image(
                                    width: 50,
                                    height: 50,
                                    image:
                                        AssetImage("assets/icons/package.png"),
                                  ),
                                  SizedBox(
                                    width: 8,
                                  ),
                                  Text("${edge.actions.length}",
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: area.isSelected
                                            ? Colors.white
                                            : Colors.black,
                                      )),
                                ],
                              )
                            : SizedBox.shrink()
                      ],
                    ),
                    trailing: Material(
                      color: Colors.transparent,
                      child: index != 0
                          ? InkWell(
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  "${index == widget.batch.route.listPaths.length - 1 ? '🎌' : ""} Chi tiết",
                                  style: TextStyle(
                                      color: area.isSelected
                                          ? Colors.white
                                          : Colors.orange,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                              onTap: () {
                                Get.toNamed(RouteHandler.EDGE,
                                    arguments: EdgeScreen(
                                      area: area,
                                      packages: widget.batch.route.listPackages,
                                      actions: edge.actions,
                                      batchId: widget.batch.id,
                                    ));
                              },
                            )
                          : Text(
                              "🚩 Bắt đầu",
                              style: TextStyle(
                                  color: area.isSelected
                                      ? Colors.white
                                      : Colors.orange,
                                  fontWeight: FontWeight.bold),
                            ),
                    ),
                  ),
                );
              },
              itemCount: widget.batch.route.listPaths.length,
            ),
          ),
        ],
      ),
    );
  }
}
