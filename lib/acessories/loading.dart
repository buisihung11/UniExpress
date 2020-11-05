import 'package:flutter/material.dart';

class LoadingBean extends StatelessWidget {
  const LoadingBean({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Image(
        width: 72,
        height: 72,
        image: AssetImage("assets/images/loading.gif"),
      ),
    );
  }
}
