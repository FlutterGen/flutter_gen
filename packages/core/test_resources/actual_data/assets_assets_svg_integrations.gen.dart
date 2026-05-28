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

class $AssetsImagesGen {
  const $AssetsImagesGen();

  /// Directory path: assets/images/icons
  $AssetsImagesIconsGen get icons => const $AssetsImagesIconsGen();
}

class $AssetsImagesIconsGen {
  const $AssetsImagesIconsGen();

  /// File path: assets/images/icons/dart@test.svg
  SvgGenImage get dartTest =>
      const SvgGenImage('assets/images/icons/dart@test.svg');

  /// File path: assets/images/icons/fuchsia.svg
  SvgGenImage get fuchsia =>
      const SvgGenImage('assets/images/icons/fuchsia.svg');

  /// File path: assets/images/icons/kmm.svg
  SvgGenImage get kmm => const SvgGenImage.vec('assets/images/icons/kmm.svg');

  /// List of all assets
  List<SvgGenImage> get values => [dartTest, fuchsia, kmm];
}

abstract final class Assets {
  static const $AssetsImagesGen images = $AssetsImagesGen();
}
