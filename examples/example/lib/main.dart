import 'package:example/gen/assets.gen.dart' hide RiveGenImage;
import 'package:example/gen/colors.gen.dart';
import 'package:example/gen/fonts.gen.dart';
import 'package:example_resources/gen/assets.gen.dart' hide RiveGenImage;
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:rive/rive.dart' as rive;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
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
                  child: _RiveWidget(MyAssets.rive.vehicles.riveFileLoader()),
                ),
                SizedBox(
                  width: 200,
                  height: 200,
                  child: MyAssets.lottie.hamburgerArrow.lottie(
                    fit: BoxFit.contain,
                  ),
                ),
                SizedBox(
                  width: 200,
                  height: 200,
                  child: MyAssets.lottie.geometricalAnimation.lottie(
                    fit: BoxFit.contain,
                  ),
                ),
                SizedBox(
                  width: 200,
                  height: 200,
                  child: MyAssets.lottie.alarmClockLottieV440.lottie(
                    fit: BoxFit.contain,
                  ),
                ),
                SizedBox(
                  width: 200,
                  height: 200,
                  child: MyAssets.lottie.cat.lottie(
                    decoder: LottieComposition.decodeGZip,
                  ),
                ),
                MyAssets.images.chip1.image(),
                Container(
                  height: 400,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: MyAssets.images.chip1.provider(),
                    ),
                  ),
                  child: const Center(child: Text('Deco')),
                ),
                // Use from example_resource package.
                MyAssets.images.icons.kmm.svg(key: const Key('kmm_svg')),
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

                // example_resource package.
                Text(MyAssets.images.icons.kmm.path),
                Text(MyAssets.images.icons.kmm.keyName),
                Text(ResAssets.images.dart.path),
                Text(ResAssets.images.dart.keyName),
                ResAssets.images.flutter3.image(),
                ResAssets.images.dart.svg(),
                SizedBox(
                  width: 200,
                  height: 200,
                  child: _RiveWidget(ResAssets.images.skills.riveFileLoader()),
                ),
                SizedBox(
                  width: 200,
                  height: 200,
                  child: ResAssets.images.runningCarOnRoad.lottie(
                    fit: BoxFit.contain,
                  ),
                ),
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
    );
  }
}

final class _RiveWidget extends StatefulWidget {
  const _RiveWidget(this.riveFileLoader);

  final rive.FileLoader riveFileLoader;

  @override
  State<_RiveWidget> createState() => _RiveWidgetState();
}

class _RiveWidgetState extends State<_RiveWidget> {
  @override
  void didUpdateWidget(covariant _RiveWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    oldWidget.riveFileLoader.dispose();
  }

  @override
  void dispose() {
    widget.riveFileLoader.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return rive.RiveWidgetBuilder(
      fileLoader: widget.riveFileLoader,
      builder: (context, state) => switch (state) {
        rive.RiveLoading() => const CircularProgressIndicator(),
        rive.RiveFailed() => Text('Failed to load: ${state.error}'),
        rive.RiveLoaded() => rive.RiveWidget(
            controller: state.controller,
            fit: rive.Fit.cover,
          ),
      },
    );
  }
}
