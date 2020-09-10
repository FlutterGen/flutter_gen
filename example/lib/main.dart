import 'package:example/gen/assets.gen.dart';
import 'package:example/gen/colors.gen.dart';
import 'package:example/gen/fonts.gen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

void main() {
  runApp(MaterialApp(
    title: 'Flutter Demo',
    theme: ThemeData(
      // Auto generated font from FlutterGen.
      fontFamily: FontFamily.raleway,
      primarySwatch: ColorName.crimsonRed,
    ),
    home: Scaffold(
      appBar: AppBar(
        title: const Text('FlutterGen'),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              // Auto generated image from FlutterGen.
              Image(image: Assets.images.chip1),
              Assets.images.icons.kmm.svg(),
              Assets.images.icons.fuchsia.svg(),
              Assets.images.icons.paint.svg(
                width: 120,
                height: 120,
              ),
              Assets.pictures.chip5.image(
                width: 120,
                height: 120,
                fit: BoxFit.scaleDown,
              ),
              const Text(
                'Hi there, I\'m FlutterGen',
                style: TextStyle(
                  // Auto generated color from FlutterGen.
                  color: ColorName.black60,

                  // Auto generated font from FlutterGen.
                  fontFamily: FontFamily.robotoMono,
                  fontFamilyFallback: [FontFamily.raleway],
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  ));
}
