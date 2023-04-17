# Contributing to FlutterGen

_See also: [Contributor Covenant Code of Conduct](https://github.com/FlutterGen/flutter_gen/blob/main/CODE_OF_CONDUCT.md)_

## Things you will need

 * Linux, Mac OS X, or Windows.
 * Flutter and Dart (Stable channel)
   * [Melos](https://melos.invertase.dev/)
 * Git

## [Melos](https://melos.invertase.dev/getting-started) Installation
Melos can be installed as a global package via pub.dev:
```sh
$ dart pub global activate melos
```

Once installed & setup, Melos needs to be bootstrapped. Bootstrapping has 2 primary roles:
- Installing all package dependencies (internally using pub get).
- Locally linking any packages together.
```sh
$ melos bootstrap
```

## Running the FlutterGen

#### Use as Dart command
To run `pub get` to make sure its dependencies have been downloaded, and use `dart command`.
```sh
$ dart packages/command/bin/flutter_gen_command.dart --config example/pubspec.yaml
```

Or melos
```sh
$ melos gen:example:command
```

#### Use as part of build_runner
```sh
$ cd example
$ flutter packages pub run build_runner build
```

Or melos
```sh
$ melos gen:example:build_runner
```

## Running the tests

To run the unit tests:

```
$ melos test
```

## Contributing code

We gladly accept contributions via GitHub pull requests.

Please peruse the
[Flutter style guide](https://github.com/flutter/flutter/wiki/Style-guide-for-Flutter-repo) before
working on anything non-trivial. These guidelines are intended to
keep the code consistent and avoid common pitfalls.

To send us a pull request:

* `git pull-request` (if you are using [Hub](http://github.com/github/hub/)) or
  go to `https://github.com/FlutterGen/flutter_gen` and click the
  "Compare & pull request" button

Please make sure all your checkins have detailed commit messages explaining the patch.

The tests are run automatically on contributions using GitHub Actions. However, due to
cost constraints, pull requests from non-committers may not run all the tests
automatically.

Once you've gotten an LGTM from a project maintainer and once your PR has received
the green light from all our automated testing, wait for one the package maintainers
to merge the pull request and `pub submit` any affected packages.
