import 'package:example/gen/assets.gen.dart';
import 'package:example/gen/color.gen.dart';
import 'package:example/gen/fonts.gen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

void main() {
  runApp(MaterialApp(
    title: 'Flutter Demo',
    theme: ThemeData(
      // Auto generated font from FlutterGen.
      fontFamily: FontFamily.raleway,
    ),
    home: Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            // Auto generated image from FlutterGen.
            Image(image: Assets.images.chip1),
            Assets.pictures.chip5.image(
              width: 120,
              height: 120,
              fit: BoxFit.scaleDown,
            ),
            Text(
              'Hi there, I\'m FlutterGen',
              style: TextStyle(
                // Auto generated color from FlutterGen.
                color: ColorName.denim,

                // Auto generated font from FlutterGen.
                fontFamily: FontFamily.robotoMono,
                fontFamilyFallback: const [FontFamily.raleway],
              ),
            ),
          ],
        ),
      ),
    ),
  ));
}
