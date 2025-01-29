import 'package:meta/meta.dart';

@immutable
class Import {
  const Import(this.import, {this.alias});

  final String import;
  final String? alias;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    return other is Import &&
        identical(other.import, import) &&
        identical(other.alias, alias);
  }

  @override
  int get hashCode => import.hashCode ^ alias.hashCode;
}
