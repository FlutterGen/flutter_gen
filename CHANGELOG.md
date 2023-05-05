## 5.3.1

**Bug fix**  
- [#383](https://github.com/FlutterGen/flutter_gen/pull/383) Fix the wrong path for unknown mime types when `packageParameterEnabled` is enabled. [@blaugold](https://github.com/blaugold)

## 5.3.0

**Feature**
- [#361](https://github.com/FlutterGen/flutter_gen/pull/361) Add package parameter to generated asset provider method. [@orevial](https://github.com/orevial)

**Bug fix**  
- [#396](https://github.com/FlutterGen/flutter_gen/pull/369) Fix `flutter_svg` `>=2.0.4` requires a non-null `clipBehavior` field. [@jetpeter](https://github.com/jetpeter) [@hasanmhallak](https://github.com/hasanmhallak)

**Development**  
- [#380](https://github.com/FlutterGen/flutter_gen/pull/380) Migrate to melos v3. [@blaugold](https://github.com/blaugold) [@jfacoustic](https://github.com/jfacoustic)
- Update Dart SDK to `>=2.17.0 <3.0.0`.

## 5.2.0


**Feature**
- [#350](https://github.com/FlutterGen/flutter_gen/pull/350) [**BREAKING CHANGES**] Upgrade for support of `flutter_svg 2.0.0`.

## 5.1.0, 5.1.0+1

**Feature**  
- [#322](https://github.com/FlutterGen/flutter_gen/issues/322) [#327](https://github.com/FlutterGen/flutter_gen/issues/327) [**BREAKING CHANGES**] Add keyName to integrations and exchange the `path` value.

## 5.0.3

**Bug fix**  
- [#322](https://github.com/FlutterGen/flutter_gen/issues/322) Fix wrong package asset path with svg, lottie, flare and rive integrations.
- [#323](https://github.com/FlutterGen/flutter_gen/issues/323) Fix generate failed when only list in a JSON files.

## 5.0.2

**Bug fix**  
- [#308](https://github.com/FlutterGen/flutter_gen/issues/308) [#309](https://github.com/FlutterGen/flutter_gen/pull/309) Fix missing add to the `lottie#controller`.

## 5.0.1

**Bug fix**  
- [#300](https://github.com/FlutterGen/flutter_gen/pull/300) Fix `package_parameter_enabled` being ignored for Flare, Rive and Lottie.
- [#303](https://github.com/FlutterGen/flutter_gen/pull/303) Add `ignore_for_file: implicit_dynamic_list_literal` to generated files.

**Development**  
- [#306](https://github.com/FlutterGen/flutter_gen/pull/306) Update required `analyzer: '>=4.7.0 <6.0.0'`


## 5.0.0

**Feature**  
- [#285](https://github.com/FlutterGen/flutter_gen/pull/285) [#298](https://github.com/FlutterGen/flutter_gen/pull/298) Add Lottie files integration.
  ```dart
  // Assets.lottie.hamburgerArrow.lottie()
  SizedBox(
    width: 200,
    height: 200,
    child: Assets.lottie.hamburgerArrow.lottie(
      fit: BoxFit.contain,
    ),
  ),
  ```
- [#286](https://github.com/FlutterGen/flutter_gen/pull/286) Allow users to change generated class name for assets, fonts, and colors.
  ```yaml
  flutter_gen:
    assets:
      # Optional
      outputs: 
        class_name: MyAssets # Default is `Assets`

    fonts:
      # Optional
      outputs:
        class_name: MyFontFamily # Default is `FontFamily`

    colors:
      # Optional
      outputs:
        class_name: MyColorName # Default is `ColorName`
  ```
- [#291](https://github.com/FlutterGen/flutter_gen/pull/291) Add values list to generated classes for each directory.
  ```dart
  Assets.images.values // <List<AssetGenImage>>[chip1, chip2, logo, profileJpg, profilePng];
  ```
- [#292](https://github.com/FlutterGen/flutter_gen/pull/292) Support an ImageProvider.
  ```dart
  // Assets.images.chip.provider()
  Container(
    height: 400,
    decoration: BoxDecoration(
      image: DecorationImage(
        image: Assets.images.chip.provider(),
      ),
    ),
    child: const Center(child: Text('Deco')),
  ),

  ```
- [#294](https://github.com/FlutterGen/flutter_gen/pull/294) [**BREAKING CHANGES**] Moved the `style` and `package_parameter_enabled` to under assets.outputs scope.
  ```yaml

  # ❌ Before
  flutter_gen:
    # ...
    assets:
      package_parameter_enabled: true
      style: snake-case
      outputs:
        class_name: MyAssets

  # ⭕️ After
  flutter_gen:
    # ...
    assets:
      outputs:
        class_name: MyAssets
        package_parameter_enabled: true
        style: snake-case
  ```

**Bug fix**  
- [#287 ](https://github.com/FlutterGen/flutter_gen/issues/287) Delete the generated files then flutter_gen won't generate files again
  - [#dart-lang/build#3364](https://github.com/dart-lang/build/issues/3364) Aggregate builder not rebuild when one of multiple output files is deleted.


## 4.3.0

**Feature**
- [#264](https://github.com/FlutterGen/flutter_gen/pull/264) Add `keyName` to asset generate file.
  - [#248](https://github.com/FlutterGen/flutter_gen/pull/248)
  - [#251](https://github.com/FlutterGen/flutter_gen/pull/251)

**Bug fix**
- [#247](https://github.com/FlutterGen/flutter_gen/pull/247) Make the default scale value null, so Flutter decides the one to use.

## 4.2.1, 4.2.1+1

**Bug fix**
- [#236](https://github.com/FlutterGen/flutter_gen/issues/236) The crypto package 3.0.2 conflict in flutter_gen_runner 4.2.0 with integration_test.

## 4.2.0

**Feature**
- [#208](https://github.com/FlutterGen/flutter_gen/pull/208) Add scale and opacity parameters to Image().
- [#221](https://github.com/FlutterGen/flutter_gen/pull/221) Support for build_runner watch.
- [#227](https://github.com/FlutterGen/flutter_gen/pull/227) Maintenance for Flutter3 (flutter_lints to 2.0.1). 
- [#229](https://github.com/FlutterGen/flutter_gen/pull/229) Removed the AssetImage inheritance from AssetGenImage.
  - [Extending package information to asset types other than AssetGenImage.](https://github.com/FlutterGen/flutter_gen/pull/162) 
  - [Added 'gen_for_package:true/false' param to support asset generation for a package.](https://github.com/FlutterGen/flutter_gen/pull/213) 
  ```dart
  // Before
  Widget build(BuildContext context) {
    return Image(image: Assets.images.chip);  // Can't use this.
  }
  // After
  Widget build(BuildContext context) {
    return Assets.images.chip.image();
  }
  ```
  - Added example_resource package for how to use another package resources from an app.
  ```dart
  # file: example_resources/pubspec.yaml
  # ... 
  flutter_gen:
    # ...
    assets:
      enabled: true
      package_parameter_enabled: true

  #...
  ```
- [#230](https://github.com/FlutterGen/flutter_gen/pull/230) Add coverage ignore comment on generated file headers.
- Update collection to 1.16.0.
- Update min dart sdk to >=2.14.0 <3.0.0.


**Development**
- Update to Dart 2.17.1
- Update to Flutter 3.0.1


## 4.1.6, 4.1.6+1

**Feature**
- [#199](https://github.com/FlutterGen/flutter_gen/pull/199) [#201](https://github.com/FlutterGen/flutter_gen/pull/201) Expose some parameters of SvgPicture (flutter_svg).
  - theme
  - cacheColorFilter

## 4.1.5

**Bug fix**  
- [#187](https://github.com/FlutterGen/flutter_gen/issues/187) Update dependencies.
  - analyzer

## 4.1.4

**Feature**
- [#180](https://github.com/FlutterGen/flutter_gen/issues/180) [#182](https://github.com/FlutterGen/flutter_gen/pull/182) Update to dartx 1.0.0 and json_serializable to 6.0.0

**Development**
- Update to Dart 2.15.0
- Update to Flutter 2.8.1

## 4.1.3

**Bug fix**  
- [#172](https://github.com/FlutterGen/flutter_gen/pull/172) [#173](https://github.com/FlutterGen/flutter_gen/pull/173) Add unnecessary_import in ignore_for_title because cause warning from Dart 2.15.

## 4.1.2+1, 4.1.2+2

**Development**  
- Added sample code.

## 4.1.2

**Bug fix**
- [#156](https://github.com/FlutterGen/flutter_gen/pull/156) The Dartdocs generate different strings on Windows and Ubuntu.

## 4.1.0

**Feature**
- [#138](https://github.com/FlutterGen/flutter_gen/pull/138) Generate dartdoc as follows.
  ```dart
  /// File path: pictures/chip5.jpg
  AssetGenImage get chip5 => const AssetGenImage('pictures/chip5.jpg');
  /// Color: #979797
  static const Color gray410 = Color(0xFF979797);
  ```
- [#143](https://github.com/FlutterGen/flutter_gen/pull/143) Support [Rive](https://rive.app/) files type. 
  ```yaml
  flutter_gen:
    integrations:
      rive: true
  ```
- [#150](https://github.com/FlutterGen/flutter_gen/pull/150) Added the --version option for command-line.
  ```shell
  % fluttergen --version 
  FlutterGen v4.1.0
  ```
**Bug fix**
- [#134](https://github.com/FlutterGen/flutter_gen/pull/134) Added the ability to support the at symbol (@) in file names.
  ```dart
  AssetGenImage get logo2x => const AssetGenImage('assets/images/logo@2x.png');
  ```
**Development**
- Update to Dart 2.14.4.
- Update to Flutter 2.5.3.
- Replace to renovate.

## 4.0.1

**Bug fix**
- [#134](https://github.com/FlutterGen/flutter_gen/issues/134) Support the at symbol (@) in file names.
- [#139](https://github.com/FlutterGen/flutter_gen/issues/139) Error: Method not found: '$checkedCreate

**Development**
- Replace to flutter_lints.

## 4.0.0

**Features**
- [BREAKING] Ended support for Non null safety codes.
- Use for `line_length` instead of `lineLength`.


**Development**
- Replace to [Melos](https://pub.dev/packages/melos).
- Add VSCode setting.

## 3.1.2

- [#117](https://github.com/FlutterGen/flutter_gen/issues/117) Update to analyzer 2.0.0.  
[flutter_gen_runner (flutter_gen_core) 3.1.2 -> analyzer 2.0.0 workaround](https://github.com/FlutterGen/flutter_gen/issues/121)
  ```yaml
  dependency_overrides:
    meta: ^1.7.0
  ```

- [#110](https://github.com/FlutterGen/flutter_gen/pull/110) Replace null safety dart style package.  

## 3.1.1

**Features** & **Bug fix**
- [#103](https://github.com/FlutterGen/flutter_gen/pull/103) Add option packageParameterEnabled to control whether to generate package parameter for assets or not.  

## 3.1.0

**Features**  
- [#98](https://github.com/FlutterGen/flutter_gen/pull/98) Support for adding assets from a package  


## 3.0.0, 3.0.1, 3.0.2

- Support Null Safety
```yaml
flutter_gen:
  output: lib/gen/
  line_length: 80
  null_safety: true # Optional (default: true)
```

## 2.0.1, 2.0.2, 2.0.3

- Update dependencies

## 2.0.0

New Feature
- [BREAKING CHANGE] [#49](https://github.com/FlutterGen/flutter_gen/issues/49) [#53](https://github.com/FlutterGen/flutter_gen/issues/53) Name collision with flutter localization when using build_runner
  ```yaml
  # Before
  # dev_dependencies:
  #  flutter_gen: 1.3.1
  
  # After
  dev_dependencies:
    flutter_gen_runner: ^2.0.0
  ```
- [#74](https://github.com/FlutterGen/flutter_gen/issues/74) Doesn't generate assets.gen.dart when there are no assets
  ```yaml
  flutter_gen:
    fonts:
      enabled: false
  ```
- [#59](https://github.com/FlutterGen/flutter_gen/issues/59) Handling duplicate file names
  ```dart
  // generated codes
  static const AssetGenImage imagesProfileJpg = AssetGenImage('assets/images/profile.jpg'); 
  static const AssetGenImage imagesProfilePng = AssetGenImage('assets/images/profile.png');
  ```


**Bug fix**
- [#75](https://github.com/FlutterGen/flutter_gen/issues/75) Null safety support for generated files 

## 1.3.1

**Bug fix**
- [#60](https://github.com/FlutterGen/flutter_gen/issues/60) Set files like .DS_Store to the ignore list.

## 1.3.0

New Feature
- [#46](https://github.com/FlutterGen/flutter_gen/issues/46) Added support for unknown mime type files.
- Added support for [Rive (previously Flare)](https://rive.app/) files.

## 1.2.2

**Bug fix**
- [#51](https://github.com/FlutterGen/flutter_gen/pull/51) Added support for Key parameter in image() and svg().

## 1.2.1

**Bug fix**
- [#42](https://github.com/FlutterGen/flutter_gen/pull/42) Generated output folder name not being respected

## 1.2.0

New Feature
- [#40](https://github.com/FlutterGen/flutter_gen/pull/40) Support MaterialAccentColor

## 1.1.0

New Feature
  - [#33](https://github.com/FlutterGen/flutter_gen/pull/33) Support to generate flat hierarchy assets with field name style:
    - camel-case
    - snake-case
    - dot-delimiter (Default)

## 1.0.3

**Bug fix**
  - Insufficient params of flutter_svg [#32](https://github.com/FlutterGen/flutter_gen/pull/34)
## 1.0.2

**Bug fix**
  - Generate sorted statements [#27](https://github.com/FlutterGen/flutter_gen/pull/27)
  - Make Windows work properly [#28](https://github.com/FlutterGen/flutter_gen/pull/28) 

## 1.0.1

**Bug fix**
  - Issue [#21](https://github.com/FlutterGen/flutter_gen/issues/21)

## 1.0.0

Initial release.

- Assets generator
  - Supported image type.
  - Supported SVG as an integration.
  - And others.

- Fonts generator
- Colors generator
  - Supported xml file.
    - MaterialColor
