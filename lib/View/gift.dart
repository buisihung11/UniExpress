import 'package:flutter/material.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import '../constraints.dart';

class GiftScreen extends StatelessWidget {
  const GiftScreen({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Container(
          height: MediaQuery.of(context).size.height,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: Center(
                  child: Container(
                    height: 70,
                    child: Text(
                      "SẮP RA MẮT",
                      style: TextStyle(
                        fontSize: 30,
                        color: kPrimary,
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 32),
              SizedBox(
                width: 250.0,
                height: 100,
                child: FadeAnimatedTextKit(
                  duration: Duration(seconds: 3),
                  // isRepeatingAnimation: true,
                  repeatForever: true,
                  onTap: () {
                    print("Tap Event");
                  },
                  text: [
                    "Tính năng đổi quà đang được phát triển",
                    "Hãy thu thập thật nhiều Bean coin nhé",
                  ],
                  textStyle: TextStyle(
                    fontSize: 20.0,
                    color: kPrimary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              Container(
                // color: Colors.amber,
                height: 300,
                width: MediaQuery.of(context).size.width * 0.9,
                child: Image.asset(
                  'assets/images/coming_soon.gif',
                  fit: BoxFit.cover,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
