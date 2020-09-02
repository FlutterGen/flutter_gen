# Contributing to FlutterGen

_See also: [Contributor Covenant Code of Conduct](https://github.com/wasabeef/flutter_gen/blob/main/CODE_OF_CONDUCT.md)_

## Things you will need

 * Linux, Mac OS X, or Windows.
 * git.

## Running the build_runner

To run an example with build_runner, switch to that
example's directory, run `flutter pub get` to make sure its dependencies have been
downloaded, and use `build_runner`. 

```sh
$ cd example 
$ flutter packages pub run build_runner build --delete-conflicting-outputs
```

## Running the tests

Flutter plugins have both unit tests of their Dart API and integration tests that run on a virtual or actual device.

To run the unit tests:

```
$ flutter test
```

To run the integration tests:

```sh
cd example
flutter drive
```

## Contributing code

We gladly accept contributions via GitHub pull requests.

Please peruse the
[Flutter style guide](https://github.com/flutter/flutter/wiki/Style-guide-for-Flutter-repo) and
[design principles](https://flutter.io/design-principles/) before
working on anything non-trivial. These guidelines are intended to
keep the code consistent and avoid common pitfalls.

To send us a pull request:

* `git pull-request` (if you are using [Hub](http://github.com/github/hub/)) or
  go to `https://github.com/wasabeef/flutter_gen` and click the
  "Compare & pull request" button

Please make sure all your checkins have detailed commit messages explaining the patch.

The tests are run automatically on contributions using GitHub Actions. However, due to
cost constraints, pull requests from non-committers may not run all the tests
automatically.

Once you've gotten an LGTM from a project maintainer and once your PR has received
the green light from all our automated testing, wait for one the package maintainers
to merge the pull request and `pub submit` any affected packages.
