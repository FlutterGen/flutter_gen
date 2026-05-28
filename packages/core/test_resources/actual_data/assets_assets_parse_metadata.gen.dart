// dart format width=80

/// GENERATED CODE - DO NOT MODIFY BY HAND
/// *****************************************************
///  FlutterGen
/// *****************************************************

// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: deprecated_member_use,directives_ordering,implicit_dynamic_list_literal,unnecessary_import

import 'package:flutter_gen_interface/flutter_gen_interface.dart';
export 'package:flutter_gen_interface/flutter_gen_interface.dart';

class $PicturesGen {
  const $PicturesGen();

  /// File path: pictures/chip5.jpg
  AssetGenImage get chip5 =>
      const AssetGenImage('pictures/chip5.jpg', size: const Size(600.0, 403.0));

  /// List of all assets
  List<AssetGenImage> get values => [chip5];
}

class $AssetsFlareGen {
  const $AssetsFlareGen();

  /// File path: assets/flare/Penguin.flr
  String get penguin => 'assets/flare/Penguin.flr';

  /// List of all assets
  List<String> get values => [penguin];
}

class $AssetsImagesGen {
  const $AssetsImagesGen();

  /// Directory path: assets/images/animated
  $AssetsImagesAnimatedGen get animated => const $AssetsImagesAnimatedGen();

  /// File path: assets/images/chip1.jpg
  AssetGenImage get chip1 => const AssetGenImage(
    'assets/images/chip1.jpg',
    size: const Size(600.0, 403.0),
  );

  /// File path: assets/images/chip2.jpg
  AssetGenImage get chip2 => const AssetGenImage('assets/images/chip2.jpg');

  /// Directory path: assets/images/chip3
  $AssetsImagesChip3Gen get chip3 => const $AssetsImagesChip3Gen();

  /// Directory path: assets/images/chip4
  $AssetsImagesChip4Gen get chip4 => const $AssetsImagesChip4Gen();

  /// Directory path: assets/images/icons
  $AssetsImagesIconsGen get icons => const $AssetsImagesIconsGen();

  /// File path: assets/images/logo.png
  AssetGenImage get logo => const AssetGenImage(
    'assets/images/logo.png',
    size: const Size(209.0, 49.0),
  );

  /// File path: assets/images/profile.jpg
  AssetGenImage get profileJpg =>
      const AssetGenImage('assets/images/profile.jpg');

  /// File path: assets/images/profile.png
  AssetGenImage get profilePng =>
      const AssetGenImage('assets/images/profile.png');

  /// List of all assets
  List<AssetGenImage> get values => [
    chip1,
    chip2,
    logo,
    profileJpg,
    profilePng,
  ];
}

class $AssetsJsonGen {
  const $AssetsJsonGen();

  /// File path: assets/json/list.json
  String get list => 'assets/json/list.json';

  /// File path: assets/json/map.json
  String get map => 'assets/json/map.json';

  /// List of all assets
  List<String> get values => [list, map];
}

class $AssetsMovieGen {
  const $AssetsMovieGen();

  /// File path: assets/movie/the_earth.mp4
  String get theEarth => 'assets/movie/the_earth.mp4';

  /// List of all assets
  List<String> get values => [theEarth];
}

class $AssetsUnknownGen {
  const $AssetsUnknownGen();

  /// File path: assets/unknown/unknown_mime_type.bk
  String get unknownMimeType => 'assets/unknown/unknown_mime_type.bk';

  /// List of all assets
  List<String> get values => [unknownMimeType];
}

class $AssetsImagesAnimatedGen {
  const $AssetsImagesAnimatedGen();

  /// File path: assets/images/animated/emoji_hugging_face.webp
  AssetGenImage get emojiHuggingFace => const AssetGenImage(
    'assets/images/animated/emoji_hugging_face.webp',
    size: const Size(512.0, 512.0),
    animation: const AssetGenImageAnimation(
      isAnimation: true,
      duration: Duration(milliseconds: 2970),
      frames: 45,
    ),
  );

  /// List of all assets
  List<AssetGenImage> get values => [emojiHuggingFace];
}

class $AssetsImagesChip3Gen {
  const $AssetsImagesChip3Gen();

  /// File path: assets/images/chip3/chip3.jpg
  AssetGenImage get chip3 => const AssetGenImage(
    'assets/images/chip3/chip3.jpg',
    size: const Size(600.0, 403.0),
  );

  /// List of all assets
  List<AssetGenImage> get values => [chip3];
}

class $AssetsImagesChip4Gen {
  const $AssetsImagesChip4Gen();

  /// File path: assets/images/chip4/chip4.jpg
  AssetGenImage get chip4 => const AssetGenImage(
    'assets/images/chip4/chip4.jpg',
    size: const Size(600.0, 403.0),
  );

  /// List of all assets
  List<AssetGenImage> get values => [chip4];
}

class $AssetsImagesIconsGen {
  const $AssetsImagesIconsGen();

  /// File path: assets/images/icons/dart@test.svg
  SvgGenImage get dartTest => const SvgGenImage(
    'assets/images/icons/dart@test.svg',
    size: Size(512.001, 512.001),
  );

  /// File path: assets/images/icons/fuchsia.svg
  SvgGenImage get fuchsia => const SvgGenImage(
    'assets/images/icons/fuchsia.svg',
    size: Size(50.0, 50.0),
  );

  /// File path: assets/images/icons/invalid.svg
  SvgGenImage get invalid =>
      const SvgGenImage('assets/images/icons/invalid.svg');

  /// File path: assets/images/icons/kmm.svg
  SvgGenImage get kmm => const SvgGenImage(
    'assets/images/icons/kmm.svg',
    size: Size(755.0, 310.0),
  );

  /// File path: assets/images/icons/paint.svg
  SvgGenImage get paint => const SvgGenImage(
    'assets/images/icons/paint.svg',
    size: Size(472.0, 392.0),
  );

  /// List of all assets
  List<SvgGenImage> get values => [dartTest, fuchsia, invalid, kmm, paint];
}

abstract final class Assets {
  static const $AssetsFlareGen flare = $AssetsFlareGen();
  static const $AssetsImagesGen images = $AssetsImagesGen();
  static const $AssetsJsonGen json = $AssetsJsonGen();
  static const $AssetsMovieGen movie = $AssetsMovieGen();
  static const $AssetsUnknownGen unknown = $AssetsUnknownGen();
  static const $PicturesGen pictures = $PicturesGen();
}
