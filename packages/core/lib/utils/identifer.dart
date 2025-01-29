/// Functions to deal with dart identifiers.
///
/// Including keywords from https://dart.dev/language/keywords which are split
/// into 4 categories:
///
/// 1. Contextual keywords, which have meaning only in specific places.
/// 2. Built-in identifiers.
/// 3. Limited reserved words.
/// 4. Reserved words, which can’t be identifiers.
///
library identifer;

// 1. Contextual keywords, which have meaning only in specific places. They’re
// valid identifiers everywhere.
const contextualKeywords = <String>{'async', 'hide', 'on', 'show', 'sync'};

// 2. Built-in identifiers. These keywords are valid identifiers in most
// places, but they can’t be used as class or type names, or as import
// prefixes.
const builtinKeywords = <String>{
  'abstract',
  'as',
  'base',
  'covariant',
  'deferred',
  'dynamic',
  'export',
  'extension',
  'external',
  'factory',
  'Function',
  'get',
  'implements',
  'import',
  'interface',
  'late',
  'library',
  'mixin',
  'operator',
  'part',
  'required',
  'sealed',
  'set',
  'static',
  'typedef',
};

// 3. Limited reserved words. Can’t use as an identifier in any function body
const asynchronyKeywords = <String>{'await', 'yield'};

// 4. Reserved words, which can’t be identifiers.
const reservedKeywords = <String>{
  'assert',
  'break',
  'case',
  'catch',
  'class',
  'const',
  'continue',
  'default',
  'do',
  'else',
  'enum',
  'extends',
  'false',
  'final',
  'finally',
  'for',
  'if',
  'in',
  'is',
  'new',
  'null',
  'rethrow',
  'return',
  'super',
  'switch',
  'this',
  'throw',
  'true',
  'try',
  'var',
  'void',
  'when',
  'while',
  'with',
};

/// List of keywords that can't be used as identifiers.
const invalidIdentifiers = <String>{...asynchronyKeywords, ...reservedKeywords};

/// Returns true this is a valid variable name, that is, a dart identifier which
/// is not a reserved keyword.
///
/// Identifiers can start with a letter or underscore (_), followed by any
/// combination of those characters plus digits.
///
/// See https://dart.dev/language
bool isValidVariableIdentifier(String identifer) =>
    !invalidIdentifiers.contains(identifer) && isValidIdentifier(identifer);

/// Returns true if this identifier is valid.
bool isValidIdentifier(String identifer) =>
    RegExp(r'^[A-Za-z_][A-Za-z0-9_]*$').hasMatch(identifer);

/// Converts a string to a valid dart identifier. For example, by replacing
/// invalid characters, and ensuring the string is prefixed with a letter or
/// underscore.
String convertToIdentifier(String identifer, {String prefix = 'a'}) {
  assert(isValidIdentifier(prefix));

  // The current implementation is a bit naive, but it works for now.
  // Consider replacing with a dart port of https://github.com/avian2/unidecode
  identifer = identifer.replaceAll(RegExp(r'[^A-Za-z0-9_]'), '_');
  if (!identifer.startsWith(RegExp(r'[A-Za-z]'))) {
    identifer = '$prefix$identifer';
  }
  return identifer;
}
