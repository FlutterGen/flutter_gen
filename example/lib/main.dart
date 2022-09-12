import 'package:example_resources/gen/assets.gen.dart' as res;
import 'package:flutter/material.dart';

import 'gen/assets.gen.dart';
import 'gen/colors.gen.dart';
import 'gen/fonts.gen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // await Firebase.initializeApp(
  //   options: DefaultFirebaseOptions.currentPlatform,
  // );

  runApp(MaterialApp(
    title: 'Flutter Demo',
    theme: ThemeData(
      // Auto generated font from FlutterGen.
      fontFamily: MyFontFamily.raleway,
      primarySwatch: MyColorName.crimsonRed,
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
              SizedBox(
                width: 200,
                height: 200,
                child: MyAssets.flare.penguin.flare(
                  animation: 'walk',
                  fit: BoxFit.contain,
                ),
              ),
              SizedBox(
                width: 200,
                height: 200,
                child: MyAssets.rive.vehicles.rive(
                  fit: BoxFit.contain,
                ),
              ),
              MyAssets.images.chip1.image(),
              // Use from example_resource package.
              res.Assets.images.flutter3.image(),
              res.Assets.images.dart.svg(),
              MyAssets.images.icons.kmm.svg(key: const Key("kmm_svg")),
              MyAssets.images.icons.fuchsia.svg(),
              MyAssets.images.icons.paint.svg(
                width: 120,
                height: 120,
              ),
              // MyAssets.pictures.chip5.image(
              //   key: const Key("chip5"),
              //   width: 120,
              //   height: 120,
              //   fit: BoxFit.scaleDown,
              // ),
              const Text(
                'Hi there, I\'m FlutterGen',
                style: TextStyle(
                  // Auto generated color from FlutterGen.
                  color: MyColorName.black60,

                  // Auto generated font from FlutterGen.
                  fontFamily: MyFontFamily.robotoMono,
                  fontFamilyFallback: [MyFontFamily.raleway],
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  ));
}
