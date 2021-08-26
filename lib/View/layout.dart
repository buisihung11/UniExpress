import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:uni_express/View/index.dart';
import 'package:uni_express/ViewModel/index.dart';
import 'package:uni_express/constraints.dart';
import 'BeanerScreen/beaner_home.dart';

class Layout extends StatefulWidget {
  final int initScreenIndex;
  final int role;
  final int batchId;

  const Layout({Key key, this.initScreenIndex = 0, this.role, this.batchId}) : super(key: key);

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
                for (final tabItem in items) tabItem.page,
              ],
            ),
            bottomNavigationBar: BottomNavigationBar(
              currentIndex: _selectedIndex,
              backgroundColor: Colors.white,
              selectedItemColor: Theme.of(context).primaryColor,
              unselectedItemColor: Colors.grey,
              onTap: (int index) => setState(() => _selectedIndex = index),
              items: [
                for (final tabItem in items)
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

  List<TabNavigationItem> get items{
    if(widget.role == StaffRole.DRIVER){
      return [
        TabNavigationItem(
          page: BatchScreen(batchId: widget.batchId,),
          icon: Icon(Icons.home),
          title: "Trang chủ",
        ),
        TabNavigationItem(
          page: ProfileScreen(),
          icon: Icon(MaterialCommunityIcons.face_outline),
          title: "Thông tin",
        ),
      ];
    }
    return [
      TabNavigationItem(
        page: BeanerHomeScreen(batchId: widget.batchId,),
        icon: Icon(Icons.home),
        title: "Trang chủ",
      ),
      TabNavigationItem(
        page: ProfileScreen(),
        icon: Icon(MaterialCommunityIcons.face_outline),
        title: "Thông tin",
      ),
    ];
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
}
