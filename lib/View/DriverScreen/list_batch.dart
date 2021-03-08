import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:uni_express/ViewModel/batch_viewModel.dart';
import 'package:uni_express/acessories/appbar.dart';
import 'package:uni_express/acessories/drawer.dart';
import 'package:uni_express/acessories/loading.dart';
import 'package:uni_express/enums/view_status.dart';
import 'package:intl/intl.dart';
import '../../constraints.dart';
import 'package:get/get.dart';

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
        drawer: DrawerMenu(),
        appBar: DefaultAppBar(
          title: widget.title,
        ),
        body: Column(
          children: [
            Container(
              width: Get.width,
              color: Colors.red,
              padding: const EdgeInsets.all(8),
              child: Text(
                "Các chuyến hàng của bạn",
                style: TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                    fontWeight: FontWeight.bold),
              ),
            ),
            filterStatus(),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(left: 8, right: 8),
                child: RefreshIndicator(
                    key: _refreshIndicatorKey,
                    onRefresh: refreshFetchOrder,
                    child: _buildBatches()),
              ),
            )
          ],
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
            return AspectRatio(
              aspectRatio: 1,
              child: Center(child: LoadingBean()),
            );
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
              DateTime now = DateTime.now();
              List<Widget> list = List();
              model.listBatch.forEach((element) {
                bool end = false;
                if(now.compareTo(element.endTime) > 0){
                  end = true;
                }
                IconData status;
                Color statusColor;
                switch (element.status) {
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
                list.add(Container(
                  margin: EdgeInsets.only(top: 8),
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.all(Radius.circular(8)),
                  ),
                  child: InkWell(
                    onTap: () {
                      model.processBatch(element);
                    },
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Flexible(
                              child: displayedTitle("Khu vực: ", element.area.name,
                                  size: 14,
                                  titleColor: kSecondary,
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
                                .format(element.startTime),
                            titleColor: kSecondary,
                            contentColor: Colors.black54),
                        SizedBox(
                          height: 8,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Flexible(
                              child: displayedTitle(
                                  "Kết thúc: ",
                                  DateFormat("HH:mm dd/MM/yyyy")
                                      .format(element.endTime),
                                  titleColor: kSecondary,
                                  contentColor: Colors.black54),
                            ),
                            end ? Icon(Icons.lock_clock, color: Colors.blueGrey,) : SizedBox.shrink()
                          ],
                        ),
                      ],
                    ),
                  ),
                ));
              });
              return ListView(
                physics: AlwaysScrollableScrollPhysics(),
                controller: model.scrollController,
                children: [
                  ...list,
                  loadMoreIcon()
                ],
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

  Widget displayedTitle(String title, String content,
      {double size, Color titleColor, Color contentColor}) {
    return Text.rich(TextSpan(
        text: title,
        style: TextStyle(
            fontSize: size ?? 14,
            color: titleColor ?? Colors.black,
            fontWeight: FontWeight.bold),
        children: [
          TextSpan(
            text: content,
            style: TextStyle(
              fontSize: size ?? 14,
              color: contentColor ?? Colors.grey,
            ),
          )
        ]));
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
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text(
                        "Trạng thái:",
                        style: TextStyle(fontWeight: FontWeight.bold, color: Colors.orange),
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
                              value: e, child: Text(status,  style: TextStyle(fontSize: 14, color: statusColor)));
                        })
                            .toList(),
                        onChanged: (value) {
                          model.changeFilter(value);
                        },
                      ),
                    ],
                  ),
                ],
              ),
            );
      },
    );
  }
}
