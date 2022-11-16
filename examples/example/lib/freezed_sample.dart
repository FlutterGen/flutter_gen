// main.dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'freezed_sample.freezed.dart';

@freezed
class Union with _$Union {
  const factory Union(int value) = Data;
  const factory Union.loading() = Loading;
  const factory Union.error([String? message]) = ErrorDetails;
}
