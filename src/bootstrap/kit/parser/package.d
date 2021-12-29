module kit.parser;

import kit : KitError, Maybe;
import kit.ast : Span;

struct ParseError {
  /// Whether this error represents a compiler assertion failure; should always be reported.
  bool internal;
  // TODO: Support other types of errors, i.e. `Parse`, `Internal`, and `Import` error types
  string message;
  Maybe!Span pos;
}

KitError[] parseModule(string module_) {
  import kit.lexer : tokenize;
  import std.algorithm : map;
  import std.array : array;
  import std.conv : to;

  auto result = module_.tokenize;
  if (result.errored) return result.errors.map!(err => err.to!KitError).array;

  // TODO: Port a basic parser from Haskell to convert token list to an AST

  import std.algorithm : each;
  import std.stdio : writeln;
  result.tokens.each!writeln;

  return [];
}

// TODO: Add `parseFile` function ()
