import 'package:animator/animator.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:uni_express/constraints.dart';
import 'package:uni_express/route_constraint.dart';

class RoleScreen extends StatefulWidget {
  RoleScreen();

  @override
  _RoleScreenState createState() => _RoleScreenState();
}

class _RoleScreenState extends State<RoleScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Container(
          decoration: BoxDecoration(
            image: DecorationImage(image: AssetImage("assets/images/background.png"), fit: BoxFit.cover)
          ),
          child: Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Animator(
                  tween: Tween<Offset>(begin: Offset(-Get.width, Get.height / 2 - 40), end: Offset(0, Get.height / 2 - 40)),
                  duration: Duration(milliseconds: 1000),

                  builder: (context, animatorState, child) => Transform.translate(
                    offset: animatorState.value,
                    child: Container(
                      width: Get.width,
                      margin: EdgeInsets.fromLTRB(32, 0, 32, 0),
                      child: FlatButton(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                          color: Colors.yellow[100],
                          padding: EdgeInsets.fromLTRB(32, 8, 32, 8),
                          onPressed: () {
                            Get.toNamed(RouteHandler.HOME, arguments: 0);
                          },
                          child: Text("Lấy hàng", style: TextStyle(color: Color(0xffa52a2a), fontWeight: FontWeight.bold, fontSize: 20),)),
                    ),
                  ),
                ),
                SizedBox(height: 16,),
                Animator(
                  tween: Tween<Offset>(begin: Offset(Get.width, Get.height / 2 -40), end: Offset(0, Get.height / 2 -40)),
                  duration: Duration(milliseconds: 1000),
                  builder: (context, animatorState, child) => Transform.translate(
                    offset: animatorState.value,
                    child: Center(
                      child: Container(
                        width: Get.width,
                        margin: EdgeInsets.fromLTRB(32, 0, 32, 0),
                        child: FlatButton(
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                            color: Colors.yellow[100],
                            padding: EdgeInsets.fromLTRB(32, 8, 32, 8),
                            onPressed: () {
                              Get.toNamed(RouteHandler.HOME, arguments: 1);
                            },
                            child: Text("Giao hàng", style: TextStyle(color: Color(0xffa52a2a), fontWeight: FontWeight.bold, fontSize: 20),)),
                      ),
                    ),
                  ),
                ),

              ],
            ),
          ),
        ),
      ),
    );
  }


}
