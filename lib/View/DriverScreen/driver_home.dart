import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:shimmer/shimmer.dart';
import 'package:uni_express/Model/DTO/BatchDTO.dart';
import 'package:uni_express/ViewModel/account_viewModel.dart';
import 'package:uni_express/ViewModel/batch_viewModel.dart';
import 'package:intl/intl.dart';
import 'package:uni_express/acessories/separator.dart';
import 'package:uni_express/acessories/shimmer_block.dart';
import 'package:uni_express/enums/view_status.dart';
import 'package:uni_express/route_constraint.dart';

import '../../constraints.dart';
import 'package:get/get.dart';

class BatchScreen extends StatefulWidget {
  final int batchId;
  BatchScreen({Key key, this.batchId}) : super(key: key);

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
    model = BatchViewModel.getInstance();
    model.getIncomingBatch(id: widget.batchId);
  }

  Future<void> refreshFetchOrder() async {
    await model.getIncomingBatch(id: widget.batchId);
  }

  @override
  Widget build(BuildContext context) {
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
                  child: ScopedModel<AccountViewModel>(
                    model: AccountViewModel.getInstance(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        _buildUserWelcome(),

                        SizedBox(height: 8),
                        _buildDriverStatistics(),
                        // SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 16),
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
                          child: RefreshIndicator(
                              key: _refreshIndicatorKey,
                              onRefresh: refreshFetchOrder,
                              child: IncomingBatchCard()),
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

  Widget _buildUserWelcome() {
    return ScopedModelDescendant<AccountViewModel>(
        builder: (context, child, model) {
      final status = model.status;
      final user = model.currentUser;
      if (status == ViewStatus.Loading)
        return Container(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ShimmerBlock(width: 200, height: 24),
              SizedBox(height: 8),
              ShimmerBlock(width: 150, height: 24),
              SizedBox(height: 8),
            ],
          ),
        );
      return Container(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Chào 👋',
              style: kSubtitleTextStyle,
            ),
            InkWell(
                onTap: () {
                  model.fetchUser();
                },
                child: Text(user.name, style: kHeadingextStyle)),
            ClipPath(
              clipper: BestSellerClipper(),
              child: Container(
                color: kBestSellerColor,
                padding:
                    EdgeInsets.only(left: 10, top: 5, right: 20, bottom: 5),
                child: Text("Chỉ số hôm nay".toUpperCase(),
                    style: kHeadingextStyle.copyWith(fontSize: 16)),
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildDriverStatistics() {
    return ScopedModelDescendant<AccountViewModel>(
        builder: (context, child, model) {
      final status = model.status;
      final user = model.currentUser;
      if (status == ViewStatus.Loading)
        return Container(
          width: Get.width,
          height: 120,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              DriverStatistic(isLoading: true),
              DriverStatistic(isLoading: true),
            ],
          ),
        );

      return Container(
        width: Get.width,
        // color: Color(0xfff0feff),
        height: 120,
        child: ListView(
          scrollDirection: Axis.horizontal,
          children: [
            DriverStatistic(
              iconPath: "assets/icons/package.png",
              contentTxt: '${model.currentUser?.report?.package ?? "-"}',
              labelTxt: 'Túi đã giao',
            ),
            DriverStatistic(
              iconPath: "assets/icons/path.png",
              contentTxt:
                  '${model.currentUser?.report?.distance != null ? NumberFormat("###.#").format(model.currentUser.report.distance) : "-"} m',
              labelTxt: 'Quãng đường',
            ),
          ],
        ),
      );
    });
  }
}

class IncomingBatchCard extends StatelessWidget {
  const IncomingBatchCard({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ScopedModelDescendant<BatchViewModel>(
        builder: (context, child, model) {
      final status = model.status;
      if (status == ViewStatus.Loading)
        return SingleChildScrollView(
          child: Column(
            children: [
              ShimmerBlock(width: Get.width, height: 24),
              Container(
                margin: EdgeInsets.only(top: 15),
                padding: const EdgeInsets.fromLTRB(15, 15, 15, 15),
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
                      children: [
                        ShimmerBlock(width: 80, height: 24),
                        SizedBox(width: 8),
                        //ShimmerBlock(width: 120, height: 24),
                      ],
                    ),
                    SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        ShimmerBlock(width: 100, height: 24),
                        ShimmerBlock(width: 100, height: 24),
                      ],
                    ),
                    SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        ShimmerBlock(width: 100, height: 32),
                        ShimmerBlock(width: 100, height: 32),
                      ],
                    ),
                    Container(
                      margin: EdgeInsets.only(
                        top: 16,
                        bottom: 16,
                      ),
                      child: MySeparator(
                        color: Colors.grey,
                        dashWidth: 8,
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        ShimmerBlock(width: 120, height: 40),
                        SizedBox(width: 8),
                        ShimmerBlock(width: 120, height: 40),
                      ],
                    ),
                    SizedBox(height: 16),
                    ShimmerBlock(width: Get.width, height: 40),
                  ],
                ),
              ),
            ],
          ),
        );
      if (status == ViewStatus.Error || model.incomingBatch == null) {
        return ListView(
          shrinkWrap: true,
          children: [
            Image.asset(
              "assets/images/backgroundForBatchs.jpg",
              width: Get.width,
              fit: BoxFit.fill,
            ),
            Text(
              "Chưa có chuyến hàng nào, vui lòng quay lại sau",
              style: kDescriptionTextSyle.copyWith(fontSize: 16),
            )
          ],
        );
      }
      BatchDTO batch = model.incomingBatch;
      List<String> timeSlot = batch.timeSlot.split(";");
      return Column(
        children: [
          Text("Chuyến hàng sắp tới", style: kTitleTextStyle),
          Expanded(
            child: ListView(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
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
                          Flexible(
                            child: Row(
                              children: [
                                Text('#${batch.id}',
                                    style: kTitleTextStyle.copyWith(
                                      color: Color(0xff7986a1),
                                    )),
                                SizedBox(width: 8),
                                Container(
                                  padding: EdgeInsets.all(4),
                                  color: Color(0xffffffb8),
                                  child: Text(
                                    'INCOMING',
                                    style: TextStyle(
                                      color: Color(0xfffadb14),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Flexible(
                            child: Text.rich(
                              TextSpan(text: 'Từ ', children: [
                                TextSpan(
                                    text: "${timeSlot[0].substring(0, 5)} ",
                                    style:
                                        kTitleTextStyle.copyWith(fontSize: 14)),
                                TextSpan(
                                  text: "đến ",
                                ),
                                TextSpan(
                                    text: "${timeSlot[1].substring(0, 5)} ",
                                    style:
                                        kTitleTextStyle.copyWith(fontSize: 14)),
                              ]),
                              style:
                                  kDescriptionTextSyle.copyWith(fontSize: 12),
                            ),
                          )
                        ],
                      ),
                      SizedBox(height: 32),
                      Row(
                        children: [
                          Text(
                            '🚩 Bắt đầu:',
                            style: kDescriptionTextSyle,
                          ),
                          SizedBox(width: 8),
                          Text(
                            '${batch.startDepot}',
                            textAlign: TextAlign.left,
                            maxLines: 2,
                            overflow: TextOverflow.visible,
                            style: kTitleTextStyle.copyWith(fontSize: 14),
                          ),
                        ],
                      ),

                      // Row(
                      //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      //   children: [

                      //     Text(
                      //       '🎌 Kết thúc',
                      //       textAlign: TextAlign.right,
                      //       style: kDescriptionTextSyle,
                      //     ),
                      //   ],
                      // ),
                      // Row(
                      //   crossAxisAlignment: CrossAxisAlignment.center,
                      //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      //   children: [
                      //     SizedBox(
                      //       width: 65,
                      //       child: Text(
                      //         '${batch.startDepot}',
                      //         textAlign: TextAlign.left,
                      //         maxLines: 2,
                      //         overflow: TextOverflow.visible,
                      //         style: kTitleTextStyle.copyWith(fontSize: 14),
                      //       ),
                      //     ),
                      //     SizedBox(width: 5),
                      //     Expanded(
                      //       child: MySeparator(color: Colors.blueAccent),
                      //     ),
                      //     Column(
                      //       children: [
                      //         Image(
                      //           width: 40,
                      //           height: 40,
                      //           image: AssetImage(
                      //               "assets/icons/shipper_motorbike.png"),
                      //         ),
                      //         // Text(
                      //         //   '~ ${batch.totalLoad} trạm',
                      //         //   style: kTitleTextStyle.copyWith(fontSize: 12),
                      //         // )
                      //       ],
                      //     ),
                      //     Expanded(
                      //       child: MySeparator(color: Colors.blueAccent),
                      //     ),
                      //     SizedBox(width: 5),
                      //     SizedBox(
                      //       width: 65,
                      //       child: Text(
                      //         'Khu cờ vua',
                      //         textAlign: TextAlign.left,
                      //         maxLines: 2,
                      //         overflow: TextOverflow.ellipsis,
                      //         style: kTitleTextStyle.copyWith(fontSize: 14),
                      //       ),
                      //     ),
                      //   ],
                      // ),
                      // Container(
                      //   margin: EdgeInsets.only(
                      //     top: 16,
                      //     bottom: 16,
                      //   ),
                      //   child: MySeparator(
                      //     color: Colors.grey,
                      //     dashWidth: 8,
                      //   ),
                      // ),
                      // Text(
                      //   "Các điểm đi qua: (${batch.totalLoad} điểm)",
                      //   style: kSubtitleTextStyle.copyWith(
                      //       fontSize: 16, fontWeight: FontWeight.bold),
                      // ),
                      SizedBox(
                        height: 4,
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
                            onTap: () async {
                              print('Khởi hành 🔥');
                              bool result = await Get.toNamed(
                                  RouteHandler.ROUTE,
                                  arguments: batch);
                              if (result != null && result) {
                                model.getIncomingBatch();
                              }
                            },
                            child: Text(
                              'Khởi hành 🔥',
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
                )
              ],
              // crossAxisAlignment: CrossAxisAlignment.start,
            ),
          ),
        ],
      );
    });
  }
}

class DriverStatistic extends StatelessWidget {
  final String iconPath;
  final String contentTxt;
  final String labelTxt;
  final bool isLoading;

  const DriverStatistic({
    Key key,
    this.iconPath,
    this.contentTxt,
    this.labelTxt,
    this.isLoading = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Shimmer.fromColors(
        baseColor: Colors.grey[300],
        highlightColor: Colors.grey[100],
        child: Container(
          width: 120,
          height: 100,
          margin: EdgeInsets.only(left: 8, right: 8),
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8), color: Colors.grey[300]),
        ),
      );
    }

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
            style: kSubtitleTextStyle.copyWith(
              fontSize: 14,
              color: Color(0xffc5c5c9),
            ),
          ),
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
