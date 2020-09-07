import 'package:xml/xml.dart';

/// https://github.com/dart-lang/mime/blob/master/lib/src/default_extension_map.dart
class Color {
  const Color(
    this.name,
    this.type,
    this.hex,
  );

  Color.fromXmlElement(XmlElement element)
      : this(
          element.getAttribute('name'),
          element.getAttribute('type'),
          element.text,
        );

  final String name;

  final String hex;

  final String type;
}
