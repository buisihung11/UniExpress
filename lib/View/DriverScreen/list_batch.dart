import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
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
          body: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: Color(0xFFF5F4EF),
              image: DecorationImage(
                fit: BoxFit.cover,
                colorFilter: ColorFilter.mode(
                    Color(0xfff0feff).withOpacity(0.4), BlendMode.srcOver),
                image: AssetImage("assets/images/ux_big.png"),
                alignment: Alignment.topRight,
              ),
            ),
            child: Column(
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(left: 20, top: 50, right: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        'Chào buổi sáng 👋',
                        style: kSubtitleTextSyule,
                      ),
                      Text('Hung Bui', style: kHeadingextStyle),
                      ClipPath(
                        clipper: BestSellerClipper(),
                        child: Container(
                          color: kBestSellerColor,
                          padding: EdgeInsets.only(
                              left: 10, top: 5, right: 20, bottom: 5),
                          child: Text("Chỉ số tuần này".toUpperCase(),
                              style: kHeadingextStyle.copyWith(fontSize: 16)),
                        ),
                      ),
                      // SizedBox(height: 16),
                      // Text('Chỉ số tuần này',
                      //     style: kHeadingextStyle.copyWith(fontSize: 16)),
                      SizedBox(height: 8),
                      Container(
                        width: Get.width,
                        // color: Color(0xfff0feff),
                        height: 120,
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          children: [
                            DriverStatistic(
                              iconPath: "assets/icons/package.png",
                              contentTxt: '12',
                              labelTxt: 'Túi đã giao',
                            ),
                            DriverStatistic(
                              iconPath: "assets/icons/path.png",
                              contentTxt: '12.000 m',
                              labelTxt: 'Quãng đường',
                            ),
                            Center(
                              child: Container(
                                width: 120,
                                child: Text('Chi tiết 👉',
                                    textAlign: TextAlign.left,
                                    style: kTitleTextStyle),
                              ),
                            ),
                          ],
                        ),
                      ),
                      // SizedBox(height: 20),
                    ],
                  ),
                ),
                SizedBox(height: 30),
                Expanded(
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(50),
                        topRight: Radius.circular(50),
                      ),
                      color: Colors.white,
                    ),
                    child: Stack(
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.fromLTRB(30, 15, 30, 0),
                          child: Column(
                            children: [
                              Text("Hôm nay bạn có 1 chuyến hàng cần giao",
                                  style: kTitleTextStyle),
                              Expanded(
                                child: ListView(
                                  // crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Text("Thông tin chuyến hàng"),
                                    Text("Dự kiến quãng đường"),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ));
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
                          builder:
                              DotSwiperPaginationBuilder(color: Colors.grey),
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
                            child: Image(
                                image: AssetImage(
                                    "assets/images/backgroundForBatchs.png")),
                          ))
                    ],
                  ),
                );
              }
              return Container(
                  height: Get.height * 0.18,
                  child: Center(
                      child: Image(
                          image: AssetImage(
                              "assets/images/backgroundForBatchs.jpg"))));
            }
            return Container(
                height: Get.height * 0.18,
                child: Center(
                    child: Image(
                        image: AssetImage(
                            "assets/images/backgroundForBatchs.jpg"))));
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

class DriverStatistic extends StatelessWidget {
  final String iconPath;
  final String contentTxt;
  final String labelTxt;

  const DriverStatistic({
    Key key,
    this.iconPath,
    this.contentTxt,
    this.labelTxt,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 120,
      height: 100,
      margin: EdgeInsets.only(left: 8, right: 8),
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: Color(0xfffefefe),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: kPrimary.withOpacity(0.7),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Center(
              child: Image(
                width: 25,
                height: 25,
                image: AssetImage(iconPath),
              ),
            ),
          ),
          Text(contentTxt, style: kHeadingextStyle.copyWith(fontSize: 16)),
          Text(
            labelTxt,
            overflow: TextOverflow.ellipsis,
            style: kSubtitleTextSyule.copyWith(
              fontSize: 14,
              color: Color(0xffc5c5c9),
            ),
          ),
        ],
      ),
    );
  }
}

class CourseContent extends StatelessWidget {
  final String number;
  final double duration;
  final String title;
  final bool isDone;
  const CourseContent({
    Key key,
    this.number,
    this.duration,
    this.title,
    this.isDone = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 30),
      child: Row(
        children: <Widget>[
          Text(
            number,
            style: kHeadingextStyle.copyWith(
              color: kTextColor.withOpacity(.15),
              fontSize: 28,
            ),
          ),
          SizedBox(width: 20),
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: "$duration mins\n",
                  style: TextStyle(
                    color: kTextColor.withOpacity(.5),
                    fontSize: 18,
                  ),
                ),
                TextSpan(
                  text: title,
                  style: kSubtitleTextSyule.copyWith(
                    fontWeight: FontWeight.w600,
                    height: 1.5,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
          ),
          Spacer(),
          Container(
            margin: EdgeInsets.only(left: 10),
            height: 40,
            width: 30,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: kGreenColor.withOpacity(isDone ? 1 : .5),
            ),
            child: Icon(Icons.play_arrow, color: Colors.white),
          )
        ],
      ),
    );
  }
}

class BestSellerClipper extends CustomClipper<Path> {
  @override
  getClip(Size size) {
    var path = Path();
    path.lineTo(size.width - 20, 0);
    path.lineTo(size.width, size.height / 2);
    path.lineTo(size.width - 20, size.height);
    path.lineTo(0, size.height);
    path.lineTo(0, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper oldClipper) {
    return false;
  }
}
