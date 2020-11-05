import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:get/get.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:uni_express/ViewModel/index.dart';

import '../constraints.dart';
import '../route_constraint.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    // await pr.hide();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    return ScopedModel(
      model: LoginViewModel(),
      child: Scaffold(
        backgroundColor: Colors.white,
        resizeToAvoidBottomPadding: false,
        body: Stack(
          children: [
            Container(
              height: screenHeight,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,

                children: [
                  SizedBox(
                    height: screenHeight * 0.1,
                  ),
                  Expanded(
                    flex: 1,
                    child: Container(
                      // color: Colors.blue,
                      padding: EdgeInsets.only(right: 24),
                      child: Image.asset(
                        'assets/images/bi.png',
                        alignment: Alignment.bottomRight,
                        fit: BoxFit.fitHeight,
                        // scale: 0.4,
                      ),
                    ),
                  ),
                  buildLoginButtons(screenHeight, context),
                ],
              ),
            ),
            // Container(
            //   margin: EdgeInsets.only(left: 24),
            //   width: 140,
            //   child: Column(
            //     children: [
            //       Row(
            //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
            //         children: [
            //           Container(
            //             margin: EdgeInsets.only(left: 24),
            //             width: 2,
            //             height: 14,
            //             color: kPrimary,
            //           ),
            //           Container(
            //             margin: EdgeInsets.only(right: 24),
            //             width: 2,
            //             height: 14,
            //             color: kPrimary,
            //           ),
            //         ],
            //       ),
            //       Container(
            //         padding: EdgeInsets.fromLTRB(16, 8, 16, 8),
            //         decoration: BoxDecoration(
            //           color: Colors.white,
            //           borderRadius: BorderRadius.circular(8),
            //           border: Border.all(
            //             color: kPrimary,
            //             width: 3,
            //           ),
            //           boxShadow: [
            //             BoxShadow(
            //               color: Colors.grey.withOpacity(0.5),
            //               spreadRadius: 3,
            //               blurRadius: 10,
            //               offset: Offset(0, 3), // changes position of shadow
            //             ),
            //           ],
            //         ),
            //         child: Text(
            //           'UniDelivery',
            //           style: TextStyle(
            //             color: kPrimary,
            //             letterSpacing: 2,
            //             fontWeight: FontWeight.bold,
            //           ),
            //         ),
            //       ),
            //     ],
            //   ),
            // ),
            Align(
              alignment: Alignment.topLeft,
              child: Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: Image(
                  image: AssetImage("assets/images/logo.png"),
                  width: Get.width * 0.3,

                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget buildLoginButtons(double screenHeight, BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: kPrimary,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      padding: EdgeInsets.fromLTRB(48, 24, 48, 16),
      height: screenHeight * 0.55,
      child: ButtonTheme(
        minWidth: 200.0,
        height: 48,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            RaisedButton(
              color: Colors.white,
              padding: EdgeInsets.fromLTRB(4, 0, 4, 0),
              elevation: 8,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24.0),
                // side: BorderSide(color: Colors.red),
              ),
              onPressed: () {
                Get.toNamed(RouteHandler.LOGIN_PHONE);
              },
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(8),
                    child: Icon(Icons.phone),
                    decoration: BoxDecoration(
                      color: Color(0xffffd24d),
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      "Đăng nhập bằng số điện thoại",
                      style: TextStyle(color: kPrimary, fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 24),
            RaisedButton(
              color: Colors.white,
              padding: EdgeInsets.fromLTRB(4, 0, 4, 0),
              elevation: 8,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24.0),
                // side: BorderSide(color: Colors.red),
              ),
              onPressed: null,
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(8),
                    child: Icon(FontAwesome.google),
                    decoration: BoxDecoration(
                      color: Color(0xffffd24d),
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      "Đăng nhập bằng Gmail",
                      style: TextStyle(color: kPrimary, fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
