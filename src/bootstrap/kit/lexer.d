module kit.lexer;

import kit : Maybe, just, nothing, isNothing;
import kit.ast : Span, posToSpan;
import kit.ast.tokens;
import kit.ast.operators;
import std.typecons : Tuple;

struct LexError {
  string message;
  Span pos;
}

alias LexResult = Tuple!(bool, "errored", LexError[], "errors", Token[], "tokens");

LexResult tokenize(string input) {
  import std.ascii : isDigit, isHexDigit, isOctalDigit, isWhite;

  auto result = LexResult(false, new LexError[0], new Token[0]);
  ulong start = 0;
  ulong current = 0;

  bool isAtEnd() {
    return current >= input.length;
  }
  char advance() {
    return input[current += 1];
  }
  char peek(ulong offset = 0) {
    assert(offset >= 0);
    if (isAtEnd() || current + offset >= input.length) return '\0';
    return input[current + offset];
  }

  import std.range : back;
  import std.stdio : write, writeln;

  Maybe!Token scanToken() {
    import std.conv : to;

    bool match(string expected) {
      import std.algorithm : all, map;
      import std.range : enumerate;
      return expected.enumerate(0).map!(c => peek(c.index) == c.value).all;
    }
    ulong consume(string literal) {
      assert(match(literal));
      return current += literal.length;
    }
    Token scanBool(bool literal) {
      auto span = posToSpan(input, start, consume(literal ? "true" : "false"));
      return Token.withData(TokenClass.literalBool, span, literal);
    }
    Maybe!Token scanNumber() {
      return nothing!Token;
    }
    Maybe!Token scanString(string delimiter, bool multiline = false) {
      while (!match(delimiter) && !isAtEnd()) {
        if (!multiline && peek() == '\n') {
          result.errors ~= LexError("Unterminated string", posToSpan(input, start, current));
          return nothing!Token;
        }
        // Escaping the delimiter
        if (match("\\" ~ delimiter)) advance();
        advance();
      }

      if (isAtEnd()) {
        result.errors ~= LexError("Unterminated string", posToSpan(input, start, current));
        return nothing!Token;
      }

      // The closing delimiter
      consume(delimiter.to!string);

      // Trim the surrounding delimiters
      string value = input[start + delimiter.length .. current - delimiter.length];
      return Token.withData(TokenClass.literalString, posToSpan(input, start, current), value).just;
    }

    if (match("true")) return scanBool(true).just;
    if (match("false")) return scanBool(false).just;

    // FIXME: This shouldn't be neccesary
    if (peek(1) == '\0') {
      current += 1;
      return nothing!Token;
    }

    char c = advance();
    switch (c) {
      case '\'':
        return scanString("'");
      case '"':
        if (peek() == '"' && peek(1) == '"') return scanString("\"\"\"", true);
        else return scanString("\"");
      default:
        if (c == '-') {
          if (peek.isDigit) return scanNumber();
          else return Token.withData(TokenClass.op, posToSpan(input, start, current), Operator.sub).just;
        } else if (c.isDigit) {
          return scanNumber();
        } else if (c == 'c' && peek() == '\'') {
          // Character literal
          c = advance();
          if (c != '\\' &&  c != '\'' && c != '\r' && c != '\n' && match("'"))
            return Token.withData(TokenClass.literalChar, posToSpan(input, start, consume("'")), c).just;
          else if (c == '\\' && peek() != '\r' && peek() != '\n' && peek(1) == '\'') {
            auto token = Token.withData(TokenClass.literalChar, posToSpan(input, start, current + 1), "\\" ~ advance());
            consume("'");
            return token.just;
          }
        }
    }
    result.errors ~= LexError(
      "Unexpected character in character literal `" ~ c ~ "`", posToSpan(input, start, current)
    );
    return nothing!Token;
  }

  while (!isAtEnd()) {
    start = current;
    // Skip whitespace
    while (input[current].isWhite)
      start = current += 1;
    auto token = scanToken();
    if (!token.isNothing) {
      token.get.show.writeln;
      result.tokens ~= token.get;
    }
  }

  return result;
}
