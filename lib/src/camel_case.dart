import 'package:path/path.dart';

class CamelCase {
  static String from(String text) {
    final words = _intoWords(basenameWithoutExtension(text))
        .map((String word) =>
            '${word.substring(0, 1).toUpperCase()}${word.substring(1).toLowerCase()}')
        .toList();
    words[0] = words[0].toLowerCase();

    return words.join();
  }

  static List<String> _intoWords(String path) {
    final _symbolRegex = RegExp(r'[ ./_\-]');
    final _upperAlphaRegex = RegExp(r'[A-Z]');
    final _lowerAlphaRegex = RegExp(r'[a-z]');
    final sb = StringBuffer();
    final words = <String>[];

    for (var i = 0; i < path.length; i++) {
      final char = String.fromCharCode(path.codeUnitAt(i));
      final nextChar = i + 1 == path.length
          ? null
          : String.fromCharCode(path.codeUnitAt(i + 1));

      if (_symbolRegex.hasMatch(char)) {
        continue;
      }

      sb.write(char);

      final isEndOfWord = nextChar == null ||
          (_upperAlphaRegex.hasMatch(nextChar) &&
              path.contains(_lowerAlphaRegex)) ||
          _symbolRegex.hasMatch(nextChar);

      if (isEndOfWord) {
        words.add(sb.toString());
        sb.clear();
      }
    }

    return words;
  }
}
