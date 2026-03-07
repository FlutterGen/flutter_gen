# example_workspace

A minimal pub workspace example for FlutterGen.

## Workspace layout

- `packages/gallery_one`: generates asset accessors for `flutter3.jpg`
- `packages/gallery_two`: generates asset accessors for `dart.svg`

Both packages use `flutter_gen_runner` through `build_runner --workspace`.

## Version requirements

- Dart SDK: `>=3.7.0`
- `build_runner`: `>=2.12.0`

FlutterGen's current `build_runner` integration relies on post-process builders
with `build_to: source`, which is only supported in `build_runner 2.12+`.

## Getting started

```sh
cd examples/example_workspace
flutter pub get
```

Generate all workspace members from the workspace root:

```sh
dart run build_runner build --workspace --delete-conflicting-outputs
```

Generated files will be written to:

- `packages/gallery_one/lib/gen/assets.gen.dart`
- `packages/gallery_two/lib/gen/assets.gen.dart`
