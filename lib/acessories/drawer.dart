
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:uni_express/ViewModel/index.dart';
import 'package:uni_express/acessories/list_item.dart';
import 'package:uni_express/enums/view_status.dart';
import 'package:uni_express/route_constraint.dart';



class DrawerMenu extends StatefulWidget{
  @override
  _DrawState createState() {
    // TODO: implement createState
    return new _DrawState();
  }

}

class _DrawState extends State<DrawerMenu>{
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return ScopedModelDescendant<RootViewModel>(
      builder: (context, child, model) {
        final status = model.status;
        final user = model.currentUser;
        if (status == ViewStatus.Loading)
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: CircularProgressIndicator(),
          );
        else if (status == ViewStatus.Error) return Text("＞﹏＜");
        return Drawer(
          child: ListView(
            children: <Widget>[
              Container(
                height: 230,
                child: DrawerHeader(
                  child: Column(
                    children: <Widget>[
                      Container(
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: Colors.white,
                              width: 1.5,
                            ),
                            shape: BoxShape.circle,
                          ),
                          child: ClipOval(
                            child: Image(
                              image: AssetImage("assets/images/avatar.png"),
                              height: 100,
                              width: 100,
                              fit: BoxFit.cover,
                            ),
                          )),
                      SizedBox(height: 16,),
                      Text(user.name,
                          style: TextStyle(fontSize: 18, color: Colors.orange, fontWeight: FontWeight.bold)),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          FlatButton(
                            color: Colors.white,
                            splashColor: Colors.lightBlue,
                            onPressed: () async {
                              Get.back();
                              bool result = await Get.toNamed(RouteHandler.SIGN_UP);
                              if(result != null && result){
                                model.fetchUser();
                              }
                            },
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(40)),
                            child: Text("Cập nhật ",
                                style: TextStyle(fontSize: 15)),
                          ),
                         
                          FlatButton(
                            color: Colors.white,
                            splashColor: Colors.lightBlue,
                            onPressed: () async {
                              await model.processSignout();
                            },
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(40)),
                            child: Text("Đăng xuất", style: TextStyle(fontSize: 15)),
                          ),
                        ],
                      )
                    ],
                  ),
                  decoration: BoxDecoration(
                    image: DecorationImage(
                        image: AssetImage("assets/images/background.jpg"),
                        fit: BoxFit.cover),
//              gradient: LinearGradient(
//                  colors: [Colors.deepOrange, Colors.orangeAccent]
//              )
                  ),
                ),
              ),
              listItem()
            ],
          ),
        );
      },
    );
  }

  Widget listItem() {
    return Column(
      children: <Widget>[
        itemDrawer(
            'Giao hàng', Icons.person, (){
          Get.back();
          Get.toNamed(RouteHandler.CUSTOMER_ORDER);
        }),
        itemDrawer('Lấy hàng', Icons.art_track,
                (){
                  Get.back();
                  Get.toNamed(RouteHandler.STORE_ORDER);
            }),

      ],
    );
  }

}


