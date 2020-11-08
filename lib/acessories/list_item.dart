import 'package:flutter/material.dart';

Widget itemDrawer(String text, IconData iconData, Function function) {
  return Container(
    padding: const EdgeInsets.only(top: 10.0, bottom: 10.0),
    decoration: BoxDecoration(
        border: Border(
      bottom: BorderSide(color: Colors.grey, style: BorderStyle.solid),
    )),
    child: InkWell(
        child: Padding(
          padding: const EdgeInsets.all(5.0),
          child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Icon(iconData),
                    Padding(
                      padding: const EdgeInsets.only(left: 10.0),
                      child: Text(
                        text,
                        style: TextStyle(fontSize: 15),
                      ),
                    ),
                  ],
                ),
                Icon(Icons.arrow_right),
              ]),
        ),
        onTap: function),
  );
}

Widget itemMenu(
    String text, IconData iconData, Color color, Function function) {
  return Container(
    height: 160,
    width: 160,
    margin: const EdgeInsets.all(10.0),
    decoration: BoxDecoration(
        border: Border.all(color: Colors.grey, width: 2),
        borderRadius: BorderRadius.all(Radius.circular(10)), color: color),
    child: InkWell(
        child: Padding(
          padding: const EdgeInsets.all(5.0),
          child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Icon(
                  iconData,
                  size: 60,
                  color: Colors.white,
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 15.0),
                  child: Text(
                    text,
                    style: TextStyle(
                        fontSize: 15,
                        color: Colors.white,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ]),
        ),
        onTap: function),
  );
}


Widget itemMenuForCast(
    String text, IconData iconData, List<Color> colors, Function function) {
  return Container(
    height: 160,
    width: 160,
    margin: const EdgeInsets.all(10.0),
    decoration: BoxDecoration(
        border: Border.all(color: Colors.grey, width: 2),
        borderRadius: BorderRadius.all(Radius.circular(10)),
        gradient: LinearGradient(
          colors: colors
        )

    ),
    child: InkWell(
        child: Padding(
          padding: const EdgeInsets.all(5.0),
          child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Icon(
                  iconData,
                  size: 60,
                  color: Colors.white,
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 15.0),
                  child: Text(
                    text,
                    style: TextStyle(
                        fontSize: 15,
                        color: Colors.white,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ]),
        ),
        onTap: function),
  );
}
