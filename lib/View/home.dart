import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:shimmer/shimmer.dart';
import 'package:uni_express/Model/DTO/index.dart';
import 'package:uni_express/ViewModel/index.dart';
import 'package:uni_express/acessories/appbar.dart';
import 'package:animator/animator.dart';
import '../constraints.dart';


const ORDER_TIME = 11;

class HomeScreen extends StatefulWidget {
  final AccountDTO user;
  const HomeScreen({Key key, @required this.user}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool switcher = false;
  PageController _scrollController = new PageController();
  HomeViewModel model = HomeViewModel();

  // int endTime = DateTime.now().millisecondsSinceEpoch + 1000 * 60 * 60;

  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      new GlobalKey<RefreshIndicatorState>();

  @override
  void initState() {
    super.initState();
    model.getProducts();

  }

  Future<void> _refresh() async {
    await model.getProducts();
  }

  @override
  Widget build(BuildContext context) {
    // print(widget?.user.uid);
    return ScopedModelDescendant<RootViewModel>(
      builder:
          (BuildContext context, Widget child, RootViewModel rootViewModel) {
        return ScopedModel(
          model: model,
          child: Scaffold(
            backgroundColor: Colors.white,
            //bottomNavigationBar: bottomBar(),
            body: SafeArea(
              child: Container(
                height: MediaQuery.of(context).size.height,
                child: Stack(
                  children: [
                    Center(
                      child: Padding(
                        padding: EdgeInsets.only(
                            top: MediaQuery.of(context).size.height * 0.12),
                        child: RefreshIndicator(
                          key: _refreshIndicatorKey,
                          onRefresh: _refresh,
                          child: ListView(
                            children: [
                              // banner(),
                              Center(
                                child: Container(
                                  margin: EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(16),
                                    // color: Colors.orange[300],
                                  ),
                                  height:
                                      MediaQuery.of(context).size.height * 0.08,
                                  width: double.infinity,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    HomeAppBar(),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget tag() {
    double screenWidth = MediaQuery.of(context).size.width;

    return Container(
      height: 50,
      width: screenWidth,
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 5,
            blurRadius: 7,
            offset: Offset(0, 3), // changes position of shadow
          ),
        ],
        color: Colors.white,
      ),
      child: Animator(
        tween:
            Tween<Offset>(begin: Offset(-screenWidth, 0), end: Offset(-0, 0)),
        duration: Duration(milliseconds: 700),
        builder: (context, animatorState, child) => Transform.translate(
          offset: animatorState.value,
          child: Container(
            width: screenWidth,
            child: ScopedModelDescendant<HomeViewModel>(
              builder: (context, child, model) {
                final filterType = model.filterType;
                final filterCategories = model.filterCategories;
                List<Filter> mergedFilter = []
                  ..addAll(filterType)
                  ..addAll(filterCategories);
                return Stack(
                  children: [
                    Row(
                      children: [
                        // Container(
                        //   decoration: BoxDecoration(
                        //     border: Border(
                        //       right: BorderSide(
                        //         color: Colors.grey,
                        //         width: 0.0,
                        //       ),
                        //     ),
                        //   ),
                        //   child: IconButton(
                        //       icon: Icon(AntDesign.search1), onPressed: () {}),
                        // ),

                      ],
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

}

