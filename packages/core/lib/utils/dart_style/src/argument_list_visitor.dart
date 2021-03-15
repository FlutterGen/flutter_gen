// Copyright (c) 2014, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.
import 'dart:math' as math;

import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/token.dart';

import 'chunk.dart';
import 'rule/argument.dart';
import 'rule/rule.dart';
import 'source_visitor.dart';

/// Helper class for [SourceVisitor] that handles visiting and writing an
/// [ArgumentList], including all of the special code needed to handle
/// block-formatted arguments.
class ArgumentListVisitor {
  final SourceVisitor _visitor;

  /// The "(" before the argument list.
  final Token _leftParenthesis;

  /// The ")" after the argument list.
  final Token _rightParenthesis;

  /// All of the arguments, positional, named, and functions, in the argument
  /// list.
  final List<Expression> _allArguments;

  /// The normal arguments preceding any block function arguments.
  final ArgumentSublist _arguments;

  /// The contiguous list of block function arguments, if any.
  ///
  /// Otherwise, this is `null`.
  final List<Expression>? _functions;

  /// If there are block function arguments, this is the arguments after them.
  ///
  /// Otherwise, this is `null`.
  final ArgumentSublist? _argumentsAfterFunctions;

  /// Returns `true` if there is only a single positional argument.
  bool get _isSingle =>
      _allArguments.length == 1 && _allArguments.single is! NamedExpression;

  /// Whether this argument list has any arguments that should be formatted as
  /// blocks.
  // TODO(rnystrom): Returning true based on collections is non-optimal. It
  // forces a method chain to break into two but the result collection may not
  // actually split which can lead to a method chain that's allowed to break
  // where it shouldn't.
  bool get hasBlockArguments =>
      _arguments._blocks.isNotEmpty || _functions != null;

  factory ArgumentListVisitor(SourceVisitor visitor, ArgumentList node) {
    return ArgumentListVisitor.forArguments(
        visitor, node.leftParenthesis, node.rightParenthesis, node.arguments);
  }

  factory ArgumentListVisitor.forArguments(
      SourceVisitor visitor,
      Token leftParenthesis,
      Token rightParenthesis,
      List<Expression> arguments) {
    // Look for a single contiguous range of block function arguments.
    var functionsStart;
    var functionsEnd;

    for (var i = 0; i < arguments.length; i++) {
      var argument = arguments[i];
      if (_isBlockFunction(argument)) {
        functionsStart ??= i;

        // The functions must be one contiguous section.
        if (functionsEnd != null && functionsEnd != i) {
          functionsStart = null;
          functionsEnd = null;
          break;
        }

        functionsEnd = i + 1;
      }
    }

    // Edge case: If all of the arguments are named, but they aren't all
    // functions, then don't handle the functions specially. A function with a
    // bunch of named arguments tends to look best when they are all lined up,
    // even the function ones (unless they are all functions).
    //
    // Prefers:
    //
    //     function(
    //         named: () {
    //           something();
    //         },
    //         another: argument);
    //
    // Over:
    //
    //     function(named: () {
    //       something();
    //     },
    //         another: argument);
    if (functionsStart != null &&
        arguments[0] is NamedExpression &&
        (functionsStart > 0 || functionsEnd < arguments.length)) {
      functionsStart = null;
    }

    // Edge case: If all of the function arguments are named and there are
    // other named arguments that are "=>" functions, then don't treat the
    // block-bodied functions specially. In a mixture of the two function
    // styles, it looks cleaner to treat them all like normal expressions so
    // that the named arguments line up.
    if (functionsStart != null &&
        arguments[functionsStart] is NamedExpression) {
      bool isArrow(NamedExpression named) {
        var expression = named.expression;

        if (expression is FunctionExpression) {
          return expression.body is ExpressionFunctionBody;
        }

        return false;
      }

      for (var i = 0; i < functionsStart; i++) {
        var argument = arguments[i];
        if (argument is! NamedExpression) continue;

        if (isArrow(argument)) {
          functionsStart = null;
          break;
        }
      }

      for (var i = functionsEnd; i < arguments.length; i++) {
        if (isArrow(arguments[i] as NamedExpression)) {
          functionsStart = null;
          break;
        }
      }
    }

    if (functionsStart == null) {
      // No functions, so there is just a single argument list.
      return ArgumentListVisitor._(visitor, leftParenthesis, rightParenthesis,
          arguments, ArgumentSublist(arguments, arguments), null, null);
    }

    // Split the arguments into two independent argument lists with the
    // functions in the middle.
    var argumentsBefore = arguments.take(functionsStart).toList();
    var functions = arguments.sublist(functionsStart, functionsEnd);
    var argumentsAfter = arguments.skip(functionsEnd).toList();

    return ArgumentListVisitor._(
        visitor,
        leftParenthesis,
        rightParenthesis,
        arguments,
        ArgumentSublist(arguments, argumentsBefore),
        functions,
        ArgumentSublist(arguments, argumentsAfter));
  }

  ArgumentListVisitor._(
      this._visitor,
      this._leftParenthesis,
      this._rightParenthesis,
      this._allArguments,
      this._arguments,
      this._functions,
      this._argumentsAfterFunctions) {
    assert(_functions == null || _argumentsAfterFunctions != null,
        'If _functions is passed, _argumentsAfterFunctions must be too.');
  }

  /// Builds chunks for the argument list.
  void visit() {
    // If there is just one positional argument, it tends to look weird to
    // split before it, so try not to.
    if (_isSingle) _visitor.builder.startSpan();

    _visitor.builder.startSpan();
    _visitor.token(_leftParenthesis);

    _arguments.visit(_visitor);

    _visitor.builder.endSpan();

    var functions = _functions;
    if (functions != null) {
      // TODO(rnystrom): It might look better to treat the parameter list of the
      // first function as if it were an argument in the preceding argument list
      // instead of just having this little solo split here. That would try to
      // keep the parameter list with other arguments when possible, and, I
      // think, generally look nicer.
      if (functions.first == _allArguments.first) {
        _visitor.soloZeroSplit();
      } else {
        _visitor.soloSplit();
      }

      for (var argument in functions) {
        if (argument != functions.first) _visitor.space();

        _visitor.visit(argument);

        // Write the following comma.
        if (_visitor.hasCommaAfter(argument)) {
          _visitor.token(argument.endToken.next);
        }
      }

      _visitor.builder.startSpan();
      _argumentsAfterFunctions!.visit(_visitor);
      _visitor.builder.endSpan();
    }

    _visitor.token(_rightParenthesis);

    if (_isSingle) _visitor.builder.endSpan();
  }

  /// Returns `true` if [expression] is a [FunctionExpression] with a non-empty
  /// block body.
  static bool _isBlockFunction(Expression expression) {
    if (expression is NamedExpression) expression = expression.expression;

    // Allow functions wrapped in dotted method calls like "a.b.c(() { ... })".
    if (expression is MethodInvocation) {
      if (!_isValidWrappingTarget(expression.target)) return false;
      if (expression.argumentList.arguments.length != 1) return false;

      return _isBlockFunction(expression.argumentList.arguments.single);
    }

    if (expression is InstanceCreationExpression) {
      if (expression.argumentList.arguments.length != 1) return false;

      return _isBlockFunction(expression.argumentList.arguments.single);
    }

    // Allow immediately-invoked functions like "() { ... }()".
    if (expression is FunctionExpressionInvocation) {
      if (expression.argumentList.arguments.isNotEmpty) return false;

      expression = expression.function;
    }

    // Unwrap parenthesized expressions.
    while (expression is ParenthesizedExpression) {
      expression = expression.expression;
    }

    // Must be a function.
    if (expression is! FunctionExpression) return false;

    // With a curly body.
    if (expression.body is! BlockFunctionBody) return false;

    // That isn't empty.
    var body = expression.body as BlockFunctionBody;
    return body.block.statements.isNotEmpty ||
        body.block.rightBracket.precedingComments != null;
  }

  /// Returns `true` if [expression] is a valid method invocation target for
  /// an invocation that wraps a function literal argument.
  static bool _isValidWrappingTarget(Expression? expression) {
    // Allow bare function calls.
    if (expression == null) return true;

    // Allow property accesses.
    while (expression is PropertyAccess) {
      expression = expression.target;
    }

    if (expression is PrefixedIdentifier) return true;
    if (expression is SimpleIdentifier) return true;

    return false;
  }
}

/// A range of arguments from a complete argument list.
///
/// One of these typically covers all of the arguments in an invocation. But,
/// when an argument list has block functions in the middle, the arguments
/// before and after the functions are treated as separate independent lists.
/// In that case, there will be two of these.
class ArgumentSublist {
  /// The full argument list from the AST.
  final List<Expression> _allArguments;

  /// The positional arguments, in order.
  final List<Expression> _positional;

  /// The named arguments, in order.
  final List<Expression> _named;

  /// Maps each block argument, excluding functions, to the first token for that
  /// argument.
  final Map<Expression, Token> _blocks;

  /// The number of leading block arguments, excluding functions.
  ///
  /// If all arguments are blocks, this counts them.
  final int _leadingBlocks;

  /// The number of trailing blocks arguments.
  ///
  /// If all arguments are blocks, this is zero.
  final int _trailingBlocks;

  /// The rule used to split the bodies of all block arguments.
  Rule? get blockRule => _blockRule;
  Rule? _blockRule;

  /// The most recent chunk that split before an argument.
  Chunk? get previousSplit => _previousSplit;
  Chunk? _previousSplit;

  factory ArgumentSublist(
      List<Expression> allArguments, List<Expression> arguments) {
    // Assumes named arguments follow all positional ones.
    var positional =
        arguments.takeWhile((arg) => arg is! NamedExpression).toList();
    var named = arguments.skip(positional.length).toList();

    var blocks = <Expression, Token>{};
    for (var argument in arguments) {
      var bracket = _blockToken(argument);
      if (bracket != null) blocks[argument] = bracket;
    }

    // Count the leading arguments that are blocks.
    var leadingBlocks = 0;
    for (var argument in arguments) {
      if (!blocks.containsKey(argument)) break;
      leadingBlocks++;
    }

    // Count the trailing arguments that are blocks.
    var trailingBlocks = 0;
    if (leadingBlocks != arguments.length) {
      for (var argument in arguments.reversed) {
        if (!blocks.containsKey(argument)) break;
        trailingBlocks++;
      }
    }

    // Blocks must all be a prefix or suffix of the argument list (and not
    // both).
    if (leadingBlocks != blocks.length) leadingBlocks = 0;
    if (trailingBlocks != blocks.length) trailingBlocks = 0;

    // Ignore any blocks in the middle of the argument list.
    if (leadingBlocks == 0 && trailingBlocks == 0) {
      blocks.clear();
    }

    return ArgumentSublist._(
        allArguments, positional, named, blocks, leadingBlocks, trailingBlocks);
  }

  ArgumentSublist._(this._allArguments, this._positional, this._named,
      this._blocks, this._leadingBlocks, this._trailingBlocks);

  void visit(SourceVisitor visitor) {
    if (_blocks.isNotEmpty) {
      _blockRule = Rule(Cost.splitBlocks);
    }

    var rule = _visitPositional(visitor);
    _visitNamed(visitor, rule);
  }

  /// Writes the positional arguments, if any.
  PositionalRule? _visitPositional(SourceVisitor visitor) {
    if (_positional.isEmpty) return null;

    // Allow splitting after "(".
    // Only count the blocks in the positional rule.
    var leadingBlocks = math.min(_leadingBlocks, _positional.length);
    var trailingBlocks = math.max(_trailingBlocks - _named.length, 0);
    var rule = PositionalRule(_blockRule, leadingBlocks, trailingBlocks);
    _visitArguments(visitor, _positional, rule);

    return rule;
  }

  /// Writes the named arguments, if any.
  void _visitNamed(SourceVisitor visitor, PositionalRule? positionalRule) {
    if (_named.isEmpty) return;

    // Only count the blocks in the named rule.
    var leadingBlocks = math.max(_leadingBlocks - _positional.length, 0);
    var trailingBlocks = math.min(_trailingBlocks, _named.length);
    var namedRule = NamedRule(_blockRule, leadingBlocks, trailingBlocks);

    // Let the positional args force the named ones to split.
    if (positionalRule != null) {
      positionalRule.setNamedArgsRule(namedRule);
    }

    _visitArguments(visitor, _named, namedRule);
  }

  void _visitArguments(
      SourceVisitor visitor, List<Expression> arguments, ArgumentRule rule) {
    visitor.builder.startRule(rule);

    // Split before the first argument.
    _previousSplit =
        visitor.builder.split(space: arguments.first != _allArguments.first);
    rule.beforeArgument(_previousSplit);

    // Try to not split the positional arguments.
    if (arguments == _positional) {
      visitor.builder.startSpan(Cost.positionalArguments);
    }

    for (var argument in arguments) {
      _visitArgument(visitor, rule, argument);

      // Write the split.
      if (argument != arguments.last) {
        _previousSplit = visitor.split();
        rule.beforeArgument(_previousSplit);
      }
    }

    if (arguments == _positional) visitor.builder.endSpan();

    visitor.builder.endRule();
  }

  void _visitArgument(
      SourceVisitor visitor, ArgumentRule rule, Expression argument) {
    // If we're about to write a block argument, handle it specially.
    var argumentBlock = _blocks[argument];
    if (argumentBlock != null) {
      rule.disableSplitOnInnerRules();

      // Tell it to use the rule we've already created.
      visitor.beforeBlock(argumentBlock, blockRule!, previousSplit);
    } else if (_allArguments.length > 1) {
      // Edge case: Only bump the nesting if there are multiple arguments. This
      // lets us avoid spurious indentation in cases like:
      //
      //     function(function(() {
      //       body;
      //     }));
      visitor.builder.startBlockArgumentNesting();
    } else if (argument is! NamedExpression) {
      // Edge case: Likewise, don't force the argument to split if there is
      // only a single positional one, like:
      //
      //     outer(inner(
      //         longArgument));
      rule.disableSplitOnInnerRules();
    }

    if (argument is NamedExpression) {
      visitor.visitNamedArgument(argument, rule as NamedRule);
    } else {
      visitor.visit(argument);
    }

    if (argumentBlock != null) {
      rule.enableSplitOnInnerRules();
    } else if (_allArguments.length > 1) {
      visitor.builder.endBlockArgumentNesting();
    } else if (argument is! NamedExpression) {
      rule.enableSplitOnInnerRules();
    }

    // Write the following comma.
    if (visitor.hasCommaAfter(argument)) {
      visitor.token(argument.endToken.next);
    }
  }

  /// If [expression] can be formatted as a block, returns the token that opens
  /// the block, such as a collection's bracket.
  ///
  /// Block-formatted arguments can get special indentation to make them look
  /// more statement-like.
  static Token? _blockToken(Expression expression) {
    if (expression is NamedExpression) {
      expression = expression.expression;
    }

    // TODO(rnystrom): Should we step into parenthesized expressions?

    if (expression is ListLiteral) return expression.leftBracket;
    if (expression is SetOrMapLiteral) return expression.leftBracket;
    if (expression is SingleStringLiteral && expression.isMultiline) {
      return expression.beginToken;
    }

    // Not a collection literal.
    return null;
  }
}
