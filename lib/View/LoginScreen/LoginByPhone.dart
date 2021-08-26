// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:get/get.dart';
// import 'package:reactive_forms/reactive_forms.dart';
// import 'package:scoped_model/scoped_model.dart';
// import 'package:uni_express/ViewModel/index.dart';
//
// import '../../constraints.dart';
// import '../../countries.dart';
//
//
// class LoginWithPhone extends StatefulWidget {
//   LoginWithPhone({Key key}) : super(key: key);
//
//   @override
//   _LoginWithPhoneState createState() => _LoginWithPhoneState();
// }
//
// class _LoginWithPhoneState extends State<LoginWithPhone> {
//   List<DropdownMenuItem<dynamic>> _dropdownMenuItems;
//   GlobalKey<FormState> _formKey = new GlobalKey();
//   String _phone, _countryCode = "+84";
//   FocusNode _phoneFocus;
//   String _validatTest;
//   bool isError = false;
//
//   // final form = FormGroup({
//   //   'phone': FormControl(validators: [
//   //     Validators.required,
//   //     // Validators.pattern(phoneReg),
//   //     // Validators.number,
//   //   ], touched: false),
//   //   'countryCode': FormControl(validators: [
//   //     Validators.required,
//   //     // Validators.pattern(phoneReg),
//   //     // Validators.number,
//   //   ], touched: false, value: "+84"),
//   // });
//
//   @override
//   void initState() {
//     super.initState();
//
//     _phoneFocus = new FocusNode();
//
//     _dropdownMenuItems = countries
//         .map(
//           (country) => DropdownMenuItem(
//             child: Text(
//               " ${country["code"]} (${country["dial_code"]})",
//               textAlign: TextAlign.center,
//               style: kTextPrimary.copyWith(
//                   color: kBackgroundGrey[0],
//                   fontSize: 12,
//                   fontWeight: FontWeight.bold),
//             ),
//             value: country["dial_code"],
//           ),
//         )
//         .toList();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final screenWidth = MediaQuery.of(context).size.width;
//
//     return SafeArea(
//       child: Scaffold(
//         resizeToAvoidBottomInset: true,
//         backgroundColor: Colors.white,
//         appBar: AppBar(
//           backgroundColor: Colors.transparent,
//           elevation: 0,
//           leading: IconButton(
//             icon: Container(
//               width: 32,
//               height: 32,
//               decoration: BoxDecoration(
//                 color: kPrimary,
//                 borderRadius: BorderRadius.circular(16),
//                 boxShadow: [
//                   BoxShadow(
//                     color: Colors.grey.withOpacity(0.5),
//                     spreadRadius: 2,
//                     blurRadius: 7,
//                     offset: Offset(2, 2), // changes position of shadow
//                   ),
//                 ],
//               ),
//               child: Icon(Icons.arrow_back, color: Colors.white),
//             ),
//             onPressed: () => Get.back(),
//           ),
//         ),
//         body: ScopedModel<LoginViewModel>(
//           model: LoginViewModel(),
//           child: Container(
//             child: Column(
//               children: [
//                 Expanded(
//                   child: Align(
//                     alignment: Alignment.topRight,
//                     child: Container(
//                       padding: EdgeInsets.only(right: 16),
//                       //color: Colors.blue,
//                       child: Image.asset(
//                         'assets/images/phone_input.png',
//                         alignment: Alignment.topRight,
//                       ),
//                     ),
//                   ),
//                 ),
//                 // PHONE FORM
//                 Expanded(
//                   // alignment: Alignment.bottomCenter,
//                   flex: 2,
//                   child: Container(
//                     decoration: BoxDecoration(
//                       color: kPrimary,
//                       borderRadius: BorderRadius.only(
//                         topLeft: Radius.circular(16),
//                         topRight: Radius.circular(16),
//                       ),
//                     ),
//                     padding: EdgeInsets.fromLTRB(0, 24, 0, 0),
//                     width: screenWidth,
//                     // height: screenHeight * 0.5,
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.stretch,
//                       children: [
//                         Padding(
//                           padding: const EdgeInsets.fromLTRB(32, 0, 32, 0),
//                           child: Text(
//                             "Nhập số điện thoại",
//                             style: TextStyle(
//                               color: Colors.white,
//                               fontSize: 24,
//                               fontWeight: FontWeight.bold,
//                             ),
//                           ),
//                         ),
//                         SizedBox(height: 24),
//                         // INPUT
//                         Padding(
//                           padding: const EdgeInsets.fromLTRB(32, 0, 32, 0),
//                           child: Row(
//                             // mainAxisSize: MainAxisSize.max,
//                             children: [
//                               Expanded(
//                                 flex: 1,
//                                 child: Container(
//                                   height: 48,
//                                   decoration: BoxDecoration(
//                                     borderRadius: BorderRadius.circular(8),
//                                     border:
//                                         Border.all(color: kBackgroundGrey[0]),
//                                     color: kPrimary,
//                                   ),
//                                   child: DropdownButtonHideUnderline(
//                                     child: DropdownButton(
//                                       dropdownColor: kSecondary,
//                                       iconSize: 20,
//                                       iconEnabledColor: kBackgroundGrey[0],
//                                       style: kTextPrimary.copyWith(
//                                           fontSize: 12,
//                                           color: kBackgroundGrey[0]),
//                                       items: _dropdownMenuItems,
//                                       value: _countryCode,
//                                       onChanged: (value) => setState(() {
//                                         _countryCode = value;
//                                       }),
//                                     ),
//                                   ),
//                                 ),
//                               ),
//                               SizedBox(width: 8),
//                               Expanded(
//                                   flex: 2,
//                                   child: Container(
//                                     height: 48,
//                                     // height: 100,
//                                     child: Form(
//                                       key: _formKey,
//                                       child: TextFormField(
//                                         autofocus: true,
//                                         focusNode: _phoneFocus,
//                                         inputFormatters: <TextInputFormatter>[
//                                           WhitelistingTextInputFormatter
//                                               .digitsOnly
//                                         ],
//                                         keyboardType: TextInputType.number,
//                                         validator: (input) {
//                                           if (input.trim().length < 9 ||
//                                               input.trim().length > 10) {
//                                             setState(() {
//                                               _validatTest =
//                                                   "Số diện thoại chưa đúng";
//                                               isError = true;
//                                             });
//                                           }
//                                           return null;
//                                         },
//                                         style: _phoneFocus.hasFocus
//                                             ? kTextSecondary
//                                             : kTextPrimary,
//                                         onSaved: (value) {
//                                           _phone = value;
//                                         },
//                                         onChanged: (value) {
//                                           setState(() {
//                                             isError = false;
//                                             _validatTest = null;
//                                           });
//                                         },
//                                         decoration: InputDecoration(
//                                           errorText: _validatTest,
//                                           filled: true,
//                                           fillColor: _phoneFocus.hasFocus
//                                               ? kBackgroundGrey[0]
//                                               : kPrimary,
//                                           focusedBorder: OutlineInputBorder(
//                                             borderRadius:
//                                                 BorderRadius.circular(8),
//                                             borderSide: new BorderSide(
//                                               color: kPrimary,
//                                               style: BorderStyle.solid,
//                                             ),
//                                             // borderRadius: new BorderRadius.circular(25.7),
//                                           ),
//                                           enabledBorder: OutlineInputBorder(
//                                             borderRadius:
//                                                 BorderRadius.circular(8),
//                                             borderSide: new BorderSide(
//                                               color: kBackgroundGrey[0],
//                                               style: BorderStyle.solid,
//                                             ),
//                                           ),
//                                         ),
//                                       ),
//                                     ),
//                                   )),
//                             ],
//                           ),
//                         ),
//                         SizedBox(height: 16),
//                         Expanded(
//                           flex: 10,
//                           child: Container(),
//                         ),
//                         ScopedModelDescendant<LoginViewModel>(
//                           builder: (context, child, model) => ButtonTheme(
//                             minWidth: 150.0,
//                             height: 48,
//                             child: RaisedButton(
//                               color: Colors.white,
//                               // padding: EdgeInsets.fromLTRB(4, 0, 4, 0),
//                               elevation: 8,
//                               shape: RoundedRectangleBorder(
//                                   // borderRadius: BorderRadius.circular(24.0),
//                                   // side: BorderSide(color: Colors.red),
//                                   ),
//                               onPressed: () async {
//                                 // marks all children as touched
//                                 //form.touch();
//                                 if (_formKey.currentState.validate()) {
//                                   if (!isError) {
//                                     _formKey.currentState.save();
//                                     // await pr.show();
//                                     if (_phone[0].contains("0")) {
//                                       _phone = _phone.substring(1);
//                                     }
//                                     String phone = _countryCode + _phone;
//                                     // print("phone $phone");
//                                     await model.onLoginWithPhone(phone);
//                                   }
//                                 }
//                               },
//                               child: Container(
//                                 // width: double.infinity,
//                                 child: Text(
//                                   "Xác nhận",
//                                   style: kTextSecondary,
//                                 ),
//                               ),
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
