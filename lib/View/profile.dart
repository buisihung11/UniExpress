import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:shimmer/shimmer.dart';
import 'package:uni_express/Model/DTO/index.dart';
import 'package:uni_express/ViewModel/index.dart';
import 'package:uni_express/enums/view_status.dart';
import 'package:uni_express/utils/index.dart';


import '../constraints.dart';
import '../route_constraint.dart';

class ProfileScreen extends StatefulWidget {
  ProfileScreen();

  @override
  _UpdateAccountState createState() {
    // TODO: implement createState
    return new _UpdateAccountState();
  }
}

class _UpdateAccountState extends State<ProfileScreen> {
  Image _userImage;

  @override
  void initState() {
    super.initState();
    _userImage = Image(
      image: NetworkImage(defaultImage),
      fit: BoxFit.cover,
    );
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      body: userInfo(),
    );
  }

  Widget userInfo() {
    return ScopedModel(
      model: RootViewModel.getInstance(),
      child: ScopedModelDescendant<RootViewModel>(
        builder: (context, child, model) {
          final status = model.status;
          if (status == ViewStatus.Loading)
            return Shimmer.fromColors(
              baseColor: Colors.grey[300],
              highlightColor: Colors.grey[100],
              enabled: true,
              child: Container(
                width: MediaQuery.of(context).size.width * 0.45,
                height: 20,
                color: Colors.grey,
              ),
            );
          else if (status == ViewStatus.Error)
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("＞﹏＜"),
                  signoutButton(),
                ],
              ),
            );

          return Container(
            color: kBackgroundGrey[0],
            margin: EdgeInsets.only(top: 16),
            child: Column(
              children: [
                Expanded(
                  child: ListView(
                    shrinkWrap: true,
                    children: <Widget>[
                      userImage(),
                      SizedBox(
                        height: 8,
                      ),
                      userAccount(model.currentUser),
                      SizedBox(
                        height: 8,
                      ),
                      userButton("Cập nhật", model),
                      SizedBox(
                        height: 8,
                      ),
                      signoutButton()
                    ],
                  ),
                ),
                systemInfo()
              ],
            ),
          );
        },
      ),
    );
  }

  Widget userImage() {
    return Center(
      child: Container(
        height: 250,
        width: 250,
        decoration: BoxDecoration(
            border: Border.all(width: 5.0, color: kPrimary),
            shape: BoxShape.circle),
        child: ClipOval(child: Image.asset('assets/images/avatar.png')),
      ),
    );
  }

  Widget userAccount(AccountDTO user) {
    return Container(
      child: Center(
        child: Column(
          children: <Widget>[
            SizedBox(
              height: 8,
            ),
            Text(
              user.name.toUpperCase(),
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(
              height: 8,
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Số tiền trong ví: ${formatPrice(user.balance)}",
                  style: TextStyle(fontSize: 15),
                ),
                Text(
                  "Số đậu trong ví: ${user.point.round().toString()} Bean",
                  style: TextStyle(fontSize: 15),
                ),
              ],
            ),
            SizedBox(
              height: 8,
            ),
          ],
        ),
      ),
    );
  }

  Widget userButton(String text, RootViewModel model) {
    return Container(
      margin: const EdgeInsets.only(left: 80.0, right: 80.0),
      child: FlatButton(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(8))),
        textColor: kBackgroundGrey[0],
        color: kPrimary,
        splashColor: kSecondary,
        child: Text(
          text,
          style: TextStyle(fontSize: 16),
        ),
        onPressed: () async {
          print("Update: ");
          bool result = await Get.toNamed(RouteHandler.SIGN_UP,
              arguments: model.currentUser);
          if (result != null) {
            if (result) {
              await model.fetchUser();
            }
          }
        },
      ),
    );
  }

  Widget signoutButton() {
    return ScopedModelDescendant<RootViewModel>(
        builder: (context, child, model) {
      return Container(
        margin: const EdgeInsets.only(left: 80.0, right: 80.0),
        child: OutlineButton(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(8))),
          textColor: kBackgroundGrey[0],
          color: kBackgroundGrey[0],
          borderSide: BorderSide(color: Colors.red),
          splashColor: kBackgroundGrey[3],
          child: Text(
            "Đăng xuất",
            style: TextStyle(fontSize: 16, color: kFail),
          ),
          onPressed: () async {
            await model.processSignout();
          },
        ),
      );
    });
  }

  Widget systemInfo() {
    return Container(
      margin: EdgeInsets.only(left: 32, right: 32, bottom: 0, top: 16),
      padding: EdgeInsets.only(left: 32, right: 32),
      // decoration: BoxDecoration(
      //   border: Border(top: BorderSide(color: kBackgroundGrey[3], width: 1)),
      // ),

      child: Center(
        child: Column(
          children: <Widget>[
            Text(
              "Version $VERSION by UniTeam",
              style: TextStyle(fontSize: 13, color: kBackgroundGrey[5]),
            ),
            SizedBox(
              height: 8,
            ),
            Container(
              // height: 40,
              child: RichText(
                text: TextSpan(
                  text: "Bean delivery ",
                  style: TextStyle(
                      fontSize: 13,
                      color: Colors.black,
                      fontWeight: FontWeight.bold
                      // fontStyle: FontStyle.italic,
                      ),
                  // children: <TextSpan>[
                  //   TextSpan(
                  //     text: "UniTeam",
                  //     style: TextStyle(
                  //       fontSize: 14,
                  //       fontStyle: FontStyle.italic,
                  //     ),
                  //   )
                  // ],
                ),
              ),
            ),
            SizedBox(
              height: 8,
            )
          ],
        ),
      ),
    );
  }
}
