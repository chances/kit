module kit.lexer;

import kit : Maybe;
import kit.ast : Span, posToSpan;
import kit.ast.tokens;
import std.traits : EnumMembers;
import std.typecons : Tuple;

private enum lexemes = [EnumMembers!TokenClass];

struct LexError {
  string message;
  Maybe!Span pos;
}

alias LexResult = Tuple!(bool, "errored", LexError[], "errors",  Token[], "tokens");

LexResult tokenize(string input) {
  import std.ascii : isWhite;

  auto result = LexResult(false, new LexError[0], new Token[0]);
  int start = 0;
  int current = 0;

  bool isAtEnd() { return current >= input.length; }

  import std.stdio : write, writeln;

  void scanToken() {
    import std.conv : to;

    int consume(TokenClass type) {
      assert(!type.isComplexLexeme);
      string token = type;
      return current += token.length.to!int;
    }
    char peek(int offset = 0) {
      assert(offset >= 0);
      assert(current + offset < input.length);
      return input[current + offset];
    }
    bool match(string expected) {
      import std.algorithm : all, map;
      import std.range : enumerate;
      return expected.enumerate(0).map!(c => peek(c.index.to!int) == c.value).all;
    }

    foreach (token; lexemes) {
      string lexeme = token;
      if (!token.isComplexLexeme && match(lexeme)) {
        result.tokens ~= SimpleToken(token, posToSpan(input, start, consume(token))).to!Token;
        break;
      }
      // TODO: Scan complex tokens
    }
  }

  while (!isAtEnd()) {
    start = current;
    // Skip whitespace
    while (input[current].isWhite) start = current += 1;
    scanToken();
  }

  return result;
}
