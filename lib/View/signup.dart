// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:intl/intl.dart';
// import 'package:reactive_forms/reactive_forms.dart';
// import 'package:scoped_model/scoped_model.dart';
// import 'package:uni_express/Model/DTO/index.dart';
// import 'package:uni_express/ViewModel/index.dart';
// import 'package:uni_express/enums/view_status.dart';
// import 'package:uni_express/utils/regex.dart';
//
// import '../constraints.dart';
// import '../route_constraint.dart';
//
// class SignUp extends StatefulWidget {
//   const SignUp({Key key, this.user, this.isCreatemode = false})
//       : super(key: key);
//   final AccountDTO user;
//   final bool isCreatemode;
//
//   @override
//   _SignUpState createState() => _SignUpState();
// }
//
// class _SignUpState extends State<SignUp> {
//   final form = FormGroup({
//     'name': FormControl(validators: [
//       Validators.required,
//     ], touched: false),
//     'phone': FormControl(validators: [
//       Validators.required,
//       Validators.pattern(phoneReg),
//       // Validators.number,
//     ], touched: false),
//     'birthdate': FormControl(validators: [
//       Validators.required,
//     ], touched: false),
//     'email': FormControl(validators: [
//       Validators.required,
//       Validators.email,
//     ], touched: false),
//     'gender': FormControl(validators: [
//       Validators.required,
//     ], touched: false, value: 'nam'),
//   });
//
//   @override
//   void initState() {
//     super.initState();
//
//     final user = widget.user;
//     // UPDATE USER INFO INTO FORM
//     if (user != null)
//       form.value = {
//         "name": user.name,
//         "phone": user.phone,
//         "birthdate": user.birthdate,
//       };
//   }
//
//   Future<void> _onUpdateUser(SignUpViewModel model) async {
//     bool updateSucces = false;
//     AccountDTO updatedUser;
//     if (form.valid) {
//       try {
//         updatedUser = await model.updateUser(form.value);
//         print('Updated User ${updatedUser.name}');
//         updateSucces = true;
//       } catch (e) {
//         await _showMyDialog("Lỗi", e.toString());
//       } finally {
//         // Chuyen trang
//         if (updateSucces) {
//           print('Update Success');
//           if (widget.user != null && !widget.user.isFirstLogin) {
//             Get.back(result: true);
//           } else {
//             Get.offAllNamed(RouteHandler.ROUTE);
//           }
//         } else {}
//       }
//     }
//   }
//
//   Future<void> _showMyDialog(String title, String content) async {
//     return showDialog<void>(
//       context: context,
//       barrierDismissible: false, // user must tap button!
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: Text('$title'),
//           content: SingleChildScrollView(
//             child: ListBody(
//               children: <Widget>[
//                 Text('$content'),
//               ],
//             ),
//           ),
//           actions: <Widget>[
//             FlatButton(
//               child: Text('Approve'),
//               onPressed: () {
//                 Get.back();
//               },
//             ),
//           ],
//         );
//       },
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final screenWidth = MediaQuery.of(context).size.width;
//     final screenHeight = MediaQuery.of(context).size.height;
//     return ScopedModel(
//       model: SignUpViewModel(),
//       child: Scaffold(
//         resizeToAvoidBottomPadding: false,
//         body: ReactiveForm(
//           formGroup: this.form,
//           child: Stack(
//             children: [
//               // BACKGROUND
//               Container(
//                 color: Color(0xFFddf1ed),
//               ),
//               Positioned(
//                 right: 0,
//                 bottom: 0,
//                 child: Container(
//                   height: screenHeight * 0.35,
//                   // width: 250,
//                   child: Image.asset(
//                     'assets/images/sign_up_character.png',
//                   ),
//                 ),
//               ),
//               // SIGN-UP FORM
//               Stack(
//                 overflow: Overflow.visible,
//                 children: [
//                   Container(
//                     decoration: BoxDecoration(
//                       borderRadius: BorderRadiusDirectional.circular(16),
//                       color: Colors.white,
//                     ),
//                     margin: EdgeInsets.fromLTRB(8, 8, 8, 0),
//                     padding: EdgeInsets.fromLTRB(8, 16, 8, 0),
//                     width: screenWidth,
//                     height: screenHeight * 0.75,
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         // HELLO SECTION
//                         Text(
//                           "Vài bước nữa là xong rồi nè!",
//                           style: TextStyle(
//                             color: Color(0xFF00d286),
//                             fontSize: 20,
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                         SizedBox(height: 8),
//                         Text(
//                           "Giúp mình điền vài thông tin dưới đây nhé.",
//                           style: TextStyle(
//                             color: Color(0xFF00d286),
//                             fontSize: 18,
//                             fontWeight: FontWeight.w500,
//                           ),
//                         ),
//                         SizedBox(height: 16),
//                         // FORM ITEM
//                         Expanded(
//                           child: ListView(
//                             shrinkWrap: true,
//                             children: [
//                               FormItem("Họ Tên", "Nguyễn Văn A", "name"),
//                               FormItem(
//                                 "Số Điện Thoại",
//                                 "012345678",
//                                 "phone",
//                                 isReadOnly: true,
//                               ),
//                               FormItem("Email", "abc@gmail.com", "email"),
//                               FormItem(
//                                 "Ngày sinh",
//                                 "01/01/2020",
//                                 "birthdate",
//                                 keyboardType: "datetime",
//                               ),
//                               FormItem(
//                                 "Giới tính",
//                                 null,
//                                 "gender",
//                                 keyboardType: "radio",
//                                 radioGroup: [
//                                   {
//                                     "title": "Nam",
//                                     "value": "nam",
//                                   },
//                                   {
//                                     "title": "Nữ",
//                                     "value": "nữ",
//                                   }
//                                 ],
//                               ),
//                             ],
//                           ),
//                         ),
//                         //SIGN UP BUTTON
//                         ReactiveFormConsumer(builder: (context, form, child) {
//                           return AnimatedContainer(
//                             duration: Duration(milliseconds: 2000),
//                             curve: Curves.easeInOut,
//                             margin: EdgeInsets.fromLTRB(0, 10, 0, 10),
//                             child: Center(
//                               child: ScopedModelDescendant<SignUpViewModel>(
//                                 builder: (context, child, model) =>
//                                     RaisedButton(
//                                   shape: RoundedRectangleBorder(
//                                     borderRadius: BorderRadius.circular(18.0),
//                                     // side: BorderSide(color: Colors.red),
//                                   ),
//                                   color: form.valid
//                                       ? Color(0xFF00d286)
//                                       : Colors.grey,
//                                   onPressed: () async {
//                                     if (model.status == ViewStatus.Completed)
//                                       await _onUpdateUser(model);
//                                   },
//                                   child: Padding(
//                                     padding: const EdgeInsets.all(10.0),
//                                     child: model.status == ViewStatus.Loading
//                                         ? CircularProgressIndicator(
//                                             backgroundColor:
//                                                 Color(0xFFFFFFFF))
//                                         : Text(
//                                             form.valid
//                                                 ? "Hoàn thành"
//                                                 : "Bạn chưa điền xong",
//                                             style: TextStyle(
//                                               color: Colors.white,
//                                               fontSize: 18,
//                                               fontWeight: FontWeight.bold,
//                                             ),
//                                           ),
//                                   ),
//                                 ),
//                               ),
//                             ),
//                           );
//                         }),
//                         // BACK TO NAV SCREEN
//                         Center(
//                           child: GestureDetector(
//                             onTap: () async {
//                               if (widget.user != null &&
//                                   !widget.user.isFirstLogin) {
//                                 Get.back();
//                               } else
//                                 Get.offAllNamed(RouteHandler.ROUTE);
//                             },
//                             child: Text(
//                               "Bỏ qua",
//                               style: TextStyle(
//                                 color: Colors.grey[400],
//                                 fontWeight: FontWeight.bold,
//                               ),
//                             ),
//                           ),
//                         ),
//                         SizedBox(height: 10),
//                       ],
//                     ),
//                   ),
//                   Positioned(
//                     bottom: -50,
//                     left: screenWidth * 0.55,
//                     child: ClipPath(
//                       clipper: TriangleClipPath(),
//                       child: Container(
//                         width: 50,
//                         height: 50,
//                         color: Colors.white,
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
//
// class FormItem extends StatelessWidget {
//   final String label;
//   final String hintText;
//   final String formName;
//   final String keyboardType;
//   final bool isReadOnly;
//
//   final List<Map<String, dynamic>> radioGroup;
//
//   const FormItem(
//     this.label,
//     this.hintText,
//     this.formName, {
//     Key key,
//     this.keyboardType,
//     this.radioGroup,
//     this.isReadOnly = false,
//   }) : super(key: key);
//
//   Widget _getFormItemType(FormGroup form) {
//     final formControl = form.control(formName);
//
//     switch (keyboardType) {
//       case "radio":
//         return Row(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: [
//             ...radioGroup
//                 .map((e) => Flexible(
//                       child: Row(
//                         children: [
//                           ReactiveRadio(
//                             value: e["value"],
//                             formControlName: formName,
//                           ),
//                           Text(e["title"]),
//                         ],
//                       ),
//                     ))
//                 .toList(),
//           ],
//         );
//       case "datetime":
//         return ReactiveDatePicker(
//           firstDate: DateTime(1900),
//           lastDate: DateTime(2030),
//           formControlName: formName,
//           builder: (BuildContext context, ReactiveDatePickerDelegate picker,
//               Widget child) {
//             return GestureDetector(
//               onTap: () {
//                 picker.showPicker();
//               },
//               child: Container(
//                 padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
//                 height: 72,
//                 child: Theme(
//                   data: ThemeData.dark(),
//                   child: Row(
//                     children: [
//                       Expanded(
//                         child: Text(
//                           formControl.value != null
//                               ? DateFormat('dd/MM/yyyy')
//                                   .format((formControl.value as DateTime))
//                               : hintText,
//                           style: TextStyle(color: Colors.blue),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             );
//           },
//         );
//       default:
//         return ReactiveTextField(
//           validationMessages: {
//             ValidationMessage.email: ':(',
//             ValidationMessage.required: ':(',
//             ValidationMessage.number: ':(',
//             ValidationMessage.pattern: ':('
//           },
//           // enableInteractiveSelection: false,
//           style: TextStyle(color: isReadOnly ? Colors.grey : Colors.black),
//           readOnly: isReadOnly,
//           formControlName: formName,
//           textCapitalization: TextCapitalization.words,
//           textAlignVertical: TextAlignVertical.center,
//           textInputAction: this.label == "Email" ? TextInputAction.done : TextInputAction.next,
//           decoration: InputDecoration(
//             filled: true,
//             fillColor: Color(0xFFf4f4f6),
//             suffixIcon: AnimatedOpacity(
//                 duration: Duration(milliseconds: 700),
//                 opacity: formControl.valid ? 1 : 0,
//                 curve: Curves.fastOutSlowIn,
//                 child: Icon(Icons.check, color: Color(0xff00d286))),
//             focusColor: Colors.white,
//             focusedBorder: OutlineInputBorder(
//               borderSide: new BorderSide(
//                   color: isReadOnly ? Colors.transparent : kPrimary),
//               // borderRadius: new BorderRadius.circular(25.7),
//             ),
//             enabledBorder: InputBorder.none,
//             // border: OutlineInputBorder(
//             //   borderSide: BorderSide.none,
//             // ),
//             // focusColor: Colors.red,
//             hintText: hintText,
//             // labelText: label,
//           ),
//         );
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return ReactiveFormConsumer(builder: (context, form, child) {
//       return Container(
//         margin: EdgeInsets.only(bottom: 15),
//         height: 60,
//         child: Row(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           // crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Flexible(
//               flex: 2,
//               child: Text(
//                 label,
//                 style: TextStyle(
//                   // fontWeight: FontWeight.bold,
//                   color: Colors.black87,
//                 ),
//               ),
//             ),
//             Flexible(
//               flex: 5,
//               child: Container(
//                 color: Color(0xFFf4f4f6),
//                 child: _getFormItemType(form),
//               ),
//             ),
//           ],
//         ),
//       );
//     });
//   }
// }
//
// class TriangleClipPath extends CustomClipper<Path> {
//   var radius = 10.0;
//   @override
//   Path getClip(Size size) {
//     Path path = Path();
//     path.lineTo(size.width / 2, size.height);
//     path.lineTo(size.width, 0.0);
//     return path;
//   }
//
//   @override
//   bool shouldReclip(CustomClipper<Path> oldClipper) => false;
// }
