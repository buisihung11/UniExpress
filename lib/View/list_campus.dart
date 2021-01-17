import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:uni_express/ViewModel/index.dart';
import 'package:uni_express/acessories/appbar.dart';
import 'package:uni_express/acessories/drawer.dart';
import 'package:uni_express/enums/view_status.dart';

import '../constraints.dart';

class CampusScreen extends StatefulWidget {
  final String navigationPath;
  final String title;
  CampusScreen({Key key, this.navigationPath, this.title}) : super(key: key);

  @override
  _CampusScreenState createState() => _CampusScreenState();
}

class _CampusScreenState extends State<CampusScreen> {
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      new GlobalKey<RefreshIndicatorState>();

  @override
  void initState() {
    super.initState();
    RootViewModel.getInstance().getVirtualStores();
  }

  Future<void> refreshFetchOrder() async {
    await RootViewModel.getInstance().getVirtualStores();
  }

  @override
  Widget build(BuildContext context) {
    print(widget.navigationPath);
    return ScopedModel<RootViewModel>(
      model: RootViewModel.getInstance(),
      child: Scaffold(
        drawer: DrawerMenu(),
        appBar: DefaultAppBar(
          title: widget.title,
        ),
        body: Container(
          margin: EdgeInsets.only(left: 16, right: 16),
          child: ListView(
            shrinkWrap: true,
            children: [
              SizedBox(
                height: 16,
              ),
              Text(
                "Danh sách cửa hàng",
                style: TextStyle(
                    fontSize: 18,
                    color: Colors.deepOrange,
                    fontWeight: FontWeight.bold),
              ),
              _buildStores()
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStores() {
    return ScopedModelDescendant<RootViewModel>(
      builder: (context, child, model) {
        final status = model.status;
        if (status == ViewStatus.Loading)
          return AspectRatio(
            aspectRatio: 1,
            child: Center(child: CircularProgressIndicator()),
          );
        else if (status == ViewStatus.Error) {
          return AspectRatio(
              aspectRatio: 1,
              child: Center(
                child: Text("Đã có sự cố xảy ra :)"),
              ));
        }
        if (model.listStore != null) {
          List<Widget> list = List();
          model.listStore.forEach((element) {
            list.add(Container(
              margin: EdgeInsets.only(top: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.all(Radius.circular(8)),
              ),
              child: ListTile(
                onTap: () {
                  Get.toNamed(widget.navigationPath, arguments: element);
                },
                contentPadding: EdgeInsets.fromLTRB(16, 8, 16, 8),
                title: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      element.id.toString() + " - " + element.name,
                      style: TextStyle(
                          fontSize: 16,
                          color: kPrimary,
                          fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(
                      height: 8,
                    ),
                    Text(
                      "Địa chỉ: " + element.location ?? "-",
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
            ));
          });
          return RefreshIndicator(
            key: _refreshIndicatorKey,
            onRefresh: refreshFetchOrder,
            child: Column(
              children: [...list],
            ),
          );
        }
        return Container();
      },
    );
  }
}
