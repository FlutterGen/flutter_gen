import 'package:flutter_gen_core/version.gen.dart';

String flutterGenVersion = 'FlutterGen v$packageVersion';

/// Check if the version is at least the minVersion specified.
/// https://github.com/xvrh/lottie-flutter/blob/cb929e791dec2487a424384ff3d513c656d6377b/lib/src/utils/misc.dart#L37-L52
bool isAtLeastVersion(
    int major, int minor, int patch, int minMajor, int minMinor, int minPatch) {
  if (major < minMajor) {
    return false;
  } else if (major > minMajor) {
    return true;
  }

  if (minor < minMinor) {
    return false;
  } else if (minor > minMinor) {
    return true;
  }

  return patch >= minPatch;
}
