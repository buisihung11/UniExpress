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
              Expanded(
                flex: 1,
                child: _buildFutureBatches(),
              ),
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

  Widget _buildFutureBatches() {
    return ScopedModelDescendant<BatchViewModel>(
      builder: (context, child, model) {
        final status = model.status;
        switch (status) {
          case ViewStatus.Loading:
            return Center(child: CircularProgressIndicator());
          case ViewStatus.Error:
            return Center(child: Image(image: AssetImage("assets/images/backgroundForBatchs.jpg")));
          default:
            if (model.listBatch != null && model.listBatch.isNotEmpty) {
              DateTime now = DateTime.now();
              List<BatchDTO> listFuture = model.listBatch.where((element) => now.compareTo(element.endTime) < 0).toList();
              if(listFuture != null && listFuture.isNotEmpty){

                return Container(
                  decoration: BoxDecoration(
                    image: DecorationImage(image: AssetImage("assets/images/backgroundForBatchs.jpg"))
                  ),
                  child: Swiper(
                    loop: true,
                    fade: 0.2,
                    // itemWidth: MediaQuery.of(context).size.width - 60,
                    // itemHeight: 370,
                    scrollDirection: Axis.horizontal,
                    itemBuilder: (BuildContext context, index) => batchItem(listFuture[index]),
                    itemCount: listFuture.length,
                    pagination: new SwiperPagination(builder: DotSwiperPaginationBuilder(color: Colors.grey), ),

                    // viewportFraction: 0.85,

                  ),
                );
              }
              return Center(child: Image(image: AssetImage("assets/images/backgroundForBatchs.jpg"), fit: BoxFit.cover,));
            }
            return Center(child: Image(image: AssetImage("assets/images/backgroundForBatchs.jpg")));
        }
      },
    );
  }

  Widget batchItem(BatchDTO dto){
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
        borderRadius: BorderRadius.all(Radius.circular(8)),
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
                    Icon(status, color: statusColor,)
                  ],
                ),
                SizedBox(
                  height: 8,
                ),
                displayedTitle(
                    "Bắt đầu: ",
                    DateFormat("HH:mm dd/MM/yyyy")
                        .format(dto.startTime),
                    titleColor: Colors.black54,
                    contentColor: Colors.black),
                SizedBox(
                  height: 8,
                ),
                displayedTitle(
                    "Kết thúc: ",
                    DateFormat("HH:mm dd/MM/yyyy")
                        .format(dto.endTime),
                    titleColor: Colors.black54,
                    contentColor: Colors.black)
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
                itemBuilder: (context, index) => batchItem(model.listBatch[index]),
                itemCount: model.listBatch.length,
              );
            }
            return ListView(
              children: [Center(child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text('Chưa có chuyến hàng nào!', style: TextStyle(color: Colors.black54),),
              ))],
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
            return SizedBox(height: 8,);
        }
      },
    );
  }

  Widget filterStatus() {
    return ScopedModelDescendant<BatchViewModel>(
      builder:
          (BuildContext context, Widget child, BatchViewModel model) {
            return Container(
              margin: EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(

              ),

              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  Text(
                    "Trạng thái:",
                    style: TextStyle(color: Colors.black54),
                  ),
                  SizedBox(
                    width: 8,
                  ),
                  DropdownButton(
                    hint: new Text("-------"),
                    value: model.selectedStatus,
                    items: model.batchStatus
                        .map((e) {
                      String status;
                      Color statusColor;
                      switch(e){
                        case BatchStatus.PROCESSING:
                          status = "Đang xử lý";
                          statusColor = Colors.blue;
                          break;
                        case BatchStatus.FAIL:
                          status = "Đã hủy";
                          statusColor = Colors.red;
                          break;
                        case BatchStatus.SUCCESS:
                          status = "Thành công";
                          statusColor = Colors.green;
                          break;
                        default:
                          status = "Tất cả";
                          statusColor = Colors.black;
                      }
                      return DropdownMenuItem(
                          value: e, child: Text(status,  style: TextStyle(fontSize: 13, color: statusColor)));
                    })
                        .toList(),
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
