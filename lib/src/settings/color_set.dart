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

  @override
  // ignore: avoid_equals_and_hash_code_on_mutable_classes
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Color &&
          runtimeType == other.runtimeType &&
          _name == other._name &&
          _hex == other._hex;

  @override
  // ignore: avoid_equals_and_hash_code_on_mutable_classes
  int get hashCode => _name.hashCode ^ _hex.hashCode;
}
