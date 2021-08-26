import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:uni_express/ViewModel/startup_viewModel.dart';
import 'package:uni_express/acessories/loading.dart';

import '../constraints.dart';


class StartUpView extends StatelessWidget {
  const StartUpView({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ScopedModel<StartUpViewModel>(
      model: StartUpViewModel.getInstance(),
      child: ScopedModelDescendant<StartUpViewModel>(
          builder: (context, child, model) {
        return Scaffold(
          backgroundColor: Colors.white,
          body: Center(
            child: LoadingScreen(title: "Bean Express",),
          ),
        );
      }),
    );
  }
}

class LoadingScreen extends StatelessWidget {

  final String title;
  const LoadingScreen({Key key, this.title}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Scaffold(
        body: Container(
          // width: 250.0,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,

                children: [
                  LoadingBean(),
                  Text(this.title, style: kTextSecondary,)
                ],
            ),
          ),
        ),
      ),
    );
  }
}
