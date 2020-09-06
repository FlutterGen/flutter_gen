import 'package:xml/xml.dart';

/// https://github.com/dart-lang/mime/blob/master/lib/src/default_extension_map.dart
class Color {
  const Color(
    this._name,
    this._type,
    this._hex,
  );

  Color.fromXmlElement(XmlElement element)
      : this(
          element.getAttribute('name'),
          element.getAttribute('type'),
          element.text,
        );

  final String _name;

  String get name => _name;

  final String _hex;

  String get hex => _hex;

  final String _type;

  String get type => _type;
}
