import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:flutter_icons/flutter_icons.dart';

import '../constraints.dart';

Future<void> showStatusDialog(
    String imageUrl, String status, String content) async {
  hideDialog();
  await Get.dialog(WillPopScope(
    onWillPop: () {},
    child: Dialog(
      backgroundColor: Colors.white,
      elevation: 8.0,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16.0))),
      child: Container(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Image(
              image: AssetImage(imageUrl),
              width: 96,
              height: 96,
            ),
            SizedBox(
              height: 8,
            ),
            Text(
              status,
              style: TextStyle(
                  fontWeight: FontWeight.bold, fontSize: 18, color: kPrimary),
            ),
            SizedBox(
              height: 8,
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                content,
                style: TextStyle(fontSize: 16, color: kPrimary),
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.left,
                maxLines: 2,
              ),
            ),
            SizedBox(
              height: 16,
            ),
            Container(
              width: double.infinity,
              child: FlatButton(
                color: kPrimary,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.only(
                        bottomRight: Radius.circular(16),
                        bottomLeft: Radius.circular(16))),
                onPressed: () {
                  hideDialog();
                },
                child: Padding(
                  padding: EdgeInsets.only(top: 16, bottom: 16),
                  child: Text(
                    "OK",
                    style: kTextPrimary,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  ));
}

void showLoadingDialog() {
  hideDialog();
  Get.defaultDialog(
      barrierDismissible: false,
      title: "Chờ mình xý nha...",
      content: WillPopScope(
        onWillPop: () {},
        child: Container(
          padding: const EdgeInsets.all(8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Image(
                width: 72,
                height: 72,
                image: AssetImage("assets/images/loading.gif"),
              ),
            ],
          ),
        ),
      ),
      titleStyle: TextStyle(fontSize: 16));
}

Future<bool> showErrorDialog() async {
  hideDialog();
  bool result;
  await Get.dialog(
      WillPopScope(
        onWillPop: () {},
        child: Dialog(
          backgroundColor: Colors.white,
          elevation: 8.0,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(16.0))),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Align(
                alignment: Alignment.topRight,
                child: IconButton(
                  icon: Icon(
                    AntDesign.closecircleo,
                    color: Colors.red,
                  ),
                  onPressed: () {
                    result = false;
                    hideDialog();
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  "Có một chút trục trặc nhỏ!!",
                  style: TextStyle(fontSize: 16, color: kPrimary),
                ),
              ),
              SizedBox(
                height: 8,
              ),
              Image(
                width: 96,
                height: 96,
                image: AssetImage("assets/images/error.png"),
              ),
              SizedBox(
                height: 8,
              ),
              Container(
                width: double.infinity,
                child: FlatButton(
                  color: kPrimary,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.only(
                          bottomRight: Radius.circular(16),
                          bottomLeft: Radius.circular(16))),
                  onPressed: () {
                    result = true;
                    hideDialog();
                  },
                  child: Padding(
                    padding: EdgeInsets.only(top: 16, bottom: 16),
                    child: Text(
                      "Thử lại",
                      style: kTextPrimary,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: false);
  return result;
}

Future<int> showOptionDialog(String text) async {
  hideDialog();
  int option;
  await Get.dialog(
    WillPopScope(
      onWillPop: () {},
      child: Dialog(
        backgroundColor: Colors.white,
        elevation: 8.0,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(16.0))),
        child: Stack(
          overflow: Overflow.visible,
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Align(
                  alignment: Alignment.topLeft,
                  child: IconButton(
                    icon: Icon(
                      AntDesign.closecircleo,
                      color: Colors.red,
                    ),
                    onPressed: () {
                      option = 0;
                      hideDialog();
                    },
                  ),
                ),
                SizedBox(
                  height: 54,
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    text,
                    style: kTextSecondary,
                  ),
                ),
                SizedBox(
                  height: 16,
                ),
                Container(
                  width: double.infinity,
                  child: FlatButton(
                    color: kPrimary,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.only(
                            bottomRight: Radius.circular(16),
                            bottomLeft: Radius.circular(16))),
                    child: Padding(
                      padding: const EdgeInsets.only(top: 16.0, bottom: 16.0),
                      child: Center(
                        child: Text(
                          "Đồng ý",
                          style: kTextPrimary,
                        ),
                      ),
                    ),
                    onPressed: () {
                      option = 1;
                      hideDialog();
                    },
                  ),
                ),
              ],
            ),
            Positioned(
              top: -54,
              right: -8,
              child: Image(
                image: AssetImage("assets/images/option.png"),
                width: 160,
                height: 160,
              ),
            )
          ],
        ),
      ),
    ),
    barrierDismissible: false,
  );
  return option;
}

void hideDialog() {
  if (Get.isDialogOpen) {
    Get.back();
  }
}

void hideSnackbar() {
  if (Get.isSnackbarOpen) {
    Get.back();
  }
}

// Future<void> changeAddressDialog(RootViewModel model, Function function) async {
//   hideDialog();
//   await Get.dialog(
//       WillPopScope(
//         onWillPop: () {},
//         child: ScopedModel(
//           model: model,
//           child: ScopedModelDescendant<RootViewModel>(
//               builder: (context, child, model) {
//             return Dialog(
//               backgroundColor: Colors.white,
//               elevation: 8.0,
//               shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.all(Radius.circular(16.0))),
//               child: Column(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       Padding(
//                           padding: const EdgeInsets.fromLTRB(16, 8, 0, 8),
//                           child: Icon(
//                             Icons.location_on,
//                             color: Colors.red,
//                             size: 32,
//                           )),
//                       Padding(
//                           padding: const EdgeInsets.all(8.0),
//                           child: Text(
//                             "Chọn một địa chỉ",
//                             style: TextStyle(color: kGreyTitle, fontSize: 16),
//                           )),
//                       Padding(
//                         padding: const EdgeInsets.all(8.0),
//                         child: IconButton(
//                           icon: Icon(
//                             AntDesign.closecircleo,
//                             color: Colors.red,
//                           ),
//                           onPressed: () {
//                             hideDialog();
//                             model.changeAddress = false;
//                             model.notifyListeners();
//                           },
//                         ),
//                       ),
//                     ],
//                   ),
//                   SizedBox(
//                     height: 8,
//                   ),
//                   for (int i = 0; i < model.list.length; i++)
//                     RadioListTile(
//                       activeColor: kFail,
//                       groupValue: model.tmp.id,
//                       value: model.list[i].id,
//                       title: Text(
//                         "${model.list[i].name} - ${model.list[i].location}",
//                         style: kTextSecondary.copyWith(
//                           fontSize: 14,
//                         ),
//                       ),
//                       onChanged: (value) {
//                         model.changeLocation(value);
//                       },
//                     ),
//                   SizedBox(
//                     height: 8,
//                   ),
//                   Container(
//                     width: double.infinity,
//                     child: FlatButton(
//                       color: kPrimary,
//                       shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.only(
//                               bottomRight: Radius.circular(16),
//                               bottomLeft: Radius.circular(16))),
//                       onPressed: function,
//                       child: Padding(
//                         padding: const EdgeInsets.only(top: 16, bottom: 16),
//                         child: Text(
//                           "Xác nhận",
//                           style: kTextPrimary,
//                         ),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             );
//           }),
//         ),
//       ),
//       barrierDismissible: false);
// }
