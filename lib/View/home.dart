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
  DateTime now = DateTime.now();
  DateTime orderTime = DateTime(DateTime.now().year, DateTime.now().month,
      DateTime.now().day, ORDER_TIME, 30);
  // int endTime = DateTime.now().millisecondsSinceEpoch + 1000 * 60 * 60;
  bool _endOrderTime = false;

  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      new GlobalKey<RefreshIndicatorState>();

  @override
  void initState() {
    super.initState();
    model.getProducts();
    if (orderTime.isBefore(DateTime.now())) {
      setState(() {
        _endOrderTime = true;
      });
    }
    print("Orderable: " + _endOrderTime.toString());
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
            floatingActionButton: buildCartButton(rootViewModel),
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
                                    color: Colors.blue[200],
                                  ),
                                  height:
                                      MediaQuery.of(context).size.height * 0.13,
                                  width: double.infinity,
                                  child: Image.asset(
                                    'assets/images/banner.png',
                                    fit: BoxFit.cover,
                                    // width: double.infinity,
                                  ),
                                ),
                              ),
                              SizedBox(height: 16),
                              SizedBox(height: 16),
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



  Widget buildCartButton(rootViewModel) {
    return !_endOrderTime
        ? ScopedModelDescendant(
            rebuildOnChange: true,
            builder: (context, child, HomeViewModel model) {
              return FutureBuilder(
                  future: model.cart,
                  builder: (context, snapshot) {
                    Cart cart = snapshot.data;
                    if (cart == null) return SizedBox.shrink();
                    int quantity = cart?.itemQuantity();
                    return Container(
                      margin: EdgeInsets.only(bottom: 40),
                      child: FloatingActionButton(
                        backgroundColor: Colors.transparent,
                        elevation: 8,
                        heroTag: CART_TAG,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                          // side: BorderSide(color: Colors.red),
                        ),
                        onPressed: () async {
                          print('Tap order');
                          await model.openCart(rootViewModel);
                        },
                        child: Stack(
                          overflow: Overflow.visible,
                          children: [
                            Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                AntDesign.shoppingcart,
                                color: kPrimary,
                              ),
                            ),
                            Positioned(
                              top: -10,
                              left: 32,
                              child: Container(
                                width: 24,
                                height: 24,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(16),
                                  color: Colors.red,
                                  //border: Border.all(color: Colors.grey),
                                ),
                                child: Center(
                                  child: Text(
                                    quantity.toString(),
                                    style: kTextPrimary.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                    );
                  });
            })
        : SizedBox.shrink();
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
                        Expanded(
                          flex: 2,
                          child: PageView(
                            controller: _scrollController,
                            scrollDirection: Axis.horizontal,
                            children: [
                              Container(
                                width: screenWidth,
                                padding: const EdgeInsets.all(10),
                                child: ListView.separated(
                                  itemBuilder: (context, index) =>
                                      filterButton(mergedFilter[index]),
                                  scrollDirection: Axis.horizontal,
                                  itemCount: mergedFilter.length,
                                  separatorBuilder:
                                      (BuildContext context, int index) =>
                                          SizedBox(width: 8),
                                ),
                              ),
                            ],
                          ),
                        ),
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

  Widget filterButton(Filter filter) {
    final title = filter.name;
    final id = filter.id;
    final isSelected = filter.isSelected;
    final isMultiple = filter.isMultiple;

    return ButtonTheme(
      minWidth: 62,
      height: 32,
      focusColor: kPrimary,
      hoverColor: kPrimary,
      textTheme: ButtonTextTheme.normal,
      child: ScopedModelDescendant<HomeViewModel>(
          builder: (context, child, model) {
        final onChangeFilter = model.updateFilter;
        return FlatButton(
          color: isSelected ? Color(0xFF00d286) : kBackgroundGrey[0],
          padding: EdgeInsets.all(4),
          onPressed: () async {
            await onChangeFilter(id, isMultiple);
          },
          child: Row(
            children: [
              isSelected && isMultiple
                  ? Padding(
                      padding: const EdgeInsets.only(right: 4.0),
                      child: Icon(
                        Icons.done,
                        size: 20,
                      ),
                    )
                  : SizedBox(),
              Text(
                title,
                style: isSelected
                    ? kTextPrimary.copyWith(
                        fontWeight: FontWeight.bold,
                      )
                    : kTextPrimary.copyWith(color: Colors.black),
              ),
            ],
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
        );
      }),
    );
  }
}

class FoodItem extends StatefulWidget {
  final ProductDTO product;
  FoodItem({Key key, this.product}) : super(key: key);

  @override
  _FoodItemState createState() => _FoodItemState();
}

class _FoodItemState extends State<FoodItem> {
  @override
  Widget build(BuildContext context) {
    final product = widget.product;
    final name = product.name;
    final imageURL = product.imageURL;
    return Container(
      // width: MediaQuery.of(context).size.width * 0.3,
      margin: const EdgeInsets.only(
        left: 10,
        right: 10,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(10)),
        // color: Colors.white,
      ),
      child: Material(
        color: Colors.transparent,
        child: ScopedModelDescendant<HomeViewModel>(
            builder: (context, child, model) {
          return InkWell(
            customBorder: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            onTap: () async {
              print('Add item to cart');
              model.openProductDetail(product);
            },
            child: Opacity(
              opacity: 1,
              child: Column(
                children: [
                  Hero(
                    tag: product.id,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Opacity(
                        opacity: 1,
                        child: AspectRatio(
                          aspectRatio: 1.14,
                          child: (imageURL == null || imageURL == "")
                              ? Icon(
                                  MaterialIcons.broken_image,
                                  color: kPrimary.withOpacity(0.5),
                                )
                              : CachedNetworkImage(
                                  imageUrl: imageURL,
                                  imageBuilder: (context, imageProvider) =>
                                      Container(
                                    decoration: BoxDecoration(
                                      image: DecorationImage(
                                        image: imageProvider,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                  progressIndicatorBuilder:
                                      (context, url, downloadProgress) =>
                                          Shimmer.fromColors(
                                    baseColor: Colors.grey[300],
                                    highlightColor: Colors.grey[100],
                                    enabled: true,
                                    child: Container(
                                      width: 100,
                                      height: 100,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  errorWidget: (context, url, error) => Icon(
                                    MaterialIcons.broken_image,
                                    color: kPrimary.withOpacity(0.5),
                                  ),
                                ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      // color: Colors.blue,
                      height: 60,
                      child: Text(
                        name,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 2,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}
