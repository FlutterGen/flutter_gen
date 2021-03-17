// Copyright (c) 2014, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/standard_ast_factory.dart';
import 'package:analyzer/dart/ast/token.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/src/generated/source.dart';

import 'argument_list_visitor.dart';
import 'call_chain_visitor.dart';
import 'chunk.dart';
import 'chunk_builder.dart';
import 'dart_formatter.dart';
import 'rule/argument.dart';
import 'rule/combinator.dart';
import 'rule/metadata.dart';
import 'rule/rule.dart';
import 'rule/type_argument.dart';
import 'source_code.dart';
import 'style_fix.dart';
import 'whitespace.dart';

/// Visits every token of the AST and passes all of the relevant bits to a
/// [ChunkBuilder].
class SourceVisitor extends ThrowingAstVisitor {
  /// Returns `true` if [node] is a method invocation that looks like it might
  /// be a static method or constructor call without a `new` keyword.
  ///
  /// With optional `new`, we can no longer reliably identify constructor calls
  /// statically, but we still don't want to mix named constructor calls into
  /// a call chain like:
  ///
  ///     Iterable
  ///         .generate(...)
  ///         .toList();
  ///
  /// And instead prefer:
  ///
  ///     Iterable.generate(...)
  ///         .toList();
  ///
  /// So we try to identify these calls syntactically. The heuristic we use is
  /// that a target that's a capitalized name (possibly prefixed by "_") is
  /// assumed to be a class.
  ///
  /// This has the effect of also keeping static method calls with the class,
  /// but that tends to look pretty good too, and is certainly better than
  /// splitting up named constructors.
  static bool looksLikeStaticCall(Expression node) {
    if (node is! MethodInvocation) return false;
    if (node.target == null) return false;

    // A prefixed unnamed constructor call:
    //
    //     prefix.Foo();
    if (node.target is SimpleIdentifier &&
        _looksLikeClassName(node.methodName.name)) {
      return true;
    }

    // A prefixed or unprefixed named constructor call:
    //
    //     Foo.named();
    //     prefix.Foo.named();
    var target = node.target;
    if (target is PrefixedIdentifier) target = target.identifier;

    return target is SimpleIdentifier && _looksLikeClassName(target.name);
  }

  /// Whether [name] appears to be a type name.
  ///
  /// Type names begin with a capital letter and contain at least one lowercase
  /// letter (so that we can distinguish them from SCREAMING_CAPS constants).
  static bool _looksLikeClassName(String name) {
    // Handle the weird lowercase corelib names.
    if (name == 'bool') return true;
    if (name == 'double') return true;
    if (name == 'int') return true;
    if (name == 'num') return true;

    // TODO(rnystrom): A simpler implementation is to test against the regex
    // "_?[A-Z].*?[a-z]". However, that currently has much worse performance on
    // AOT: https://github.com/dart-lang/sdk/issues/37785.
    const underscore = 95;
    const capitalA = 65;
    const capitalZ = 90;
    const lowerA = 97;
    const lowerZ = 122;

    var start = 0;
    var firstChar = name.codeUnitAt(start++);

    // It can be private.
    if (firstChar == underscore) {
      if (name.length == 1) return false;
      firstChar = name.codeUnitAt(start++);
    }

    // It must start with a capital letter.
    if (firstChar < capitalA || firstChar > capitalZ) return false;

    // And have at least one lowercase letter in it. Otherwise it could be a
    // SCREAMING_CAPS constant.
    for (var i = start; i < name.length; i++) {
      var char = name.codeUnitAt(i);
      if (char >= lowerA && char <= lowerZ) return true;
    }

    return false;
  }

  static bool _isControlFlowElement(AstNode node) =>
      node is IfElement || node is ForElement;

  /// The builder for the block that is currently being visited.
  ChunkBuilder builder;

  final DartFormatter _formatter;

  /// Cached line info for calculating blank lines.
  final LineInfo _lineInfo;

  /// The source being formatted.
  final SourceCode _source;

  /// `true` if the visitor has written past the beginning of the selection in
  /// the original source text.
  bool _passedSelectionStart = false;

  /// `true` if the visitor has written past the end of the selection in the
  /// original source text.
  bool _passedSelectionEnd = false;

  /// The character offset of the end of the selection, if there is a selection.
  ///
  /// This is calculated and cached by [_findSelectionEnd].
  int? _selectionEnd;

  /// How many levels deep inside a constant context the visitor currently is.
  int _constNesting = 0;

  /// Whether we are currently fixing a typedef declaration.
  ///
  /// Set to `true` while traversing the parameters of a typedef being converted
  /// to the new syntax. The new syntax does not allow `int foo()` as a
  /// parameter declaration, so it needs to be converted to `int Function() foo`
  /// as part of the fix.
  bool _insideNewTypedefFix = false;

  /// A stack that tracks forcing nested collections to split.
  ///
  /// Each entry corresponds to a collection currently being visited and the
  /// value is whether or not it should be forced to split. Every time a
  /// collection is entered, it sets all of the existing elements to `true`
  /// then it pushes `false` for itself.
  ///
  /// When done visiting the elements, it removes its value. If it was set to
  /// `true`, we know we visited a nested collection so we force this one to
  /// split.
  final List<bool> _collectionSplits = [];

  /// The stack of current rules for handling parameter metadata.
  ///
  /// Each time a parameter (or type parameter) list is begun, a single rule
  /// for all of the metadata annotations on parameters in that list is pushed
  /// onto this stack. We reuse this rule for all annotations so that they split
  /// in unison.
  final List<MetadataRule> _metadataRules = [];

  /// The mapping for blocks that are managed by the argument list that contains
  /// them.
  ///
  /// When a block expression, such as a collection literal or a multiline
  /// string, appears inside an [ArgumentSublist], the argument list provides a
  /// rule for the body to split to ensure that all blocks split in unison. It
  /// also tracks the chunk before the argument that determines whether or not
  /// the block body is indented like an expression or a statement.
  ///
  /// Before a block argument is visited, [ArgumentSublist] binds itself to the
  /// beginning token of each block it controls. When we later visit that
  /// literal, we use the token to find that association.
  ///
  /// This mapping is also used for spread collection literals that appear
  /// inside control flow elements to ensure that when a "then" collection
  /// splits, the corresponding "else" one does too.
  final Map<Token, Rule> _blockRules = {};
  final Map<Token, Chunk> _blockPreviousChunks = {};

  /// Comments and new lines attached to tokens added here are suppressed
  /// from the output.
  final Set<Token> _suppressPrecedingCommentsAndNewLines = {};

  /// Initialize a newly created visitor to write source code representing
  /// the visited nodes to the given [writer].
  SourceVisitor(this._formatter, this._lineInfo, this._source)
      : builder = ChunkBuilder(_formatter, _source);

  /// Runs the visitor on [node], formatting its contents.
  ///
  /// Returns a [SourceCode] containing the resulting formatted source and
  /// updated selection, if any.
  ///
  /// This is the only method that should be called externally. Everything else
  /// is effectively private.
  SourceCode run(AstNode node) {
    visit(node);

    // Output trailing comments.
    writePrecedingCommentsAndNewlines(node.endToken.next!);

    assert(_constNesting == 0, 'Should have exited all const contexts.');

    // Finish writing and return the complete result.
    return builder.end();
  }

  @override
  void visitAdjacentStrings(AdjacentStrings node) {
    // We generally want to indent adjacent strings because it can be confusing
    // otherwise when they appear in a list of expressions, like:
    //
    //     [
    //       "one",
    //       "two"
    //       "three",
    //       "four"
    //     ]
    //
    // Especially when these stings are longer, it can be hard to tell that
    // "three" is a continuation of the previous argument.
    //
    // However, the indentation is distracting in argument lists that don't
    // suffer from this ambiguity:
    //
    //     test(
    //         "A very long test description..."
    //             "this indentation looks bad.", () { ... });
    //
    // To balance these, we omit the indentation when an adjacent string
    // expression is the only string in an argument list.
    var shouldNest = true;

    var parent = node.parent;
    if (parent is ArgumentList) {
      shouldNest = false;

      for (var argument in parent.arguments) {
        if (argument == node) continue;
        if (argument is StringLiteral) {
          shouldNest = true;
          break;
        }
      }
    } else if (parent is Assertion) {
      // Treat asserts like argument lists.
      shouldNest = false;
      if (parent.condition != node && parent.condition is StringLiteral) {
        shouldNest = true;
      }

      if (parent.message != node && parent.message is StringLiteral) {
        shouldNest = true;
      }
    } else if (parent is VariableDeclaration ||
        parent is AssignmentExpression &&
            parent.rightHandSide == node &&
            parent.parent is ExpressionStatement) {
      // Don't add extra indentation in a variable initializer or assignment:
      //
      //     var variable =
      //         "no extra"
      //         "indent";
      shouldNest = false;
    } else if (parent is NamedExpression || parent is ExpressionFunctionBody) {
      shouldNest = false;
    }

    builder.startSpan();
    builder.startRule();
    if (shouldNest) builder.nestExpression();
    visitNodes(node.strings, between: splitOrNewline);
    if (shouldNest) builder.unnest();
    builder.endRule();
    builder.endSpan();
  }

  @override
  void visitAnnotation(Annotation node) {
    token(node.atSign);
    visit(node.name);

    builder.nestExpression();
    visit(node.typeArguments);
    token(node.period);
    visit(node.constructorName);

    if (node.arguments != null) {
      // Metadata annotations are always const contexts.
      _constNesting++;
      visitArgumentList(node.arguments!, nestExpression: false);
      _constNesting--;
    }

    builder.unnest();
  }

  /// Visits an argument list.
  ///
  /// This is a bit complex to handle the rules for formatting positional and
  /// named arguments. The goals, in rough order of descending priority are:
  ///
  /// 1. Keep everything on the first line.
  /// 2. Keep the named arguments together on the next line.
  /// 3. Keep everything together on the second line.
  /// 4. Split between one or more positional arguments, trying to keep as many
  ///    on earlier lines as possible.
  /// 5. Split the named arguments each onto their own line.
  @override
  void visitArgumentList(ArgumentList node, {bool nestExpression = true}) {
    // Corner case: handle empty argument lists.
    if (node.arguments.isEmpty) {
      token(node.leftParenthesis);

      // If there is a comment inside the parens, do allow splitting before it.
      if (node.rightParenthesis.precedingComments != null) soloZeroSplit();

      token(node.rightParenthesis);
      return;
    }

    // If the argument list has a trailing comma, format it like a collection
    // literal where each argument goes on its own line, they are indented +2,
    // and the ")" ends up on its own line.
    if (hasCommaAfter(node.arguments.last)) {
      _visitCollectionLiteral(
          null, node.leftParenthesis, node.arguments, node.rightParenthesis);
      return;
    }

    if (nestExpression) builder.nestExpression();
    ArgumentListVisitor(this, node).visit();
    if (nestExpression) builder.unnest();
  }

  @override
  void visitAsExpression(AsExpression node) {
    builder.startSpan();
    builder.nestExpression();
    visit(node.expression);
    soloSplit();
    token(node.asOperator);
    space();
    visit(node.type);
    builder.unnest();
    builder.endSpan();
  }

  @override
  void visitAssertInitializer(AssertInitializer node) {
    token(node.assertKeyword);

    var arguments = <Expression>[node.condition];
    if (node.message != null) arguments.add(node.message!);

    // If the argument list has a trailing comma, format it like a collection
    // literal where each argument goes on its own line, they are indented +2,
    // and the ")" ends up on its own line.
    if (hasCommaAfter(arguments.last)) {
      _visitCollectionLiteral(
          null, node.leftParenthesis, arguments, node.rightParenthesis);
      return;
    }

    builder.nestExpression();
    var visitor = ArgumentListVisitor.forArguments(
        this, node.leftParenthesis, node.rightParenthesis, arguments);
    visitor.visit();
    builder.unnest();
  }

  @override
  void visitAssertStatement(AssertStatement node) {
    _simpleStatement(node, () {
      token(node.assertKeyword);

      var arguments = [node.condition];
      if (node.message != null) arguments.add(node.message!);

      // If the argument list has a trailing comma, format it like a collection
      // literal where each argument goes on its own line, they are indented +2,
      // and the ")" ends up on its own line.
      if (hasCommaAfter(arguments.last)) {
        _visitCollectionLiteral(
            null, node.leftParenthesis, arguments, node.rightParenthesis);
        return;
      }

      var visitor = ArgumentListVisitor.forArguments(
          this, node.leftParenthesis, node.rightParenthesis, arguments);
      visitor.visit();
    });
  }

  @override
  void visitAssignmentExpression(AssignmentExpression node) {
    builder.nestExpression();

    visit(node.leftHandSide);
    _visitAssignment(node.operator, node.rightHandSide);

    builder.unnest();
  }

  @override
  void visitAwaitExpression(AwaitExpression node) {
    token(node.awaitKeyword);
    space();
    visit(node.expression);
  }

  @override
  void visitBinaryExpression(BinaryExpression node) {
    builder.startSpan();

    // If a binary operator sequence appears immediately after a `=>`, don't
    // add an extra level of nesting. Instead, let the subsequent operands line
    // up with the first, as in:
    //
    //     method() =>
    //         argument &&
    //         argument &&
    //         argument;
    var isArrowBody = node.parent is ExpressionFunctionBody;
    if (!isArrowBody) builder.nestExpression();

    // Start lazily so we don't force the operator to split if a line comment
    // appears before the first operand.
    builder.startLazyRule();

    // Flatten out a tree/chain of the same precedence. If we split on this
    // precedence level, we will break all of them.
    var precedence = node.operator.type.precedence;

    @override
    void traverse(Expression e) {
      if (e is BinaryExpression && e.operator.type.precedence == precedence) {
        traverse(e.leftOperand);

        space();
        token(e.operator);

        split();
        traverse(e.rightOperand);
      } else {
        visit(e);
      }
    }

    // Blocks as operands to infix operators should always nest like regular
    // operands. (Granted, this case is exceedingly rare in real code.)
    builder.startBlockArgumentNesting();

    traverse(node);

    builder.endBlockArgumentNesting();

    if (!isArrowBody) builder.unnest();
    builder.endSpan();
    builder.endRule();
  }

  @override
  void visitBlock(Block node) {
    // Treat empty blocks specially. In most cases, they are not allowed to
    // split. However, an empty block as the then statement of an if with an
    // else is always split.
    if (_isEmptyCollection(node.statements, node.rightBracket)) {
      token(node.leftBracket);

      // Force a split when used as the then body of an if with an else:
      //
      //     if (condition) {
      //     } else ...
      if (node.parent is IfStatement) {
        var ifStatement = node.parent as IfStatement;
        if (ifStatement.elseStatement != null &&
            ifStatement.thenStatement == node) {
          newline();
        }
      }

      token(node.rightBracket);
      return;
    }

    // If the block is a function body, it may get expression-level indentation,
    // so handle it specially. Otherwise, just bump the indentation and keep it
    // in the current block.
    if (node.parent is BlockFunctionBody) {
      _startLiteralBody(node.leftBracket);
    } else {
      _beginBody(node.leftBracket);
    }

    var needsDouble = true;
    for (var statement in node.statements) {
      if (needsDouble) {
        twoNewlines();
      } else {
        oneOrTwoNewlines();
      }

      visit(statement);

      needsDouble = false;
      if (statement is FunctionDeclarationStatement) {
        // Add a blank line after non-empty block functions.
        var body = statement.functionDeclaration.functionExpression.body;
        if (body is BlockFunctionBody) {
          needsDouble = body.block.statements.isNotEmpty;
        }
      }
    }

    if (node.statements.isNotEmpty) newline();

    if (node.parent is BlockFunctionBody) {
      _endLiteralBody(node.rightBracket,
          forceSplit: node.statements.isNotEmpty);
    } else {
      _endBody(node.rightBracket);
    }
  }

  @override
  void visitBlockFunctionBody(BlockFunctionBody node) {
    // Space after the parameter list.
    space();

    // The "async" or "sync" keyword.
    token(node.keyword);

    // The "*" in "async*" or "sync*".
    token(node.star);
    if (node.keyword != null) space();

    visit(node.block);
  }

  @override
  void visitBooleanLiteral(BooleanLiteral node) {
    token(node.literal);
  }

  @override
  void visitBreakStatement(BreakStatement node) {
    _simpleStatement(node, () {
      token(node.breakKeyword);
      visit(node.label, before: space);
    });
  }

  @override
  void visitCascadeExpression(CascadeExpression node) {
    var splitIfOperandsSplit =
        node.cascadeSections.length > 1 || _isCollectionLike(node.target);

    // If the cascade sections have consistent names they can be broken
    // normally otherwise they always get their own line.
    if (splitIfOperandsSplit) {
      builder.startLazyRule(_allowInlineCascade(node) ? Rule() : Rule.hard());
    }

    // If the target of the cascade is a method call (or chain of them), we
    // treat the nesting specially. Normally, you would end up with:
    //
    //     receiver
    //           .method()
    //           .method()
    //       ..cascade()
    //       ..cascade();
    //
    // This is logical, since the method chain is an operand of the cascade
    // expression, so it's more deeply nested. But it looks wrong, so we leave
    // the method chain's nesting active until after the cascade sections to
    // force the *cascades* to be deeper because it looks better:
    //
    //     receiver
    //         .method()
    //         .method()
    //           ..cascade()
    //           ..cascade();
    if (node.target is MethodInvocation) {
      CallChainVisitor(this, node.target).visit(unnest: false);
    } else {
      visit(node.target);
    }

    builder.nestExpression(indent: Indent.cascade, now: true);
    builder.startBlockArgumentNesting();

    // If the cascade section shouldn't cause the cascade to split, end the
    // rule early so it isn't affected by it.
    if (!splitIfOperandsSplit) {
      builder.startRule(_allowInlineCascade(node) ? Rule() : Rule.hard());
    }

    zeroSplit();

    if (!splitIfOperandsSplit) {
      builder.endRule();
    }

    visitNodes(node.cascadeSections, between: zeroSplit);

    if (splitIfOperandsSplit) {
      builder.endRule();
    }

    builder.endBlockArgumentNesting();
    builder.unnest();

    if (node.target is MethodInvocation) builder.unnest();
  }

  /// Whether [expression] is a collection literal, or a call with a trailing
  /// comma in an argument list.
  ///
  /// In that case, when the expression is a target of a cascade, we don't
  /// force a split before the ".." as eagerly to avoid ugly results like:
  ///
  ///     [
  ///       1,
  ///       2,
  ///     ]..addAll(numbers);
  bool _isCollectionLike(Expression expression) {
    if (expression is ListLiteral) return false;
    if (expression is SetOrMapLiteral) return false;

    // If the target is a call with a trailing comma in the argument list,
    // treat it like a collection literal.
    ArgumentList? arguments;
    if (expression is InvocationExpression) {
      arguments = expression.argumentList;
    } else if (expression is InstanceCreationExpression) {
      arguments = expression.argumentList;
    }

    // TODO(rnystrom): Do we want to allow an invocation where the last
    // argument is a collection literal? Like:
    //
    //     foo(argument, [
    //       element
    //     ])..cascade();

    return arguments == null ||
        arguments.arguments.isEmpty ||
        !hasCommaAfter(arguments.arguments.last);
  }

  /// Whether a cascade should be allowed to be inline as opposed to one
  /// expression per line.
  bool _allowInlineCascade(CascadeExpression node) {
    // If the receiver is an expression that makes the cascade's very low
    // precedence confusing, force it to split. For example:
    //
    //     a ? b : c..d();
    //
    // Here, the cascade is applied to the result of the conditional, not "c".
    if (node.target is ConditionalExpression) return false;
    if (node.target is BinaryExpression) return false;
    if (node.target is PrefixExpression) return false;
    if (node.target is AwaitExpression) return false;

    if (node.cascadeSections.length < 2) return true;

    var name;
    // We could be more forgiving about what constitutes sections with
    // consistent names but for now we require all sections to have the same
    // method name.
    for (var expression in node.cascadeSections) {
      if (expression is MethodInvocation) {
        if (name == null) {
          name = expression.methodName.name;
        } else if (name != expression.methodName.name) {
          return false;
        }
      } else {
        return false;
      }
    }
    return true;
  }

  @override
  void visitCatchClause(CatchClause node) {
    token(node.onKeyword, after: space);
    visit(node.exceptionType);

    if (node.catchKeyword != null) {
      if (node.exceptionType != null) {
        space();
      }
      token(node.catchKeyword);
      space();
      token(node.leftParenthesis);
      visit(node.exceptionParameter);
      token(node.comma, after: space);
      visit(node.stackTraceParameter);
      token(node.rightParenthesis);
      space();
    } else {
      space();
    }
    visit(node.body);
  }

  @override
  void visitClassDeclaration(ClassDeclaration node) {
    visitMetadata(node.metadata);

    builder.nestExpression();
    modifier(node.abstractKeyword);
    token(node.classKeyword);
    space();
    visit(node.name);
    visit(node.typeParameters);
    visit(node.extendsClause);

    builder.startRule(CombinatorRule());
    visit(node.withClause);
    visit(node.implementsClause);
    builder.endRule();

    visit(node.nativeClause, before: space);
    space();

    builder.unnest();
    _beginBody(node.leftBracket);
    _visitMembers(node.members);
    _endBody(node.rightBracket);
  }

  @override
  void visitClassTypeAlias(ClassTypeAlias node) {
    visitMetadata(node.metadata);

    _simpleStatement(node, () {
      modifier(node.abstractKeyword);
      token(node.typedefKeyword);
      space();
      visit(node.name);
      visit(node.typeParameters);
      space();
      token(node.equals);
      space();

      visit(node.superclass);

      builder.startRule(CombinatorRule());
      visit(node.withClause);
      visit(node.implementsClause);
      builder.endRule();
    });
  }

  @override
  void visitComment(Comment node) => null;

  @override
  void visitCommentReference(CommentReference node) => null;

  @override
  void visitCompilationUnit(CompilationUnit node) {
    visit(node.scriptTag);

    // Put a blank line between the library tag and the other directives.
    Iterable<Directive> directives = node.directives;
    if (directives.isNotEmpty && directives.first is LibraryDirective) {
      visit(directives.first);
      twoNewlines();

      directives = directives.skip(1);
    }

    visitNodes(directives, between: oneOrTwoNewlines);

    var needsDouble = true;
    for (var declaration in node.declarations) {
      var hasClassBody = declaration is ClassDeclaration ||
          declaration is ExtensionDeclaration;

      // Add a blank line before declarations with class-like bodies.
      if (hasClassBody) needsDouble = true;

      if (needsDouble) {
        twoNewlines();
      } else {
        // Variables and arrow-bodied members can be more tightly packed if
        // the user wants to group things together.
        oneOrTwoNewlines();
      }

      visit(declaration);

      needsDouble = false;
      if (hasClassBody) {
        // Add a blank line after declarations with class-like bodies.
        needsDouble = true;
      } else if (declaration is FunctionDeclaration) {
        // Add a blank line after non-empty block functions.
        var body = declaration.functionExpression.body;
        if (body is BlockFunctionBody) {
          needsDouble = body.block.statements.isNotEmpty;
        }
      }
    }
  }

  @override
  void visitConditionalExpression(ConditionalExpression node) {
    builder.nestExpression();

    // Start lazily so we don't force the operator to split if a line comment
    // appears before the first operand. If we split after one clause in a
    // conditional, always split after both.
    builder.startLazyRule();
    visit(node.condition);

    // Push any block arguments all the way past the leading "?" and ":".
    builder.nestExpression(indent: Indent.block, now: true);
    builder.startBlockArgumentNesting();
    builder.unnest();

    builder.startSpan();

    split();
    token(node.question);
    space();
    builder.nestExpression();
    visit(node.thenExpression);
    builder.unnest();

    split();
    token(node.colon);
    space();
    visit(node.elseExpression);

    // If conditional expressions are directly nested, force them all to split.
    // This line here forces the child, which implicitly forces the surrounding
    // parent rules to split too.
    if (node.parent is ConditionalExpression) builder.forceRules();

    builder.endRule();
    builder.endSpan();
    builder.endBlockArgumentNesting();
    builder.unnest();
  }

  @override
  void visitConfiguration(Configuration node) {
    token(node.ifKeyword);
    space();
    token(node.leftParenthesis);
    visit(node.name);

    if (node.equalToken != null) {
      builder.nestExpression();
      space();
      token(node.equalToken);
      soloSplit();
      visit(node.value);
      builder.unnest();
    }

    token(node.rightParenthesis);
    space();
    visit(node.uri);
  }

  @override
  void visitConstructorDeclaration(ConstructorDeclaration node) {
    visitMetadata(node.metadata);

    modifier(node.externalKeyword);
    modifier(node.constKeyword);
    modifier(node.factoryKeyword);
    visit(node.returnType);
    token(node.period);
    visit(node.name);

    // Make the rule for the ":" span both the preceding parameter list and
    // the entire initialization list. This ensures that we split before the
    // ":" if the parameters and initialization list don't all fit on one line.
    if (node.initializers.isNotEmpty) builder.startRule();

    // If the redirecting constructor happens to wrap, we want to make sure
    // the parameter list gets more deeply indented.
    if (node.redirectedConstructor != null) builder.nestExpression();

    _visitBody(null, node.parameters, node.body, () {
      // Check for redirects or initializer lists.
      if (node.redirectedConstructor != null) {
        _visitConstructorRedirects(node);
        builder.unnest();
      } else if (node.initializers.isNotEmpty) {
        _visitConstructorInitializers(node);

        // End the rule for ":" after all of the initializers.
        builder.endRule();
      }
    });
  }

  void _visitConstructorRedirects(ConstructorDeclaration node) {
    token(node.separator /* = */, before: space);
    soloSplit();
    visitCommaSeparatedNodes(node.initializers);
    visit(node.redirectedConstructor);
  }

  void _visitConstructorInitializers(ConstructorDeclaration node) {
    var hasTrailingComma = node.parameters.parameters.isNotEmpty &&
        hasCommaAfter(node.parameters.parameters.last);

    if (hasTrailingComma) {
      // Since the ")", "])", or "})" on the preceding line doesn't take up
      // much space, it looks weird to move the ":" onto it's own line. Instead,
      // keep it and the first initializer on the current line but add enough
      // space before it to line it up with any subsequent initializers.
      //
      //     Foo(
      //       parameter,
      //     )   : field = value,
      //           super();
      space();
      if (node.initializers.length > 1) {
        _writeText(node.parameters.parameters.last.isOptional ? ' ' : '  ',
            node.separator!.offset);
      }

      // ":".
      token(node.separator);
      space();

      builder.indent(6);
    } else {
      // Shift the itself ":" forward.
      builder.indent(Indent.constructorInitializer);

      // If the parameters or initializers split, put the ":" on its own line.
      split();

      // ":".
      token(node.separator);
      space();

      // Try to line up the initializers with the first one that follows the ":":
      //
      //     Foo(notTrailing)
      //         : initializer = value,
      //           super(); // +2 from previous line.
      //
      //     Foo(
      //       trailing,
      //     ) : initializer = value,
      //         super(); // +4 from previous line.
      //
      // This doesn't work if there is a trailing comma in an optional parameter,
      // but we don't want to do a weird +5 alignment:
      //
      //     Foo({
      //       trailing,
      //     }) : initializer = value,
      //         super(); // Doesn't quite line up. :(
      builder.indent(2);
    }

    for (var i = 0; i < node.initializers.length; i++) {
      if (i > 0) {
        // Preceding comma.
        token(node.initializers[i].beginToken.previous);
        newline();
      }

      node.initializers[i].accept(this);
    }

    builder.unindent();
    if (!hasTrailingComma) builder.unindent();
  }

  @override
  void visitConstructorFieldInitializer(ConstructorFieldInitializer node) {
    builder.nestExpression();

    token(node.thisKeyword);
    token(node.period);
    visit(node.fieldName);

    _visitAssignment(node.equals, node.expression);

    builder.unnest();
  }

  @override
  void visitConstructorName(ConstructorName node) {
    visit(node.type);
    token(node.period);
    visit(node.name);
  }

  @override
  void visitContinueStatement(ContinueStatement node) {
    _simpleStatement(node, () {
      token(node.continueKeyword);
      visit(node.label, before: space);
    });
  }

  @override
  void visitDeclaredIdentifier(DeclaredIdentifier node) {
    modifier(node.keyword);
    visit(node.type, after: space);
    visit(node.identifier);
  }

  @override
  void visitDefaultFormalParameter(DefaultFormalParameter node) {
    visit(node.parameter);
    if (node.separator != null) {
      builder.startSpan();
      builder.nestExpression();

      if (_formatter.fixes.contains(StyleFix.namedDefaultSeparator)) {
        // Change the separator to "=".
        space();
        writePrecedingCommentsAndNewlines(node.separator!);
        _writeText('=', node.separator!.offset);
      } else {
        // The '=' separator is preceded by a space, ":" is not.
        if (node.separator!.type == TokenType.EQ) space();
        token(node.separator);
      }

      soloSplit(_assignmentCost(node.defaultValue!));
      visit(node.defaultValue);

      builder.unnest();
      builder.endSpan();
    }
  }

  @override
  void visitDoStatement(DoStatement node) {
    builder.nestExpression();
    token(node.doKeyword);
    space();
    builder.unnest(now: false);
    visit(node.body);

    builder.nestExpression();
    space();
    token(node.whileKeyword);
    space();
    token(node.leftParenthesis);
    soloZeroSplit();
    visit(node.condition);
    token(node.rightParenthesis);
    token(node.semicolon);
    builder.unnest();
  }

  @override
  void visitDottedName(DottedName node) {
    for (var component in node.components) {
      // Write the preceding ".".
      if (component != node.components.first) {
        token(component.beginToken.previous);
      }

      visit(component);
    }
  }

  @override
  void visitDoubleLiteral(DoubleLiteral node) {
    token(node.literal);
  }

  @override
  void visitEmptyFunctionBody(EmptyFunctionBody node) {
    token(node.semicolon);
  }

  @override
  void visitEmptyStatement(EmptyStatement node) {
    token(node.semicolon);
  }

  @override
  void visitEnumConstantDeclaration(EnumConstantDeclaration node) {
    visitMetadata(node.metadata);
    visit(node.name);
  }

  @override
  void visitEnumDeclaration(EnumDeclaration node) {
    visitMetadata(node.metadata);

    token(node.enumKeyword);
    space();
    visit(node.name);
    space();

    _beginBody(node.leftBracket, space: true);
    visitCommaSeparatedNodes(node.constants, between: splitOrTwoNewlines);

    // If there is a trailing comma, always force the constants to split.
    if (hasCommaAfter(node.constants.last)) {
      builder.forceRules();
    }

    _endBody(node.rightBracket, space: true);
  }

  @override
  void visitExportDirective(ExportDirective node) {
    _visitDirectiveMetadata(node);
    _simpleStatement(node, () {
      token(node.keyword);
      space();
      visit(node.uri);

      _visitConfigurations(node.configurations);

      builder.startRule(CombinatorRule());
      visitNodes(node.combinators);
      builder.endRule();
    });
  }

  @override
  void visitExpressionFunctionBody(ExpressionFunctionBody node) {
    // Space after the parameter list.
    space();

    // The "async" or "sync" keyword.
    token(node.keyword, after: space);

    // Try to keep the "(...) => " with the start of the body for anonymous
    // functions.
    if (_isInLambda(node)) builder.startSpan();

    token(node.functionDefinition); // "=>".

    // Split after the "=>", using the rule created before the parameters
    // by _visitBody().
    split();

    // If the body is a binary operator expression, then we want to force the
    // split at `=>` if the operators split. See visitBinaryExpression().
    if (node.expression is! BinaryExpression) builder.endRule();

    if (_isInLambda(node)) builder.endSpan();

    // If this function invocation appears in an argument list with trailing
    // comma, don't add extra nesting to preserve normal indentation.
    var isArgWithTrailingComma = false;
    var parent = node.parent;
    if (parent is FunctionExpression) {
      isArgWithTrailingComma = _isTrailingCommaArgument(parent);
    }

    if (!isArgWithTrailingComma) builder.startBlockArgumentNesting();
    builder.startSpan();
    visit(node.expression);
    builder.endSpan();
    if (!isArgWithTrailingComma) builder.endBlockArgumentNesting();

    if (node.expression is BinaryExpression) builder.endRule();

    token(node.semicolon);
  }

  /// Synthesize a token with [type] to replace the given [operator].
  ///
  /// Offset, comments, and previous/next links are all preserved.
  static Token _synthesizeToken(TokenType type, Token operator) =>
      Token(type, operator.offset, operator.precedingComments)
        ..previous = operator.previous
        ..next = operator.next;

  static Expression _realTargetOf(Expression expression) {
    if (expression is PropertyAccess) {
      return expression.realTarget;
    } else if (expression is MethodInvocation) {
      return expression.realTarget!;
    } else if (expression is IndexExpression) {
      return expression.realTarget;
    }
    throw UnimplementedError('Unhandled ${expression.runtimeType}'
        '($expression)');
  }

  /// Recursively insert [cascadeTarget] (the LHS of the cascade) into the
  /// LHS of the assignment expression that used to be the cascade's RHS.
  static Expression _insertCascadeTargetIntoExpression(
      Expression expression, Expression cascadeTarget) {
    // Base case: We've recursed as deep as possible.
    if (expression == cascadeTarget) return cascadeTarget;

    // Otherwise, copy `expression` and recurse into its LHS.
    var expressionTarget = _realTargetOf(expression);
    if (expression is PropertyAccess) {
      return astFactory.propertyAccess(
          _insertCascadeTargetIntoExpression(expressionTarget, cascadeTarget),
          // If we've reached the end, replace the `..` operator with `.`
          expressionTarget == cascadeTarget
              ? _synthesizeToken(TokenType.PERIOD, expression.operator)
              : expression.operator,
          expression.propertyName);
    } else if (expression is MethodInvocation) {
      return astFactory.methodInvocation(
          _insertCascadeTargetIntoExpression(expressionTarget, cascadeTarget),
          // If we've reached the end, replace the `..` operator with `.`
          expressionTarget == cascadeTarget
              ? _synthesizeToken(TokenType.PERIOD, expression.operator!)
              : expression.operator,
          expression.methodName,
          expression.typeArguments,
          expression.argumentList);
    } else if (expression is IndexExpression) {
      var question = expression.question;

      // A null-aware cascade treats the `?` in `?..` as part of the token, but
      // for a non-cascade index, it is a separate `?` token.
      if (expression.period?.type == TokenType.QUESTION_PERIOD_PERIOD) {
        question = _synthesizeToken(TokenType.QUESTION, expression.period!);
      }

      return astFactory.indexExpressionForTarget2(
          target: _insertCascadeTargetIntoExpression(
              expressionTarget, cascadeTarget),
          question: question,
          leftBracket: expression.leftBracket,
          index: expression.index,
          rightBracket: expression.rightBracket);
    }
    throw UnimplementedError('Unhandled ${expression.runtimeType}'
        '($expression)');
  }

  /// Parenthesize the target of the given statement's expression (assumed to
  /// be a CascadeExpression) before removing the cascade.
  void _fixCascadeByParenthesizingTarget(ExpressionStatement statement) {
    var cascade = statement.expression as CascadeExpression;
    assert(cascade.cascadeSections.length == 1);

    // Write any leading comments and whitespace immediately, as they should
    // precede the new opening parenthesis, but then prevent them from being
    // written again after the parenthesis.
    writePrecedingCommentsAndNewlines(cascade.target.beginToken);
    _suppressPrecedingCommentsAndNewLines.add(cascade.target.beginToken);

    var newTarget = astFactory.parenthesizedExpression(
        Token(TokenType.OPEN_PAREN, 0)
          ..previous = statement.beginToken.previous
          ..next = cascade.target.beginToken,
        cascade.target,
        Token(TokenType.CLOSE_PAREN, 0)
          ..previous = cascade.target.endToken
          ..next = statement.semicolon);

    // Finally, we can revisit a clone of this ExpressionStatement to actually
    // remove the cascade.
    visit(astFactory.expressionStatement(
        astFactory.cascadeExpression(newTarget, cascade.cascadeSections),
        statement.semicolon));
  }

  void _removeCascade(ExpressionStatement statement) {
    var cascade = statement.expression as CascadeExpression;
    var subexpression = cascade.cascadeSections.single;
    builder.nestExpression();

    if (subexpression is AssignmentExpression) {
      // CascadeExpression("leftHandSide", "..",
      //     AssignmentExpression("target", "=", "rightHandSide"))
      //
      // transforms to
      //
      // AssignmentExpression(
      //     PropertyAccess("leftHandSide", ".", "target"),
      //     "=",
      //     "rightHandSide")
      visit(astFactory.assignmentExpression(
          _insertCascadeTargetIntoExpression(
              subexpression.leftHandSide, cascade.target),
          subexpression.operator,
          subexpression.rightHandSide));
    } else if (subexpression is MethodInvocation ||
        subexpression is PropertyAccess) {
      // CascadeExpression("leftHandSide", "..",
      //     MethodInvocation("target", ".", "methodName", ...))
      //
      // transforms to
      //
      // MethodInvocation(
      //     PropertyAccess("leftHandSide", ".", "target"),
      //     ".",
      //     "methodName", ...)
      //
      // And similarly for PropertyAccess expressions.
      visit(_insertCascadeTargetIntoExpression(subexpression, cascade.target));
    } else {
      throw UnsupportedError(
          '--fix-single-cascade-statements: subexpression of cascade '
          '"$cascade" has unsupported type ${subexpression.runtimeType}.');
    }

    token(statement.semicolon);
    builder.unnest();
  }

  /// Remove any unnecessary single cascade from the given expression statement,
  /// which is assumed to contain a [CascadeExpression].
  ///
  /// Returns true after applying the fix, which involves visiting the nested
  /// expression. Callers must visit the nested expression themselves
  /// if-and-only-if this method returns false.
  bool _fixSingleCascadeStatement(ExpressionStatement statement) {
    var cascade = statement.expression as CascadeExpression;
    if (cascade.cascadeSections.length != 1) return false;

    var target = cascade.target;
    if (target is AsExpression ||
        target is AwaitExpression ||
        target is BinaryExpression ||
        target is ConditionalExpression ||
        target is IsExpression ||
        target is PostfixExpression ||
        target is PrefixExpression) {
      // In these cases, the cascade target needs to be parenthesized before
      // removing the cascade, otherwise the semantics will change.
      _fixCascadeByParenthesizingTarget(statement);
      return true;
    } else if (target is BooleanLiteral ||
        target is FunctionExpression ||
        target is IndexExpression ||
        target is InstanceCreationExpression ||
        target is IntegerLiteral ||
        target is ListLiteral ||
        target is NullLiteral ||
        target is MethodInvocation ||
        target is ParenthesizedExpression ||
        target is PrefixedIdentifier ||
        target is PropertyAccess ||
        target is SimpleIdentifier ||
        target is StringLiteral ||
        target is ThisExpression) {
      // OK to simply remove the cascade.
      _removeCascade(statement);
      return true;
    } else {
      // If we get here, some new syntax was added to the language that the fix
      // does not yet support. Leave it as is.
      return false;
    }
  }

  @override
  void visitExpressionStatement(ExpressionStatement node) {
    if (_formatter.fixes.contains(StyleFix.singleCascadeStatements) &&
        node.expression is CascadeExpression &&
        _fixSingleCascadeStatement(node)) {
      return;
    }

    _simpleStatement(node, () {
      visit(node.expression);
    });
  }

  @override
  void visitExtendsClause(ExtendsClause node) {
    soloSplit();
    token(node.extendsKeyword);
    space();
    visit(node.superclass);
  }

  @override
  void visitExtensionDeclaration(ExtensionDeclaration node) {
    visitMetadata(node.metadata);

    builder.nestExpression();
    token(node.extensionKeyword);

    // Don't put a space after `extension` if the extension is unnamed. That
    // way, generic unnamed extensions format like `extension<T> on ...`.
    if (node.name != null) {
      space();
      visit(node.name);
    }

    visit(node.typeParameters);
    soloSplit();
    token(node.onKeyword);
    space();
    visit(node.extendedType);
    space();
    builder.unnest();

    _beginBody(node.leftBracket);
    _visitMembers(node.members);
    _endBody(node.rightBracket);
  }

  @override
  void visitFieldDeclaration(FieldDeclaration node) {
    visitMetadata(node.metadata);

    _simpleStatement(node, () {
      modifier(node.externalKeyword);
      modifier(node.staticKeyword);
      modifier(node.abstractKeyword);
      modifier(node.covariantKeyword);
      visit(node.fields);
    });
  }

  @override
  void visitFieldFormalParameter(FieldFormalParameter node) {
    visitParameterMetadata(node.metadata, () {
      _beginFormalParameter(node);
      token(node.keyword, after: space);
      visit(node.type, after: split);
      token(node.thisKeyword);
      token(node.period);
      visit(node.identifier);
      visit(node.parameters);
      token(node.question);
      _endFormalParameter(node);
    });
  }

  @override
  void visitFormalParameterList(FormalParameterList node,
      {bool nestExpression = true}) {
    // Corner case: empty parameter lists.
    if (node.parameters.isEmpty) {
      token(node.leftParenthesis);

      // If there is a comment, do allow splitting before it.
      if (node.rightParenthesis.precedingComments != null) soloZeroSplit();

      token(node.rightParenthesis);
      return;
    }

    // If the parameter list has a trailing comma, format it like a collection
    // literal where each parameter goes on its own line, they are indented +2,
    // and the ")" ends up on its own line.
    if (hasCommaAfter(node.parameters.last)) {
      _visitTrailingCommaParameterList(node);
      return;
    }

    var requiredParams = node.parameters
        .where((param) => param is! DefaultFormalParameter)
        .toList();
    var optionalParams =
        node.parameters.whereType<DefaultFormalParameter>().toList();

    if (nestExpression) builder.nestExpression();
    token(node.leftParenthesis);

    _metadataRules.add(MetadataRule());

    var rule;
    if (requiredParams.isNotEmpty) {
      rule = PositionalRule(null, 0, 0);
      _metadataRules.last.bindPositionalRule(rule);

      builder.startRule(rule);
      if (_isInLambda(node)) {
        // Don't allow splitting before the first argument (i.e. right after
        // the bare "(" in a lambda. Instead, just stuff a null chunk in there
        // to avoid confusing the arg rule.
        rule.beforeArgument(null);
      } else {
        // Split before the first argument.
        rule.beforeArgument(zeroSplit());
      }

      builder.startSpan();

      for (var param in requiredParams) {
        visit(param);
        _writeCommaAfter(param);

        if (param != requiredParams.last) rule.beforeArgument(split());
      }

      builder.endSpan();
      builder.endRule();
    }

    if (optionalParams.isNotEmpty) {
      var namedRule = NamedRule(null, 0, 0);
      if (rule != null) rule.setNamedArgsRule(namedRule);

      _metadataRules.last.bindNamedRule(namedRule);

      builder.startRule(namedRule);

      // Make sure multi-line default values are indented.
      builder.startBlockArgumentNesting();

      namedRule.beforeArgument(builder.split(space: requiredParams.isNotEmpty));

      // "[" or "{" for optional parameters.
      token(node.leftDelimiter);

      for (var param in optionalParams) {
        visit(param);
        _writeCommaAfter(param);

        if (param != optionalParams.last) namedRule.beforeArgument(split());
      }

      builder.endBlockArgumentNesting();
      builder.endRule();

      // "]" or "}" for optional parameters.
      token(node.rightDelimiter);
    }

    _metadataRules.removeLast();

    token(node.rightParenthesis);
    if (nestExpression) builder.unnest();
  }

  @override
  void visitForElement(ForElement node) {
    // Treat a spread of a collection literal like a block in a for statement
    // and don't split after the for parts.
    var isSpreadBody = _isSpreadCollection(node.body);

    builder.nestExpression();
    token(node.awaitKeyword, after: space);
    token(node.forKeyword);
    space();
    token(node.leftParenthesis);

    // Start the body rule so that if the parts split, the body does too.
    builder.startRule();

    // The rule for the parts.
    builder.startRule();
    visit(node.forLoopParts);
    token(node.rightParenthesis);
    builder.endRule();
    builder.unnest();

    builder.nestExpression(indent: 2, now: true);

    if (isSpreadBody) {
      space();
    } else {
      split();

      // If the body is a non-spread collection or lambda, indent it.
      builder.startBlockArgumentNesting();
    }

    visit(node.body);

    if (!isSpreadBody) builder.endBlockArgumentNesting();
    builder.unnest();

    // If a control flow element is nested inside another, force the outer one
    // to split.
    if (_isControlFlowElement(node.body)) builder.forceRules();

    builder.endRule();
  }

  @override
  void visitForStatement(ForStatement node) {
    builder.nestExpression();
    token(node.awaitKeyword, after: space);
    token(node.forKeyword);
    space();
    token(node.leftParenthesis);

    builder.startRule();

    visit(node.forLoopParts);

    token(node.rightParenthesis);
    builder.endRule();
    builder.unnest();

    _visitLoopBody(node.body);
  }

  @override
  void visitForEachPartsWithDeclaration(ForEachPartsWithDeclaration node) {
    // TODO(rnystrom): The formatting logic here is slightly different from
    // how parameter metadata is handled and from how variable metadata is
    // handled. I think what it does works better in the context of a for-in
    // loop, but consider trying to unify this with one of the above.
    //
    // Metadata on class and variable declarations is *always* split:
    //
    //     @foo
    //     class Bar {}
    //
    // Metadata on parameters has some complex logic to handle multiple
    // parameters with metadata. It also indents the parameters farther than
    // the metadata when split:
    //
    //     function(
    //         @foo(long arg list...)
    //             parameter1,
    //         @foo
    //             parameter2) {}
    //
    // For for-in variables, we allow it to not split, like parameters, but
    // don't indent the variable when it does split:
    //
    //     for (
    //         @foo
    //         @bar
    //         var blah in stuff) {}
    // TODO(rnystrom): we used to call builder.startRule() here, but now we call
    // it from visitForStatement2 prior to the `(`.  Is that ok?
    visitNodes(node.loopVariable.metadata, between: split, after: split);
    visit(node.loopVariable);
    // TODO(rnystrom): we used to call builder.endRule() here, but now we call
    // it from visitForStatement2 after the `)`.  Is that ok?

    _visitForEachPartsFromIn(node);
  }

  void _visitForEachPartsFromIn(ForEachParts node) {
    soloSplit();
    token(node.inKeyword);
    space();
    visit(node.iterable);
  }

  @override
  void visitForEachPartsWithIdentifier(ForEachPartsWithIdentifier node) {
    visit(node.identifier);
    _visitForEachPartsFromIn(node);
  }

  @override
  void visitForPartsWithDeclarations(ForPartsWithDeclarations node) {
    // Nest split variables more so they aren't at the same level
    // as the rest of the loop clauses.
    builder.nestExpression();

    // Allow the variables to stay unsplit even if the clauses split.
    builder.startRule();

    var declaration = node.variables;
    visitMetadata(declaration.metadata);
    modifier(declaration.keyword);
    visit(declaration.type, after: space);

    visitCommaSeparatedNodes(declaration.variables, between: () {
      split();
    });

    builder.endRule();
    builder.unnest();

    _visitForPartsFromLeftSeparator(node);
  }

  @override
  void visitForPartsWithExpression(ForPartsWithExpression node) {
    visit(node.initialization);
    _visitForPartsFromLeftSeparator(node);
  }

  void _visitForPartsFromLeftSeparator(ForParts node) {
    token(node.leftSeparator);

    // The condition clause.
    if (node.condition != null) split();
    visit(node.condition);
    token(node.rightSeparator);

    // The update clause.
    if (node.updaters.isNotEmpty) {
      split();

      // Allow the updates to stay unsplit even if the clauses split.
      builder.startRule();

      visitCommaSeparatedNodes(node.updaters, between: split);

      builder.endRule();
    }
  }

  @override
  void visitFunctionDeclaration(FunctionDeclaration node) {
    _visitMemberDeclaration(node, node.functionExpression);
  }

  @override
  void visitFunctionDeclarationStatement(FunctionDeclarationStatement node) {
    visit(node.functionDeclaration);
  }

  @override
  void visitFunctionExpression(FunctionExpression node) {
    // Inside a function body is no longer in the surrounding const context.
    var oldConstNesting = _constNesting;
    _constNesting = 0;

    _visitBody(node.typeParameters, node.parameters, node.body);

    _constNesting = oldConstNesting;
  }

  @override
  void visitFunctionExpressionInvocation(FunctionExpressionInvocation node) {
    // Try to keep the entire invocation one line.
    builder.startSpan();
    builder.nestExpression();

    visit(node.function);
    visit(node.typeArguments);
    visitArgumentList(node.argumentList, nestExpression: false);

    builder.unnest();
    builder.endSpan();
  }

  @override
  void visitFunctionTypeAlias(FunctionTypeAlias node) {
    visitMetadata(node.metadata);

    if (_formatter.fixes.contains(StyleFix.functionTypedefs)) {
      _simpleStatement(node, () {
        // Inlined visitGenericTypeAlias
        _visitGenericTypeAliasHeader(node.typedefKeyword, node.name,
            node.typeParameters, null, (node.returnType ?? node.name).offset);

        space();

        // Recursively convert function-arguments to Function syntax.
        _insideNewTypedefFix = true;
        _visitGenericFunctionType(
            node.returnType, null, node.name.offset, null, node.parameters);
        _insideNewTypedefFix = false;
      });
      return;
    }

    _simpleStatement(node, () {
      token(node.typedefKeyword);
      space();
      visit(node.returnType, after: space);
      visit(node.name);
      visit(node.typeParameters);
      visit(node.parameters);
    });
  }

  @override
  void visitFunctionTypedFormalParameter(FunctionTypedFormalParameter node) {
    visitParameterMetadata(node.metadata, () {
      if (!_insideNewTypedefFix) {
        modifier(node.requiredKeyword);
        modifier(node.covariantKeyword);
        visit(node.returnType, after: space);
        // Try to keep the function's parameters with its name.
        builder.startSpan();
        visit(node.identifier);
        _visitParameterSignature(node.typeParameters, node.parameters);
        token(node.question);
        builder.endSpan();
      } else {
        _beginFormalParameter(node);
        _visitGenericFunctionType(node.returnType, null, node.identifier.offset,
            node.typeParameters, node.parameters);
        token(node.question);
        split();
        visit(node.identifier);
        _endFormalParameter(node);
      }
    });
  }

  @override
  void visitGenericFunctionType(GenericFunctionType node) {
    _visitGenericFunctionType(node.returnType, node.functionKeyword, null,
        node.typeParameters, node.parameters);
    token(node.question);
  }

  @override
  void visitGenericTypeAlias(GenericTypeAlias node) {
    visitNodes(node.metadata, between: newline, after: newline);
    _simpleStatement(node, () {
      _visitGenericTypeAliasHeader(node.typedefKeyword, node.name,
          node.typeParameters, node.equals, null);

      space();

      visit(node.functionType);
    });
  }

  @override
  void visitHideCombinator(HideCombinator node) {
    _visitCombinator(node.keyword, node.hiddenNames);
  }

  @override
  void visitIfElement(IfElement node) {
    // Treat a chain of if-else elements as a single unit so that we don't
    // unnecessarily indent each subsequent section of the chain.
    var ifElements = [
      for (CollectionElement? thisNode = node;
          thisNode is IfElement;
          thisNode = thisNode.elseElement)
        thisNode
    ];

    // If the body of the then or else branch is a spread of a collection
    // literal, then we want to format those collections more like blocks than
    // like standalone objects. In particular, if both the then and else branch
    // are spread collection literals, we want to ensure that they both split
    // if either splits. So this:
    //
    //     [
    //       if (condition) ...[
    //         thenClause
    //       ] else ...[
    //         elseClause
    //       ]
    //     ]
    //
    // And not something like this:
    //
    //     [
    //       if (condition) ...[
    //         thenClause
    //       ] else ...[elseClause]
    //     ]
    //
    // To do that, if we see that either clause is a spread collection, we
    // create a single rule and force both collections to use it.
    var spreadRule = Rule();
    var spreadBrackets = <CollectionElement, Token>{};
    for (var element in ifElements) {
      var spreadBracket = _findSpreadCollectionBracket(element.thenElement);
      if (spreadBracket != null) {
        spreadBrackets[element] = spreadBracket;
        beforeBlock(spreadBracket, spreadRule, null);
      }
    }

    var elseSpreadBracket =
        _findSpreadCollectionBracket(ifElements.last.elseElement);
    if (elseSpreadBracket != null) {
      spreadBrackets[ifElements.last.elseElement!] = elseSpreadBracket;
      beforeBlock(elseSpreadBracket, spreadRule, null);
    }

    void visitChild(CollectionElement element, CollectionElement child) {
      builder.nestExpression(indent: 2, now: true);

      // Treat a spread of a collection literal like a block in an if statement
      // and don't split after the "else".
      var isSpread = spreadBrackets.containsKey(element);
      if (isSpread) {
        space();
      } else {
        split();

        // If the then clause is a non-spread collection or lambda, make sure the
        // body is indented.
        builder.startBlockArgumentNesting();
      }

      visit(child);

      if (!isSpread) builder.endBlockArgumentNesting();
      builder.unnest();
    }

    // Wrap the whole thing in a single rule. If a split happens inside the
    // condition or the then clause, we want the then and else clauses to split.
    builder.startLazyRule();

    var hasInnerControlFlow = false;
    for (var element in ifElements) {
      // The condition.
      token(element.ifKeyword);
      space();
      token(element.leftParenthesis);
      visit(element.condition);
      token(element.rightParenthesis);

      visitChild(element, element.thenElement);
      if (_isControlFlowElement(element.thenElement)) {
        hasInnerControlFlow = true;
      }

      // Handle this element's "else" keyword and prepare to write the element,
      // but don't write it. It will either be the next element in [ifElements]
      // or the final else element handled after the loop.
      if (element.elseElement != null) {
        if (spreadBrackets.containsKey(element)) {
          space();
        } else {
          split();
        }

        token(element.elseKeyword);

        // If there is another if element in the chain, put a space between
        // it and this "else".
        if (element != ifElements.last) space();
      }
    }

    // Handle the final trailing else if there is one.
    var lastElse = ifElements.last.elseElement;
    if (lastElse != null) {
      visitChild(lastElse, lastElse);

      if (_isControlFlowElement(lastElse)) {
        hasInnerControlFlow = true;
      }
    }

    // If a control flow element is nested inside another, force the outer one
    // to split.
    if (hasInnerControlFlow) builder.forceRules();
    builder.endRule();
  }

  @override
  void visitIfStatement(IfStatement node) {
    builder.nestExpression();
    token(node.ifKeyword);
    space();
    token(node.leftParenthesis);
    visit(node.condition);
    token(node.rightParenthesis);
    builder.unnest();

    @override
    void visitClause(Statement clause) {
      if (clause is Block || clause is IfStatement) {
        space();
        visit(clause);
      } else {
        // Allow splitting in a statement-bodied if even though it's against
        // the style guide. Since we can't fix the code itself to follow the
        // style guide, we should at least format it as well as we can.
        builder.indent();
        builder.startRule();

        // If there is an else clause, always split before both the then and
        // else statements.
        if (node.elseStatement != null) {
          builder.writeWhitespace(Whitespace.newline);
        } else {
          builder.split(nest: false, space: true);
        }

        visit(clause);

        builder.endRule();
        builder.unindent();
      }
    }

    visitClause(node.thenStatement);

    if (node.elseStatement != null) {
      if (node.thenStatement is Block) {
        space();
      } else {
        // Corner case where an else follows a single-statement then clause.
        // This is against the style guide, but we still need to handle it. If
        // it happens, put the else on the next line.
        newline();
      }

      token(node.elseKeyword);
      visitClause(node.elseStatement!);
    }
  }

  @override
  void visitImplementsClause(ImplementsClause node) {
    _visitCombinator(node.implementsKeyword, node.interfaces);
  }

  @override
  void visitImportDirective(ImportDirective node) {
    _visitDirectiveMetadata(node);
    _simpleStatement(node, () {
      token(node.keyword);
      space();
      visit(node.uri);

      _visitConfigurations(node.configurations);

      if (node.asKeyword != null) {
        soloSplit();
        token(node.deferredKeyword, after: space);
        token(node.asKeyword);
        space();
        visit(node.prefix);
      }

      builder.startRule(CombinatorRule());
      visitNodes(node.combinators);
      builder.endRule();
    });
  }

  @override
  void visitIndexExpression(IndexExpression node) {
    builder.nestExpression();

    if (node.isCascaded) {
      token(node.period);
    } else {
      visit(node.target);
    }

    finishIndexExpression(node);

    builder.unnest();
  }

  /// Visit the index part of [node], excluding the target.
  ///
  /// Called by [CallChainVisitor] to handle index expressions in the middle of
  /// call chains.
  void finishIndexExpression(IndexExpression node) {
    if (node.target is IndexExpression) {
      // Edge case: On a chain of [] accesses, allow splitting between them.
      // Produces nicer output in cases like:
      //
      //     someJson['property']['property']['property']['property']...
      soloZeroSplit();
    }

    builder.startSpan(Cost.index);
    token(node.question);
    token(node.leftBracket);
    soloZeroSplit();
    visit(node.index);
    token(node.rightBracket);
    builder.endSpan();
  }

  @override
  void visitInstanceCreationExpression(InstanceCreationExpression node) {
    builder.startSpan();

    var includeKeyword = true;

    if (node.keyword != null) {
      if (node.keyword!.keyword == Keyword.NEW &&
          _formatter.fixes.contains(StyleFix.optionalNew)) {
        includeKeyword = false;
      } else if (node.keyword!.keyword == Keyword.CONST &&
          _formatter.fixes.contains(StyleFix.optionalConst) &&
          _constNesting > 0) {
        includeKeyword = false;
      }
    }

    if (includeKeyword) {
      token(node.keyword, after: space);
    } else {
      // Don't lose comments before the discarded keyword, if any.
      writePrecedingCommentsAndNewlines(node.keyword!);
    }

    builder.startSpan(Cost.constructorName);

    // Start the expression nesting for the argument list here, in case this
    // is a generic constructor with type arguments. If it is, we need the type
    // arguments to be nested too so they get indented past the arguments.
    builder.nestExpression();
    visit(node.constructorName);

    _startPossibleConstContext(node.keyword);

    builder.endSpan();
    visitArgumentList(node.argumentList, nestExpression: false);
    builder.endSpan();

    _endPossibleConstContext(node.keyword);

    builder.unnest();
  }

  @override
  void visitIntegerLiteral(IntegerLiteral node) {
    token(node.literal);
  }

  @override
  void visitInterpolationExpression(InterpolationExpression node) {
    builder.preventSplit();
    token(node.leftBracket);
    builder.startSpan();
    visit(node.expression);
    builder.endSpan();
    token(node.rightBracket);
    builder.endPreventSplit();
  }

  @override
  void visitInterpolationString(InterpolationString node) {
    _writeStringLiteral(node.contents);
  }

  @override
  void visitIsExpression(IsExpression node) {
    builder.startSpan();
    builder.nestExpression();
    visit(node.expression);
    soloSplit();
    token(node.isOperator);
    token(node.notOperator);
    space();
    visit(node.type);
    builder.unnest();
    builder.endSpan();
  }

  @override
  void visitLabel(Label node) {
    visit(node.label);
    token(node.colon);
  }

  @override
  void visitLabeledStatement(LabeledStatement node) {
    _visitLabels(node.labels);
    visit(node.statement);
  }

  @override
  void visitLibraryDirective(LibraryDirective node) {
    _visitDirectiveMetadata(node);
    _simpleStatement(node, () {
      token(node.keyword);
      space();
      visit(node.name);
    });
  }

  @override
  void visitLibraryIdentifier(LibraryIdentifier node) {
    visit(node.components.first);
    for (var component in node.components.skip(1)) {
      token(component.beginToken.previous); // "."
      visit(component);
    }
  }

  @override
  void visitListLiteral(ListLiteral node) {
    // Corner case: Splitting inside a list looks bad if there's only one
    // element, so make those more costly.
    var cost = node.elements.length <= 1 ? Cost.singleElementList : Cost.normal;
    _visitCollectionLiteral(
        node, node.leftBracket, node.elements, node.rightBracket, cost);
  }

  @override
  void visitMapLiteralEntry(MapLiteralEntry node) {
    builder.nestExpression();
    visit(node.key);
    token(node.separator);
    soloSplit();
    visit(node.value);
    builder.unnest();
  }

  @override
  void visitMethodDeclaration(MethodDeclaration node) {
    _visitMemberDeclaration(node, node);
  }

  @override
  void visitMethodInvocation(MethodInvocation node) {
    // If there's no target, this is a "bare" function call like "foo(1, 2)",
    // or a section in a cascade.
    //
    // If it looks like a constructor or static call, we want to keep the
    // target and method together instead of including the method in the
    // subsequent method chain. When this happens, it's important that this
    // code here has the same rules as in [visitInstanceCreationExpression].
    //
    // That ensures that the way some code is formatted is not affected by the
    // presence or absence of `new`/`const`. In particular, it means that if
    // they run `dartfmt --fix`, and then run `dartfmt` *again*, the second run
    // will not produce any additional changes.
    if (node.target == null || looksLikeStaticCall(node)) {
      // Try to keep the entire method invocation one line.
      builder.nestExpression();
      builder.startSpan();

      if (node.target != null) {
        builder.startSpan(Cost.constructorName);
        visit(node.target);
        soloZeroSplit();
      }

      // If target is null, this will be `..` for a cascade.
      token(node.operator);
      visit(node.methodName);

      if (node.target != null) builder.endSpan();

      // TODO(rnystrom): Currently, there are no constraints between a generic
      // method's type arguments and arguments. That can lead to some funny
      // splitting like:
      //
      //     method<VeryLongType,
      //             AnotherTypeArgument>(argument,
      //         argument, argument, argument);
      //
      // The indentation is fine, but splitting in the middle of each argument
      // list looks kind of strange. If this ends up happening in real world
      // code, consider putting a constraint between them.
      builder.nestExpression();
      visit(node.typeArguments);
      visitArgumentList(node.argumentList, nestExpression: false);
      builder.unnest();

      builder.endSpan();
      builder.unnest();
      return;
    }

    CallChainVisitor(this, node).visit();
  }

  @override
  void visitMixinDeclaration(MixinDeclaration node) {
    visitMetadata(node.metadata);

    builder.nestExpression();
    token(node.mixinKeyword);
    space();
    visit(node.name);
    visit(node.typeParameters);

    // If there is only a single superclass constraint, format it like an
    // "extends" in a class.
    var onClause = node.onClause;
    if (onClause != null && onClause.superclassConstraints.length == 1) {
      soloSplit();
      token(onClause.onKeyword);
      space();
      visit(onClause.superclassConstraints.single);
    }

    builder.startRule(CombinatorRule());

    // If there are multiple superclass constraints, format them like the
    // "implements" clause.
    if (onClause != null && onClause.superclassConstraints.length > 1) {
      visit(onClause);
    }

    visit(node.implementsClause);
    builder.endRule();

    space();

    builder.unnest();
    _beginBody(node.leftBracket);
    _visitMembers(node.members);
    _endBody(node.rightBracket);
  }

  @override
  void visitNamedExpression(NamedExpression node) {
    visitNamedArgument(node);
  }

  @override
  void visitNativeClause(NativeClause node) {
    token(node.nativeKeyword);
    visit(node.name, before: space);
  }

  @override
  void visitNativeFunctionBody(NativeFunctionBody node) {
    _simpleStatement(node, () {
      builder.nestExpression(now: true);
      soloSplit();
      token(node.nativeKeyword);
      visit(node.stringLiteral, before: space);
      builder.unnest();
    });
  }

  @override
  void visitNullLiteral(NullLiteral node) {
    token(node.literal);
  }

  @override
  void visitOnClause(OnClause node) {
    _visitCombinator(node.onKeyword, node.superclassConstraints);
  }

  @override
  void visitParenthesizedExpression(ParenthesizedExpression node) {
    builder.nestExpression();
    token(node.leftParenthesis);
    visit(node.expression);
    builder.unnest();
    token(node.rightParenthesis);
  }

  @override
  void visitPartDirective(PartDirective node) {
    _visitDirectiveMetadata(node);
    _simpleStatement(node, () {
      token(node.keyword);
      space();
      visit(node.uri);
    });
  }

  @override
  void visitPartOfDirective(PartOfDirective node) {
    _visitDirectiveMetadata(node);
    _simpleStatement(node, () {
      token(node.keyword);
      space();
      token(node.ofKeyword);
      space();

      // Part-of may have either a name or a URI. Only one of these will be
      // non-null. We visit both since visit() ignores null.
      visit(node.libraryName);
      visit(node.uri);
    });
  }

  @override
  void visitPostfixExpression(PostfixExpression node) {
    visit(node.operand);
    token(node.operator);
  }

  @override
  void visitPrefixedIdentifier(PrefixedIdentifier node) {
    CallChainVisitor(this, node).visit();
  }

  @override
  void visitPrefixExpression(PrefixExpression node) {
    token(node.operator);

    // Edge case: put a space after "-" if the operand is "-" or "--" so we
    // don't merge the operators.
    var operand = node.operand;
    if (operand is PrefixExpression &&
        (operand.operator.lexeme == '-' || operand.operator.lexeme == '--')) {
      space();
    }

    visit(node.operand);
  }

  @override
  void visitPropertyAccess(PropertyAccess node) {
    if (node.isCascaded) {
      token(node.operator);
      visit(node.propertyName);
      return;
    }

    CallChainVisitor(this, node).visit();
  }

  @override
  void visitRedirectingConstructorInvocation(
      RedirectingConstructorInvocation node) {
    builder.startSpan();

    token(node.thisKeyword);
    token(node.period);
    visit(node.constructorName);
    visit(node.argumentList);

    builder.endSpan();
  }

  @override
  void visitRethrowExpression(RethrowExpression node) {
    token(node.rethrowKeyword);
  }

  @override
  void visitReturnStatement(ReturnStatement node) {
    _simpleStatement(node, () {
      token(node.returnKeyword);
      visit(node.expression, before: space);
    });
  }

  @override
  void visitScriptTag(ScriptTag node) {
    // The lexeme includes the trailing newline. Strip it off since the
    // formatter ensures it gets a newline after it. Since the script tag must
    // come at the top of the file, we don't have to worry about preceding
    // comments or whitespace.
    _writeText(node.scriptTag.lexeme.trim(), node.offset);
    twoNewlines();
  }

  @override
  void visitSetOrMapLiteral(SetOrMapLiteral node) {
    _visitCollectionLiteral(
        node, node.leftBracket, node.elements, node.rightBracket);
  }

  @override
  void visitShowCombinator(ShowCombinator node) {
    _visitCombinator(node.keyword, node.shownNames);
  }

  @override
  void visitSimpleFormalParameter(SimpleFormalParameter node) {
    visitParameterMetadata(node.metadata, () {
      _beginFormalParameter(node);

      var hasType = node.type != null;
      if (_insideNewTypedefFix && !hasType) {
        // Parameters can use "var" instead of "dynamic". Since we are inserting
        // "dynamic" in that case, remove the "var".
        if (node.keyword != null) {
          if (node.keyword!.type != Keyword.VAR) {
            modifier(node.keyword);
          } else {
            // Keep any comment attached to "var".
            writePrecedingCommentsAndNewlines(node.keyword!);
          }
        }

        // In function declarations and the old typedef syntax, you can have a
        // parameter name without a type. In the new syntax, you can have a type
        // without a name. Add "dynamic" in that case.

        // Ensure comments on the identifier comes before the inserted type.
        token(node.identifier!.token, before: () {
          _writeText('dynamic', node.identifier!.offset);
          split();
        });
      } else {
        modifier(node.keyword);
        visit(node.type);

        if (hasType && node.identifier != null) split();

        visit(node.identifier);
      }

      _endFormalParameter(node);
    });
  }

  @override
  void visitSimpleIdentifier(SimpleIdentifier node) {
    token(node.token);
  }

  @override
  void visitSimpleStringLiteral(SimpleStringLiteral node) {
    _writeStringLiteral(node.literal);
  }

  @override
  void visitSpreadElement(SpreadElement node) {
    token(node.spreadOperator);
    visit(node.expression);
  }

  @override
  void visitStringInterpolation(StringInterpolation node) {
    for (var element in node.elements) {
      visit(element);
    }
  }

  @override
  void visitSuperConstructorInvocation(SuperConstructorInvocation node) {
    builder.startSpan();

    token(node.superKeyword);
    token(node.period);
    visit(node.constructorName);
    visit(node.argumentList);

    builder.endSpan();
  }

  @override
  void visitSuperExpression(SuperExpression node) {
    token(node.superKeyword);
  }

  @override
  void visitSwitchCase(SwitchCase node) {
    _visitLabels(node.labels);
    token(node.keyword);
    space();
    visit(node.expression);
    token(node.colon);

    builder.indent();
    // TODO(rnystrom): Allow inline cases?
    newline();

    visitNodes(node.statements, between: oneOrTwoNewlines);
    builder.unindent();
  }

  @override
  void visitSwitchDefault(SwitchDefault node) {
    _visitLabels(node.labels);
    token(node.keyword);
    token(node.colon);

    builder.indent();
    // TODO(rnystrom): Allow inline cases?
    newline();

    visitNodes(node.statements, between: oneOrTwoNewlines);
    builder.unindent();
  }

  @override
  void visitSwitchStatement(SwitchStatement node) {
    builder.nestExpression();
    token(node.switchKeyword);
    space();
    token(node.leftParenthesis);
    soloZeroSplit();
    visit(node.expression);
    token(node.rightParenthesis);
    space();
    token(node.leftBracket);
    builder.unnest();
    builder.indent();
    newline();

    visitNodes(node.members, between: oneOrTwoNewlines, after: newline);
    token(node.rightBracket, before: () {
      builder.unindent();
      newline();
    });
  }

  @override
  void visitSymbolLiteral(SymbolLiteral node) {
    token(node.poundSign);
    var components = node.components;
    for (var component in components) {
      // The '.' separator
      if (component.previous!.lexeme == '.') {
        token(component.previous);
      }
      token(component);
    }
  }

  @override
  void visitThisExpression(ThisExpression node) {
    token(node.thisKeyword);
  }

  @override
  void visitThrowExpression(ThrowExpression node) {
    token(node.throwKeyword);
    space();
    visit(node.expression);
  }

  @override
  void visitTopLevelVariableDeclaration(TopLevelVariableDeclaration node) {
    visitMetadata(node.metadata);

    _simpleStatement(node, () {
      modifier(node.externalKeyword);
      visit(node.variables);
    });
  }

  @override
  void visitTryStatement(TryStatement node) {
    token(node.tryKeyword);
    space();
    visit(node.body);
    visitNodes(node.catchClauses, before: space, between: space);
    token(node.finallyKeyword, before: space, after: space);
    visit(node.finallyBlock);
  }

  @override
  void visitTypeArgumentList(TypeArgumentList node) {
    _visitGenericList(node.leftBracket, node.rightBracket, node.arguments);
  }

  @override
  void visitTypeName(TypeName node) {
    visit(node.name);
    visit(node.typeArguments);
    token(node.question);
  }

  @override
  void visitTypeParameter(TypeParameter node) {
    visitParameterMetadata(node.metadata, () {
      visit(node.name);
      token(node.extendsKeyword, before: space, after: space);
      visit(node.bound);
    });
  }

  @override
  void visitTypeParameterList(TypeParameterList node) {
    _metadataRules.add(MetadataRule());

    _visitGenericList(node.leftBracket, node.rightBracket, node.typeParameters);

    _metadataRules.removeLast();
  }

  @override
  void visitVariableDeclaration(VariableDeclaration node) {
    visit(node.name);
    if (node.initializer == null) return;

    // If there are multiple variables being declared, we want to nest the
    // initializers farther so they don't line up with the variables. Bad:
    //
    //     var a =
    //         aValue,
    //         b =
    //         bValue;
    //
    // Good:
    //
    //     var a =
    //             aValue,
    //         b =
    //             bValue;
    var hasMultipleVariables =
        (node.parent as VariableDeclarationList).variables.length > 1;

    _visitAssignment(node.equals!, node.initializer!,
        nest: hasMultipleVariables);
  }

  @override
  void visitVariableDeclarationList(VariableDeclarationList node) {
    visitMetadata(node.metadata);

    // Allow but try to avoid splitting between the type and name.
    builder.startSpan();

    modifier(node.lateKeyword);
    modifier(node.keyword);
    visit(node.type, after: soloSplit);

    builder.endSpan();

    _startPossibleConstContext(node.keyword);

    // Use a single rule for all of the variables. If there are multiple
    // declarations, we will try to keep them all on one line. If that isn't
    // possible, we split after *every* declaration so that each is on its own
    // line.
    builder.startRule();

    // If there are multiple declarations split across lines, then we want any
    // blocks in the initializers to indent past the variables.
    if (node.variables.length > 1) builder.startBlockArgumentNesting();

    visitCommaSeparatedNodes(node.variables, between: split);

    if (node.variables.length > 1) builder.endBlockArgumentNesting();

    builder.endRule();
    _endPossibleConstContext(node.keyword);
  }

  @override
  void visitVariableDeclarationStatement(VariableDeclarationStatement node) {
    _simpleStatement(node, () {
      visit(node.variables);
    });
  }

  @override
  void visitWhileStatement(WhileStatement node) {
    builder.nestExpression();
    token(node.whileKeyword);
    space();
    token(node.leftParenthesis);
    soloZeroSplit();
    visit(node.condition);
    token(node.rightParenthesis);
    builder.unnest();

    _visitLoopBody(node.body);
  }

  @override
  void visitWithClause(WithClause node) {
    _visitCombinator(node.withKeyword, node.mixinTypes);
  }

  @override
  void visitYieldStatement(YieldStatement node) {
    _simpleStatement(node, () {
      token(node.yieldKeyword);
      token(node.star);
      space();
      visit(node.expression);
    });
  }

  /// Visit a [node], and if not null, optionally preceded or followed by the
  /// specified functions.
  void visit(AstNode? node, {void Function()? before, void Function()? after}) {
    if (node == null) return;

    if (before != null) before();

    node.accept(this);

    if (after != null) after();
  }

  /// Visit metadata annotations on declarations, and members.
  ///
  /// These always force the annotations to be on the previous line.
  void visitMetadata(NodeList<Annotation> metadata) {
    visitNodes(metadata, between: newline, after: newline);
  }

  /// Visit metadata annotations for a directive.
  ///
  /// Always force the annotations to be on a previous line.
  void _visitDirectiveMetadata(Directive directive) {
    // Preserve a blank line before the first directive since users (in
    // particular the test package) sometimes use that for metadata that
    // applies to the entire library and not the following directive itself.
    var isFirst =
        directive == (directive.parent as CompilationUnit).directives.first;

    visitNodes(directive.metadata,
        between: newline, after: isFirst ? oneOrTwoNewlines : newline);
  }

  /// Visits metadata annotations on parameters and type parameters.
  ///
  /// Unlike other annotations, these are allowed to stay on the same line as
  /// the parameter.
  void visitParameterMetadata(
      NodeList<Annotation> metadata, void Function() visitParameter) {
    if (metadata.isEmpty) {
      visitParameter();
      return;
    }

    // Split before all of the annotations or none.
    builder.startLazyRule(_metadataRules.last);

    visitNodes(metadata, between: split, after: () {
      // Don't nest until right before the last metadata. Ensures we only
      // indent the parameter and not any of the metadata:
      //
      //     function(
      //         @LongAnnotation
      //         @LongAnnotation
      //             indentedParameter) {}
      builder.nestExpression(now: true);
      split();
    });
    visitParameter();

    builder.unnest();

    // Wrap the rule around the parameter too. If it splits, we want to force
    // the annotations to split as well.
    builder.endRule();
  }

  /// Visits [node], which may be in an argument list controlled by [rule].
  ///
  /// This is called directly by [ArgumentListVisitor] so that it can pass in
  /// the surrounding named argument rule. That way, this can ensure that a
  /// split between the name and argument forces the argument list to split
  /// too.
  void visitNamedArgument(NamedExpression node, [NamedRule? rule]) {
    builder.nestExpression();
    builder.startSpan();
    visit(node.name);

    // Don't allow a split between a name and a collection. Instead, we want
    // the collection itself to split, or to split before the argument.
    if (node.expression is ListLiteral || node.expression is SetOrMapLiteral) {
      space();
    } else {
      var split = soloSplit();
      if (rule != null) split.imply(rule);
    }

    visit(node.expression);
    builder.endSpan();
    builder.unnest();
  }

  /// Visits the `=` and the following expression in any place where an `=`
  /// appears:
  ///
  /// * Assignment
  /// * Variable declaration
  /// * Constructor initialization
  ///
  /// If [nest] is true, an extra level of expression nesting is added after
  /// the "=".
  void _visitAssignment(Token equalsOperator, Expression rightHandSide,
      {bool nest = false}) {
    space();
    token(equalsOperator);

    if (nest) builder.nestExpression(now: true);

    soloSplit(_assignmentCost(rightHandSide));
    builder.startSpan();
    visit(rightHandSide);
    builder.endSpan();

    if (nest) builder.unnest();
  }

  /// Visits a type parameter or type argument list.
  void _visitGenericList(
      Token leftBracket, Token rightBracket, List<AstNode> nodes) {
    var rule = TypeArgumentRule();
    builder.startLazyRule(rule);
    builder.startSpan();
    builder.nestExpression();

    token(leftBracket);
    rule.beforeArgument(zeroSplit());

    for (var node in nodes) {
      visit(node);

      // Write the trailing comma.
      if (node != nodes.last) {
        token(node.endToken.next);
        rule.beforeArgument(split());
      }
    }

    token(rightBracket);

    builder.unnest();
    builder.endSpan();
    builder.endRule();
  }

  /// Visits a sequence of labels before a statement or switch case.
  void _visitLabels(NodeList<Label> labels) {
    visitNodes(labels, between: newline, after: newline);
  }

  /// Visits the list of members in a class or mixin declaration.
  void _visitMembers(NodeList<ClassMember> members) {
    for (var member in members) {
      visit(member);

      if (member == members.last) {
        newline();
        break;
      }

      // Add a blank line after non-empty block methods.
      var needsDouble = false;
      if (member is MethodDeclaration && member.body is BlockFunctionBody) {
        var body = member.body as BlockFunctionBody;
        needsDouble = body.block.statements.isNotEmpty;
      }

      if (needsDouble) {
        twoNewlines();
      } else {
        // Variables and arrow-bodied members can be more tightly packed if
        // the user wants to group things together.
        oneOrTwoNewlines();
      }
    }
  }

  /// Visits a top-level function or method declaration.
  ///
  /// The two AST node types are very similar but, alas, share no common
  /// interface type in analyzer, hence the dynamic typing.
  void _visitMemberDeclaration(
      /* FunctionDeclaration|MethodDeclaration */ node,
      /* FunctionExpression|MethodDeclaration */ function) {
    visitMetadata(node.metadata as NodeList<Annotation>);

    // Nest the signature in case we have to split between the return type and
    // name.
    builder.nestExpression();
    builder.startSpan();
    modifier(node.externalKeyword);
    if (node is MethodDeclaration) modifier(node.modifierKeyword);
    visit(node.returnType, after: soloSplit);
    modifier(node.propertyKeyword);
    if (node is MethodDeclaration) modifier(node.operatorKeyword);
    visit(node.name);
    builder.endSpan();

    TypeParameterList? typeParameters;
    if (node is FunctionDeclaration) {
      typeParameters = node.functionExpression.typeParameters;
    } else {
      typeParameters = (node as MethodDeclaration).typeParameters;
    }

    _visitBody(typeParameters, function.parameters, function.body, () {
      // If the body is a block, we need to exit nesting before we hit the body
      // indentation, but we do want to wrap it around the parameters.
      if (function.body is! ExpressionFunctionBody) builder.unnest();
    });

    // If it's an expression, we want to wrap the nesting around that so that
    // the body gets nested farther.
    if (function.body is ExpressionFunctionBody) builder.unnest();
  }

  /// Visit the given function [parameters] followed by its [body], printing a
  /// space before it if it's not empty.
  ///
  /// If [beforeBody] is provided, it is invoked before the body is visited.
  void _visitBody(TypeParameterList? typeParameters,
      FormalParameterList? parameters, FunctionBody body,
      [void Function()? beforeBody]) {
    // If the body is "=>", add an extra level of indentation around the
    // parameters and a rule that spans the parameters and the "=>". This
    // ensures that if the parameters wrap, they wrap more deeply than the "=>"
    // does, as in:
    //
    //     someFunction(parameter,
    //             parameter, parameter) =>
    //         "the body";
    //
    // Also, it ensures that if the parameters wrap, we split at the "=>" too
    // to avoid:
    //
    //     someFunction(parameter,
    //         parameter) => function(
    //         argument);
    //
    // This is confusing because it looks like those two lines are at the same
    // level when they are actually unrelated. Splitting at "=>" forces:
    //
    //     someFunction(parameter,
    //             parameter) =>
    //         function(
    //             argument);
    if (body is ExpressionFunctionBody) {
      builder.nestExpression();

      // This rule is ended by visitExpressionFunctionBody().
      builder.startLazyRule(Rule(Cost.arrow));
    }

    _visitParameterSignature(typeParameters, parameters);

    if (beforeBody != null) beforeBody();
    visit(body);

    if (body is ExpressionFunctionBody) builder.unnest();
  }

  /// Visits the type parameters (if any) and formal parameters of a method
  /// declaration, function declaration, or generic function type.
  void _visitParameterSignature(
      TypeParameterList? typeParameters, FormalParameterList? parameters) {
    // Start the nesting for the parameters here, so they indent past the
    // type parameters too, if any.
    builder.nestExpression();

    visit(typeParameters);
    if (parameters != null) {
      visitFormalParameterList(parameters, nestExpression: false);
    }

    builder.unnest();
  }

  /// Visits the body statement of a `for`, `for in`, or `while` loop.
  void _visitLoopBody(Statement body) {
    if (body is EmptyStatement) {
      // No space before the ";".
      visit(body);
    } else if (body is Block) {
      space();
      visit(body);
    } else {
      // Allow splitting in a statement-bodied loop even though it's against
      // the style guide. Since we can't fix the code itself to follow the
      // style guide, we should at least format it as well as we can.
      builder.indent();
      builder.startRule();

      builder.split(nest: false, space: true);
      visit(body);

      builder.endRule();
      builder.unindent();
    }
  }

  /// Visit a list of [nodes] if not null, optionally separated and/or preceded
  /// and followed by the given functions.
  void visitNodes(Iterable<AstNode> nodes,
      {void Function()? before,
      void Function()? between,
      void Function()? after}) {
    if (nodes.isEmpty) return;

    if (before != null) before();

    visit(nodes.first);
    for (var node in nodes.skip(1)) {
      if (between != null) between();
      visit(node);
    }

    if (after != null) after();
  }

  /// Visit a comma-separated list of [nodes] if not null.
  void visitCommaSeparatedNodes(Iterable<AstNode> nodes,
      {void Function()? between}) {
    if (nodes.isEmpty) return;

    between ??= space;

    var first = true;
    for (var node in nodes) {
      if (!first) between();
      first = false;

      visit(node);

      // The comma after the node.
      if (node.endToken.next!.lexeme == ',') token(node.endToken.next);
    }
  }

  /// Visits the collection literal [node] whose body starts with [leftBracket],
  /// ends with [rightBracket] and contains [elements].
  ///
  /// This is also used for argument lists with a trailing comma which are
  /// considered "collection-like". In that case, [node] is `null`.
  void _visitCollectionLiteral(TypedLiteral? node, Token leftBracket,
      Iterable<AstNode> elements, Token rightBracket,
      [int? cost]) {
    if (node != null) {
      // See if `const` should be removed.
      if (node.constKeyword != null &&
          _constNesting > 0 &&
          _formatter.fixes.contains(StyleFix.optionalConst)) {
        // Don't lose comments before the discarded keyword, if any.
        writePrecedingCommentsAndNewlines(node.constKeyword!);
      } else {
        modifier(node.constKeyword);
      }

      visit(node.typeArguments);
    }

    // Don't allow splitting in an empty collection.
    if (_isEmptyCollection(elements, rightBracket)) {
      token(leftBracket);
      token(rightBracket);
      return;
    }

    // Force all of the surrounding collections to split.
    for (var i = 0; i < _collectionSplits.length; i++) {
      _collectionSplits[i] = true;
    }

    // Add this collection to the stack.
    _collectionSplits.add(false);

    _startLiteralBody(leftBracket);
    if (node != null) _startPossibleConstContext(node.constKeyword);

    // If a collection contains a line comment, we assume it's a big complex
    // blob of data with some documented structure. In that case, the user
    // probably broke the elements into lines deliberately, so preserve those.
    var preserveNewlines = _containsLineComments(elements, rightBracket);

    var rule;
    var lineRule;
    if (preserveNewlines) {
      // Newlines are significant, so we'll explicitly write those. Elements
      // on the same line all share an argument-list-like rule that allows
      // splitting between zero, one, or all of them. This is faster in long
      // lists than using individual splits after each element.
      lineRule = TypeArgumentRule();
      builder.startLazyRule(lineRule);
    } else {
      // Newlines aren't significant, so use a hard rule to split the elements.
      // The parent chunk of the collection will handle the unsplit case, so
      // this only comes into play when the collection is split.
      rule = Rule.hard();
      builder.startRule(rule);
    }

    for (var element in elements) {
      if (element != elements.first) {
        if (preserveNewlines) {
          // See if the next element is on the next line.
          if (_endLine(element.beginToken.previous!) !=
              _startLine(element.beginToken)) {
            oneOrTwoNewlines();

            // Start a new rule for the new line.
            builder.endRule();
            lineRule = TypeArgumentRule();
            builder.startLazyRule(lineRule);
          } else {
            lineRule.beforeArgument(split());
          }
        } else {
          builder.split(nest: false, space: true);
        }
      }

      visit(element);
      _writeCommaAfter(element);
    }

    builder.endRule();

    // If there is a collection inside this one, it forces this one to split.
    var force = _collectionSplits.removeLast();

    // If the collection has a trailing comma, the user must want it to split.
    if (elements.isNotEmpty && hasCommaAfter(elements.last)) force = true;

    if (node != null) _endPossibleConstContext(node.constKeyword);
    _endLiteralBody(rightBracket, ignoredRule: rule, forceSplit: force);
  }

  /// Writes [parameters], which is assumed to have a trailing comma after the
  /// last parameter.
  ///
  /// Parameter lists with trailing commas are formatted differently from
  /// regular parameter lists. They are treated more like collection literals.
  ///
  /// We don't reuse [_visitCollectionLiteral] here because there are enough
  /// weird differences around optional parameters that it's easiest just to
  /// give them their own method.
  void _visitTrailingCommaParameterList(FormalParameterList parameters) {
    // Can't have a trailing comma if there are no parameters.
    assert(parameters.parameters.isNotEmpty);

    _metadataRules.add(MetadataRule());

    // Always split the parameters.
    builder.startRule(Rule.hard());

    token(parameters.leftParenthesis);

    // Find the parameter immediately preceding the optional parameters (if
    // there are any).
    FormalParameter? lastRequired;
    for (var i = 0; i < parameters.parameters.length; i++) {
      if (parameters.parameters[i] is DefaultFormalParameter) {
        if (i > 0) lastRequired = parameters.parameters[i - 1];
        break;
      }
    }

    // If all parameters are optional, put the "[" or "{" right after "(".
    if (parameters.parameters.first is DefaultFormalParameter) {
      token(parameters.leftDelimiter);
    }

    // Process the parameters as a separate set of chunks.
    builder = builder.startBlock(null);

    for (var parameter in parameters.parameters) {
      visit(parameter);
      _writeCommaAfter(parameter);

      // If the optional parameters start after this one, put the delimiter
      // at the end of its line.
      if (parameter == lastRequired) {
        space();
        token(parameters.leftDelimiter);
        lastRequired = null;
      }

      newline();
    }

    // Put comments before the closing ")", "]", or "}" inside the block.
    var firstDelimiter =
        parameters.rightDelimiter ?? parameters.rightParenthesis;
    writePrecedingCommentsAndNewlines(firstDelimiter);
    builder = builder.endBlock(null, forceSplit: true);
    builder.endRule();

    _metadataRules.removeLast();

    // Now write the delimiter itself.
    _writeText(firstDelimiter.lexeme, firstDelimiter.offset);
    if (firstDelimiter != parameters.rightParenthesis) {
      token(parameters.rightParenthesis);
    }
  }

  /// Begins writing a formal parameter of any kind.
  void _beginFormalParameter(FormalParameter node) {
    builder.startLazyRule(Rule(Cost.parameterType));
    builder.nestExpression();
    modifier(node.requiredKeyword);
    modifier(node.covariantKeyword);
  }

  /// Ends writing a formal parameter of any kind.
  void _endFormalParameter(FormalParameter node) {
    builder.unnest();
    builder.endRule();
  }

  /// Writes a `Function` function type.
  ///
  /// Used also by a fix, so there may not be a [functionKeyword].
  /// In that case [functionKeywordPosition] should be the source position
  /// used for the inserted "Function" text.
  void _visitGenericFunctionType(
      AstNode? returnType,
      Token? functionKeyword,
      int? functionKeywordPosition,
      TypeParameterList? typeParameters,
      FormalParameterList parameters) {
    builder.startLazyRule();
    builder.nestExpression();

    visit(returnType, after: split);
    if (functionKeyword != null) {
      token(functionKeyword);
    } else {
      _writeText('Function', functionKeywordPosition!);
    }

    builder.unnest();
    builder.endRule();
    _visitParameterSignature(typeParameters, parameters);
  }

  /// Writes the header of a new-style typedef.
  ///
  /// Also used by a fix so there may not be an [equals] token.
  /// If [equals] is `null`, then [equalsPosition] must be a
  /// position to use for the inserted text "=".
  void _visitGenericTypeAliasHeader(Token typedefKeyword, AstNode name,
      AstNode? typeParameters, Token? equals, int? equalsPosition) {
    token(typedefKeyword);
    space();

    // If the typedef's type parameters split, split after the "=" too,
    // mainly to ensure the function's type parameters and parameters get
    // end up on successive lines with the same indentation.
    builder.startRule();

    visit(name);

    visit(typeParameters);
    split();

    if (equals != null) {
      token(equals);
    } else {
      _writeText('=', equalsPosition!);
    }

    builder.endRule();
  }

  /// Whether [node] is an argument in an argument list with a trailing comma.
  bool _isTrailingCommaArgument(Expression node) {
    var parent = node.parent;
    if (parent is NamedExpression) parent = parent.parent;

    return parent is ArgumentList && hasCommaAfter(parent.arguments.last);
  }

  /// Whether [node] is a spread of a collection literal.
  bool _isSpreadCollection(AstNode node) =>
      _findSpreadCollectionBracket(node) != null;

  /// Whether the collection literal or block containing [nodes] and
  /// terminated by [rightBracket] is empty or not.
  ///
  /// An empty collection must have no elements or comments inside. Collections
  /// like that are treated specially because they cannot be split inside.
  bool _isEmptyCollection(Iterable<AstNode> nodes, Token rightBracket) =>
      nodes.isEmpty && rightBracket.precedingComments == null;

  /// If [node] is a spread of a non-empty collection literal, then this
  /// returns the token for the opening bracket of the collection, as in:
  ///
  ///     [ ...[a, list] ]
  ///     //   ^
  ///
  /// Otherwise, returns `null`.
  Token? _findSpreadCollectionBracket(AstNode? node) {
    if (node is SpreadElement) {
      var expression = node.expression;
      if (expression is ListLiteral) {
        if (!_isEmptyCollection(expression.elements, expression.rightBracket)) {
          return expression.leftBracket;
        }
      } else if (expression is SetOrMapLiteral) {
        if (!_isEmptyCollection(expression.elements, expression.rightBracket)) {
          return expression.leftBracket;
        }
      }
    }

    return null;
  }

  /// Gets the cost to split at an assignment (or `:` in the case of a named
  /// default value) with the given [rightHandSide].
  ///
  /// "Block-like" expressions (collections and cascades) bind a bit tighter
  /// because it looks better to have code like:
  ///
  ///     var list = [
  ///       element,
  ///       element,
  ///       element
  ///     ];
  ///
  ///     var builder = new SomeBuilderClass()
  ///       ..method()
  ///       ..method();
  ///
  /// over:
  ///
  ///     var list =
  ///         [element, element, element];
  ///
  ///     var builder =
  ///         new SomeBuilderClass()..method()..method();
  int _assignmentCost(Expression rightHandSide) {
    if (rightHandSide is ListLiteral) return Cost.assignBlock;
    if (rightHandSide is SetOrMapLiteral) return Cost.assignBlock;
    if (rightHandSide is CascadeExpression) return Cost.assignBlock;

    return Cost.assign;
  }

  /// Returns `true` if the collection withs [elements] delimited by
  /// [rightBracket] contains any line comments.
  ///
  /// This only looks for comments at the element boundary. Comments within an
  /// element are ignored.
  bool _containsLineComments(Iterable<AstNode> elements, Token rightBracket) {
    bool hasLineCommentBefore(token) {
      var comment = token.precedingComments;
      for (; comment != null; comment = comment.next) {
        if (comment.type == TokenType.SINGLE_LINE_COMMENT) return true;
      }

      return false;
    }

    // Look before each element.
    for (var element in elements) {
      if (hasLineCommentBefore(element.beginToken)) return true;
    }

    // Look before the closing bracket.
    return hasLineCommentBefore(rightBracket);
  }

  /// Begins writing a literal body: a collection or block-bodied function
  /// expression.
  ///
  /// Writes the delimiter and then creates the [Rule] that handles splitting
  /// the body.
  void _startLiteralBody(Token leftBracket) {
    token(leftBracket);

    // See if this literal is associated with an argument list or if element
    // that wants to handle splitting and indenting it. If not, we'll use a
    // default rule.
    var rule = _blockRules[leftBracket];
    var argumentChunk = _blockPreviousChunks[leftBracket];

    // Create a rule for whether or not to split the block contents.
    builder.startRule(rule);

    // Process the collection contents as a separate set of chunks.
    builder = builder.startBlock(argumentChunk);
  }

  /// Ends the literal body started by a call to [_startLiteralBody()].
  ///
  /// If [forceSplit] is `true`, forces the body to split. If [ignoredRule] is
  /// given, ignores that rule inside the body when determining if it should
  /// split.
  void _endLiteralBody(Token rightBracket,
      {Rule? ignoredRule, bool? forceSplit}) {
    forceSplit ??= false;

    // Put comments before the closing delimiter inside the block.
    var hasLeadingNewline = writePrecedingCommentsAndNewlines(rightBracket);

    builder = builder.endBlock(ignoredRule,
        forceSplit: hasLeadingNewline || forceSplit);

    builder.endRule();

    // Now write the delimiter itself.
    _writeText(rightBracket.lexeme, rightBracket.offset);
  }

  /// Visits a list of configurations in an import or export directive.
  void _visitConfigurations(NodeList<Configuration> configurations) {
    if (configurations.isEmpty) return;

    builder.startRule();

    for (var configuration in configurations) {
      split();
      visit(configuration);
    }

    builder.endRule();
  }

  /// Visits a "combinator".
  ///
  /// This is a [keyword] followed by a list of [nodes], with specific line
  /// splitting rules. As the name implies, this is used for [HideCombinator]
  /// and [ShowCombinator], but it also used for "with" and "implements"
  /// clauses in class declarations, which are formatted the same way.
  ///
  /// This assumes the current rule is a [CombinatorRule].
  void _visitCombinator(Token keyword, Iterable<AstNode> nodes) {
    // Allow splitting before the keyword.
    var rule = builder.rule as CombinatorRule;
    rule.addCombinator(split());

    builder.nestExpression();
    token(keyword);

    rule.addName(split());
    visitCommaSeparatedNodes(nodes, between: () => rule.addName(split()));

    builder.unnest();
  }

  /// If [keyword] is `const`, begins a new constant context.
  void _startPossibleConstContext(Token? keyword) {
    if (keyword != null && keyword.keyword == Keyword.CONST) {
      _constNesting++;
    }
  }

  /// If [keyword] is `const`, ends the current outermost constant context.
  void _endPossibleConstContext(Token? keyword) {
    if (keyword != null && keyword.keyword == Keyword.CONST) {
      _constNesting--;
    }
  }

  /// Writes the simple statement or semicolon-delimited top-level declaration.
  ///
  /// Handles nesting if a line break occurs in the statement and writes the
  /// terminating semicolon. Invokes [body] which should write statement itself.
  void _simpleStatement(AstNode node, void Function() body) {
    builder.nestExpression();
    body();

    // TODO(rnystrom): Can the analyzer move "semicolon" to some shared base
    // type?
    token((node as dynamic).semicolon);
    builder.unnest();
  }

  /// Marks the block that starts with [token] as being controlled by
  /// [rule] and following [previousChunk].
  ///
  /// When the block is visited, these will determine the indentation and
  /// splitting rule for the block. These are used for handling block-like
  /// expressions inside argument lists and spread collections inside if
  /// elements.
  void beforeBlock(Token token, Rule rule, [Chunk? previousChunk]) {
    _blockRules[token] = rule;
    if (previousChunk != null) _blockPreviousChunks[token] = previousChunk;
  }

  /// Writes the beginning of a brace-delimited body and handles indenting and
  /// starting the rule used to split the contents.
  void _beginBody(Token leftBracket, {bool space = false}) {
    token(leftBracket);

    // Indent the body.
    builder.indent();

    // Split after the bracket.
    builder.startRule();
    builder.split(isDouble: false, nest: false, space: space);
  }

  /// Finishes the body started by a call to [_beginBody].
  void _endBody(Token rightBracket, {bool space = false}) {
    token(rightBracket, before: () {
      // Split before the closing bracket character.
      builder.unindent();
      builder.split(nest: false, space: space);
    });

    builder.endRule();
  }

  /// Returns `true` if [node] is immediately contained within an anonymous
  /// [FunctionExpression].
  bool _isInLambda(AstNode node) =>
      node.parent is FunctionExpression &&
      node.parent!.parent is! FunctionDeclaration;

  /// Writes the string literal [string] to the output.
  ///
  /// Splits multiline strings into separate chunks so that the line splitter
  /// can handle them correctly.
  void _writeStringLiteral(Token string) {
    // Since we output the string literal manually, ensure any preceding
    // comments are written first.
    writePrecedingCommentsAndNewlines(string);

    // Split each line of a multiline string into separate chunks.
    var lines = string.lexeme.split(_formatter.lineEnding!);
    var offset = string.offset;

    _writeText(lines.first, offset);
    offset += lines.first.length;

    for (var line in lines.skip(1)) {
      builder.writeWhitespace(Whitespace.newlineFlushLeft);
      offset++;
      _writeText(line, offset);
      offset += line.length;
    }
  }

  /// Write the comma token following [node], if there is one.
  void _writeCommaAfter(AstNode node) {
    token(_commaAfter(node));
  }

  /// Whether there is a comma token immediately following [node].
  bool hasCommaAfter(AstNode node) => _commaAfter(node) != null;

  /// The comma token immediately following [node] if there is one, or `null`.
  Token? _commaAfter(AstNode node) {
    var next = node.endToken.next!;
    if (next.type == TokenType.COMMA) return next;

    // TODO(sdk#38990): endToken doesn't include the "?" on a nullable
    // function-typed formal, so check for that case and handle it.
    if (next.type == TokenType.QUESTION && next.next!.type == TokenType.COMMA) {
      return next.next;
    }

    return null;
  }

  /// Emit the given [modifier] if it's non null, followed by non-breaking
  /// whitespace.
  void modifier(Token? modifier) {
    token(modifier, after: space);
  }

  /// Emit a non-breaking space.
  void space() {
    builder.writeWhitespace(Whitespace.space);
  }

  /// Emit a single mandatory newline.
  void newline() {
    builder.writeWhitespace(Whitespace.newline);
  }

  /// Emit a two mandatory newlines.
  void twoNewlines() {
    builder.writeWhitespace(Whitespace.twoNewlines);
  }

  /// Allow either a single split or newline to be emitted before the next
  /// non-whitespace token based on whether a newline exists in the source
  /// between the last token and the next one.
  void splitOrNewline() {
    builder.writeWhitespace(Whitespace.splitOrNewline);
  }

  /// Allow either a single split or newline to be emitted before the next
  /// non-whitespace token based on whether a newline exists in the source
  /// between the last token and the next one.
  void splitOrTwoNewlines() {
    builder.writeWhitespace(Whitespace.splitOrTwoNewlines);
  }

  /// Allow either one or two newlines to be emitted before the next
  /// non-whitespace token based on whether more than one newline exists in the
  /// source between the last token and the next one.
  void oneOrTwoNewlines() {
    builder.writeWhitespace(Whitespace.oneOrTwoNewlines);
  }

  /// Writes a single space split owned by the current rule.
  ///
  /// Returns the chunk the split was applied to.
  Chunk split() => builder.split(space: true);

  /// Writes a zero-space split owned by the current rule.
  ///
  /// Returns the chunk the split was applied to.
  Chunk zeroSplit() => builder.split();

  /// Writes a single space split with its own rule.
  Rule soloSplit([int? cost]) {
    var rule = Rule(cost);
    builder.startRule(rule);
    split();
    builder.endRule();
    return rule;
  }

  /// Writes a zero-space split with its own rule.
  void soloZeroSplit() {
    builder.startRule();
    builder.split();
    builder.endRule();
  }

  /// Emit [token], along with any comments and formatted whitespace that comes
  /// before it.
  ///
  /// Does nothing if [token] is `null`. If [before] is given, it will be
  /// executed before the token is outout. Likewise, [after] will be called
  /// after the token is output.
  void token(Token? token, {void Function()? before, void Function()? after}) {
    if (token == null) return;

    writePrecedingCommentsAndNewlines(token);

    if (before != null) before();

    _writeText(token.lexeme, token.offset);

    if (after != null) after();
  }

  /// Writes all formatted whitespace and comments that appear before [token].
  bool writePrecedingCommentsAndNewlines(Token token) {
    Token? comment = token.precedingComments;

    // For performance, avoid calculating newlines between tokens unless
    // actually needed.
    if (comment == null) {
      if (builder.needsToPreserveNewlines) {
        builder.preserveNewlines(_startLine(token) - _endLine(token.previous!));
      }

      return false;
    }

    // If the token's comments are being moved by a fix, do not write them here.
    if (_suppressPrecedingCommentsAndNewLines.contains(token)) return false;

    var previousLine = _endLine(token.previous!);
    var tokenLine = _startLine(token);

    // Edge case: The analyzer includes the "\n" in the script tag's lexeme,
    // which confuses some of these calculations. We don't want to allow a
    // blank line between the script tag and a following comment anyway, so
    // just override the script tag's line.
    if (token.previous!.type == TokenType.SCRIPT_TAG) previousLine = tokenLine;

    var comments = <SourceComment>[];
    while (comment != null) {
      var commentLine = _startLine(comment);

      // Don't preserve newlines at the top of the file.
      if (comment == token.precedingComments &&
          token.previous!.type == TokenType.EOF) {
        previousLine = commentLine;
      }

      var text = comment.lexeme.trim();
      var linesBefore = commentLine - previousLine;
      var flushLeft = _startColumn(comment) == 1;

      if (text.startsWith('///') && !text.startsWith('////')) {
        // Line doc comments are always indented even if they were flush left.
        flushLeft = false;

        // Always add a blank line (if possible) before a doc comment block.
        if (comment == token.precedingComments) linesBefore = 2;
      }

      var sourceComment = SourceComment(text, linesBefore,
          isLineComment: comment.type == TokenType.SINGLE_LINE_COMMENT,
          flushLeft: flushLeft);

      // If this comment contains either of the selection endpoints, mark them
      // in the comment.
      var start = _getSelectionStartWithin(comment.offset, comment.length);
      if (start != null) sourceComment.startSelection(start);

      var end = _getSelectionEndWithin(comment.offset, comment.length);
      if (end != null) sourceComment.endSelection(end);

      comments.add(sourceComment);

      previousLine = _endLine(comment);
      comment = comment.next;
    }

    builder.writeComments(comments, tokenLine - previousLine, token.lexeme);

    // TODO(rnystrom): This is wrong. Consider:
    //
    // [/* inline comment */
    //     // line comment
    //     element];
    return comments.first.linesBefore > 0;
  }

  /// Write [text] to the current chunk, given that it starts at [offset] in
  /// the original source.
  ///
  /// Also outputs the selection endpoints if needed.
  void _writeText(String text, int offset) {
    builder.write(text);

    // If this text contains either of the selection endpoints, mark them in
    // the chunk.
    var start = _getSelectionStartWithin(offset, text.length);
    if (start != null) {
      builder.startSelectionFromEnd(text.length - start);
    }

    var end = _getSelectionEndWithin(offset, text.length);
    if (end != null) {
      builder.endSelectionFromEnd(text.length - end);
    }
  }

  /// Returns the number of characters past [offset] in the source where the
  /// selection start appears if it appears before `offset + length`.
  ///
  /// Returns `null` if the selection start has already been processed or is
  /// not within that range.
  int? _getSelectionStartWithin(int offset, int length) {
    // If there is no selection, do nothing.
    if (_source.selectionStart == null) return null;

    // If we've already passed it, don't consider it again.
    if (_passedSelectionStart) return null;

    var start = _source.selectionStart! - offset;

    // If it started in whitespace before this text, push it forward to the
    // beginning of the non-whitespace text.
    if (start < 0) start = 0;

    // If we haven't reached it yet, don't consider it.
    if (start >= length) return null;

    // We found it.
    _passedSelectionStart = true;

    return start;
  }

  /// Returns the number of characters past [offset] in the source where the
  /// selection endpoint appears if it appears before `offset + length`.
  ///
  /// Returns `null` if the selection endpoint has already been processed or is
  /// not within that range.
  int? _getSelectionEndWithin(int offset, int length) {
    // If there is no selection, do nothing.
    if (_source.selectionLength == null) return null;

    // If we've already passed it, don't consider it again.
    if (_passedSelectionEnd) return null;

    var end = _findSelectionEnd() - offset;

    // If it started in whitespace before this text, push it forward to the
    // beginning of the non-whitespace text.
    if (end < 0) end = 0;

    // If we haven't reached it yet, don't consider it.
    if (end > length) return null;

    if (end == length && _findSelectionEnd() == _source.selectionStart) {
      return null;
    }

    // We found it.
    _passedSelectionEnd = true;

    return end;
  }

  /// Calculates the character offset in the source text of the end of the
  /// selection.
  ///
  /// Removes any trailing whitespace from the selection.
  int _findSelectionEnd() {
    if (_selectionEnd != null) return _selectionEnd!;

    var end = _source.selectionStart! + _source.selectionLength!;

    // If the selection bumps to the end of the source, pin it there.
    if (end == _source.text.length) {
      _selectionEnd = end;
      return end;
    }

    // Trim off any trailing whitespace. We want the selection to "rubberband"
    // around the selected non-whitespace tokens since the whitespace will
    // be munged by the formatter itself.
    while (end > _source.selectionStart!) {
      // Stop if we hit anything other than space, tab, newline or carriage
      // return.
      var char = _source.text.codeUnitAt(end - 1);
      if (char != 0x20 && char != 0x09 && char != 0x0a && char != 0x0d) {
        break;
      }

      end--;
    }

    _selectionEnd = end;
    return end;
  }

  /// Gets the 1-based line number that the beginning of [token] lies on.
  int _startLine(Token token) => _lineInfo.getLocation(token.offset).lineNumber;

  /// Gets the 1-based line number that the end of [token] lies on.
  int _endLine(Token token) => _lineInfo.getLocation(token.end).lineNumber;

  /// Gets the 1-based column number that the beginning of [token] lies on.
  int _startColumn(Token token) =>
      _lineInfo.getLocation(token.offset).columnNumber;
}
