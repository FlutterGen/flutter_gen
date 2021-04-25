// Copyright (c) 2015, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

library dart_style.src.nesting_level;

import 'fast_hash.dart';

/// A single level of expression nesting.
///
/// When a line is split in the middle of an expression, this tracks the
/// context of where in the expression that split occurs. It ensures that the
/// [LineSplitter] obeys the expression nesting when deciding what column to
/// start lines at when split inside an expression.
///
/// Each instance of this represents a single level of expression nesting. If we
/// split at to chunks with different levels of nesting, the splitter ensures
/// they each get assigned to different columns.
///
/// In addition, each level has an indent. This is the number of spaces it is
/// indented relative to the outer expression. It's almost always
/// [Indent.expression], but cascades are special magic snowflakes and use
/// [Indent.cascade].
class NestingLevel extends FastHash {
  /// The nesting level surrounding this one, or `null` if this is represents
  /// top level code in a block.
  NestingLevel? get parent => _parent;
  NestingLevel? _parent;

  /// The number of characters that this nesting level is indented relative to
  /// the containing level.
  ///
  /// Normally, this is [Indent.expression], but cascades use [Indent.cascade].
  final int indent;

  /// The total number of characters of indentation from this level and all of
  /// its parents, after determining which nesting levels are actually used.
  ///
  /// This is only valid during line splitting.
  int get totalUsedIndent => _totalUsedIndent!;
  int? _totalUsedIndent;

  bool get isNested => _parent != null;

  NestingLevel() : indent = 0;

  NestingLevel._(this._parent, this.indent);

  /// Creates a new deeper level of nesting indented [spaces] more characters
  /// that the outer level.
  NestingLevel nest(int spaces) => NestingLevel._(this, spaces);

  /// Clears the previously calculated total indent of this nesting level.
  void clearTotalUsedIndent() {
    _totalUsedIndent = null;
    _parent?.clearTotalUsedIndent();
  }

  /// Calculates the total amount of indentation from this nesting level and
  /// all of its parents assuming only [usedNesting] levels are in use.
  void refreshTotalUsedIndent(Set<NestingLevel> usedNesting) {
    var totalIndent = _totalUsedIndent;
    if (totalIndent != null) return;

    totalIndent = 0;

    if (_parent != null) {
      _parent!.refreshTotalUsedIndent(usedNesting);
      totalIndent += _parent!.totalUsedIndent;
    }

    if (usedNesting.contains(this)) totalIndent += indent;

    _totalUsedIndent = totalIndent;
  }

  @override
  String toString() {
    if (_parent == null) return indent.toString();
    return '$parent:$indent';
  }
}
