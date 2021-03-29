import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class ShimmerBlock extends StatelessWidget {
  final double width;
  final double height;

  const ShimmerBlock({Key key, this.width = 20, this.height = 10})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300],
      highlightColor: Colors.grey[100],
      child: Container(
        width: width,
        height: height,
        color: Colors.grey[300],
      ),
    );
  }
}
