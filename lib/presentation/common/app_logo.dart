import 'package:flutter/material.dart';

class AppLogo extends StatelessWidget {
  final double? _width;
  final double? _height;
  const AppLogo({
    Key? key,
    double? width = 200,
    double? height = 200,
  })  : _width = width,
        _height = height,
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Image(
        width: _width,
        height: _height,
        image: const AssetImage('assets/images/Logoapp.png'),
      ),
    );
  }
}
