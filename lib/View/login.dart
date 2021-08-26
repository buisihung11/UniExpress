import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:uni_express/ViewModel/index.dart';
import 'package:uni_express/enums/view_status.dart';

import '../constraints.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final form = FormGroup({
    'username': FormControl(validators: [
      Validators.required,
    ], touched: false),
    'password': FormControl(validators: [
      Validators.required,
      Validators.minLength(6),
      Validators.maxLength(10)
      // Validators.number,
    ], touched: false),
  });
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
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomPadding: true,
      body: ScopedModel(
        model: LoginViewModel(),
        child: ReactiveForm(
          formGroup: this.form,
          child: Container(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 1,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: Image(
                      image: AssetImage("assets/images/logo.png"),
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: Container(
                      // color: Colors.blue,
                      padding: EdgeInsets.only(right: 24),
                      child: Image.asset(
                        'assets/images/bi.png',
                        // scale: 0.4,
                      ),
                    ),
                  ),
                ),
                Expanded(flex: 3, child: buildLogin()),
                ReactiveFormConsumer(builder: (context, form, child) {
                  return AnimatedContainer(
                    duration: Duration(milliseconds: 2000),
                    curve: Curves.easeInOut,
                    child: ScopedModelDescendant<LoginViewModel>(
                      builder: (context, child, model) => FlatButton(
                        minWidth: Get.width,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                          // side: BorderSide(color: Colors.red),
                        ),

                        onPressed: () async {
                          if (model.status == ViewStatus.Completed) if (form
                              .valid) {
                            await model.loginForStaff(form.value);
                          }
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: model.status == ViewStatus.Loading
                              ? CircularProgressIndicator(
                              backgroundColor: Color(0xFFFFFFFF))
                              : Text(
                            "Đăng nhập",
                            style: TextStyle(
                              color: form.valid ? Color(0xFF00d286) : Colors.grey,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                })
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildLogin() {
    return Container(
        padding: EdgeInsets.only(left: 16, right: 16, top: 16),
        decoration: BoxDecoration(
          color: kPrimary,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
          ),
        ),
        child: Column(
          children: [
            FormItem(
              "Tên đăng nhập",
              "",
              "username",
              labelStyle: kTitleTextStyle.copyWith(
                  color: Colors.white, fontSize: 14),
              borderRadius: 8,
            ),
            FormItem(
              "Mật khẩu",
              "",
              "password",
              labelStyle: kTitleTextStyle.copyWith(
                  color: Colors.white, fontSize: 14),
              borderRadius: 8,
              hideText: true,
            ),
          ],
        ));
  }
}

class FormItem extends StatefulWidget {
  final String label;
  final String hintText;
  final String formName;
  final String keyboardType;
  final bool isReadOnly;
  final TextStyle labelStyle;
  final double borderRadius;
  bool hideText;

  final List<Map<String, dynamic>> radioGroup;

   FormItem(this.label, this.hintText, this.formName,
      {Key key,
      this.keyboardType,
      this.radioGroup,
      this.isReadOnly = false,
      this.labelStyle,
      this.borderRadius,
      this.hideText = false})
      : super(key: key);


  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _FormItemState();
  }
}

class _FormItemState extends State<FormItem>{

  Widget _getFormItemType(FormGroup form) {
    final formControl = form.control(widget.formName);

    switch (widget.keyboardType) {
      case "radio":
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            ...widget.radioGroup
                .map((e) => Flexible(
              child: Row(
                children: [
                  ReactiveRadio(
                    value: e["value"],
                    formControlName: widget.formName,
                  ),
                  Text(e["title"]),
                ],
              ),
            ))
                .toList(),
          ],
        );
      case "datetime":
        return ReactiveDatePicker(
          firstDate: DateTime(1900),
          lastDate: DateTime(2030),
          formControlName: widget.formName,
          builder: (BuildContext context, ReactiveDatePickerDelegate picker,
              Widget child) {
            return GestureDetector(
              onTap: () {
                picker.showPicker();
              },
              child: Container(
                padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                height: 72,
                child: Theme(
                  data: ThemeData.dark(),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          formControl.value != null
                              ? DateFormat('dd/MM/yyyy')
                              .format((formControl.value as DateTime))
                              : widget.hintText,
                          style: TextStyle(color: Colors.blue),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      default:
        return ReactiveTextField(
          validationMessages: {
            ValidationMessage.email: ':(',
            ValidationMessage.required: ':(',
            ValidationMessage.number: ':(',
            ValidationMessage.pattern: ':(',
            ValidationMessage.minLength: 'Mật khẩu từ 6 đến 10 ký tự',
            ValidationMessage.maxLength: 'Mật khẩu từ 6 đến 10 ký tự'
          },
          // enableInteractiveSelection: false,
          style: TextStyle(color: widget.isReadOnly ? Colors.grey : Colors.black),
          readOnly: widget.isReadOnly,
          formControlName: widget.formName,
          textCapitalization: TextCapitalization.words,
          textAlignVertical: TextAlignVertical.center,
          textInputAction: widget.label == "Email"
              ? TextInputAction.done
              : TextInputAction.next,
          obscureText: widget.hideText,
          decoration: InputDecoration(

            filled: true,
            fillColor: Color(0xFFf4f4f6),
            suffixIcon: AnimatedOpacity(
                duration: Duration(milliseconds: 700),
                opacity: widget.formName != "password" ? (formControl.valid ? 1 : 0) : (formControl.value == null || (formControl.value as String).isEmpty ? 0 : 1),
                curve: Curves.fastOutSlowIn,
                child: widget.formName != "password" ? Icon(Icons.check, color: Color(0xff00d286)) : IconButton(icon: Icon(Icons.remove_red_eye, color: widget.hideText ? Colors.grey : Color(0xff00d286)), onPressed: (){setState(() {
                  widget.hideText = !widget.hideText;
                });}, splashColor: Color(0xff00d286),)),
            focusColor: Colors.white,
            focusedBorder: OutlineInputBorder(
              borderSide: new BorderSide(
                  color: widget.isReadOnly ? Colors.transparent : kPrimary),
              // borderRadius: new BorderRadius.circular(25.7),
            ),
            enabledBorder: InputBorder.none,
            // border: OutlineInputBorder(
            //   borderSide: BorderSide.none,
            // ),
            // focusColor: Colors.red,
            hintText: widget.hintText,
            // labelText: label,
          ),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return ReactiveFormConsumer(builder: (context, form, child) {
      return Container(
        margin: EdgeInsets.only(bottom: 15),
        height: 60,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          // crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Flexible(
              flex: 2,
              child: Text(
                widget.label,
                style: widget.labelStyle ??
                    TextStyle(
                      // fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
              ),
            ),
            Flexible(
              flex: 5,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(widget.borderRadius ?? 0),
                  color: Color(0xFFf4f4f6),
                ),
                child: _getFormItemType(form),
              ),
            ),
          ],
        ),
      );
    });
  }

}
