import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:uni_express/Model/DTO/index.dart';
import 'package:uni_express/View/CustomerScreen/customer_order.dart';
import 'package:uni_express/View/DriverScreen/list_batch.dart';
import 'package:uni_express/View/RestaurantScreen/store_order.dart';
import 'package:uni_express/View/index.dart';
import 'package:uni_express/ViewModel/index.dart';
import 'package:uni_express/constraints.dart';
import 'package:uni_express/route_constraint.dart';

class Layout extends StatefulWidget {
  final int initScreenIndex;

  const Layout({Key key, this.initScreenIndex = 0}) : super(key: key);

  @override
  _LayoutState createState() => _LayoutState();
}

class _LayoutState extends State<Layout> {
  final List<IconData> _icons = const [
    MaterialCommunityIcons.food,
    Icons.card_giftcard,
    MaterialCommunityIcons.face_outline,
  ];
  int _selectedIndex = 0;
  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initScreenIndex;
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: _icons.length,
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onHorizontalDragStart: (e) {},
        onLongPress: () {},
        onTap: () {
          // TODO:
          // FEATURE: HIEN GOI Y KHI USER KHONG TAP VAO SCREEN MOT KHOANG THOI GIAN
        },
        child: ScopedModel<RootViewModel>(
          model: RootViewModel.getInstance(),
          child: Scaffold(
            body: IndexedStack(
              index: _selectedIndex,
              children: [
                for (final tabItem in TabNavigationItem.items) tabItem.page,
              ],
            ),
            bottomNavigationBar: BottomNavigationBar(
              currentIndex: _selectedIndex,
              backgroundColor: Colors.white,
              selectedItemColor: Theme.of(context).primaryColor,
              unselectedItemColor: Colors.grey,
              onTap: (int index) => setState(() => _selectedIndex = index),
              items: [
                for (final tabItem in TabNavigationItem.items)
                  BottomNavigationBarItem(
                    icon: tabItem.icon,
                    label: tabItem.title,
                  )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class TabNavigationItem {
  final Widget page;
  final String title;
  final Icon icon;

  TabNavigationItem({
    @required this.page,
    @required this.title,
    @required this.icon,
  });

  static List<TabNavigationItem> get items => [
        TabNavigationItem(
          page: BatchScreen(title: 'Lấy hàng'),
          icon: Icon(Icons.home),
          title: "Trang chủ",
        ),
        TabNavigationItem(
          page: StoreOrderScreen(
            store: StoreDTO(id: 150, name: 'Unibean FPT'),
          ),
          icon: Icon(FontAwesome.motorcycle),
          title: "Lấy hàng",
        ),
        TabNavigationItem(
          page: CustomerOrderScreen(
              store: StoreDTO(id: 150, name: 'Unibean FPT')),
          icon: Icon(SimpleLineIcons.handbag),
          title: "Giao hàng",
        ),
        TabNavigationItem(
          page: ProfileScreen(),
          icon: Icon(MaterialCommunityIcons.face_outline),
          title: "Thông tin",
        ),
      ];
}

class CustomTabBar extends StatelessWidget {
  final List<IconData> icons;
  final int selectedIndex;
  final Function(int) onTap;
  final bool isBottomIndicator;

  const CustomTabBar({
    Key key,
    @required this.icons,
    @required this.selectedIndex,
    @required this.onTap,
    this.isBottomIndicator = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TabBar(
      indicatorPadding: EdgeInsets.zero,
      indicator: BoxDecoration(
        border: isBottomIndicator
            ? Border(
                bottom: BorderSide(
                  color: kPrimary,
                  width: 3.0,
                ),
              )
            : Border(
                top: BorderSide(
                  color: kPrimary,
                  width: 3.0,
                ),
              ),
      ),
      tabs: icons
          .asMap()
          .map((i, e) => MapEntry(
                i,
                Tab(
                  text: "Home",
                  icon: Icon(
                    e,
                    color: i == selectedIndex ? kPrimary : Colors.black45,
                    size: i == selectedIndex ? 24.0 : 16.0,
                  ),
                ),
              ))
          .values
          .toList(),
      onTap: onTap,
    );
  }
}
