import 'package:path/path.dart';

class CamelCase {
  static String from(String text) {
    List<String> words = _intoWords(basenameWithoutExtension(text))
        .map((word) =>
            '${word.substring(0, 1).toUpperCase()}${word.substring(1).toLowerCase()}')
        .toList();
    words[0] = words[0].toLowerCase();

    return words.join();
  }

  static List<String> _intoWords(String path) {
    final RegExp _symbolRegex = new RegExp(r'[ ./_\-]');
    final RegExp _upperAlphaRegex = new RegExp(r'[A-Z]');
    final RegExp _lowerAlphaRegex = new RegExp(r'[a-z]');
    StringBuffer sb = new StringBuffer();
    List<String> words = [];

    for (int i = 0; i < path.length; i++) {
      String char = new String.fromCharCode(path.codeUnitAt(i));
      String nextChar = (i + 1 == path.length
          ? null
          : new String.fromCharCode(path.codeUnitAt(i + 1)));

      if (_symbolRegex.hasMatch(char)) continue;

      sb.write(char);

      bool isEndOfWord = nextChar == null ||
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
