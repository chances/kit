#pragma once

#include "tokens.h"
#include "../ast/span.h"

Maybe(Token);

typedef struct {
  size_t length;
  Token* tokens;
  bool errored;
} TokenList;

#define isAtEnd(str, pos) (pos >= str.length)
#define isRN_EOL(str, pos) (str.cString[pos] == '\r' && str.cString[pos+1] == '\n')
#define isEOL(str, pos) (str.cString[pos] == '\n' || str.cString[pos] == '\r' || isRN_EOL(str, pos))
#define lexError(str, pos, c) {\
  Span _errSpan = posToSpan(str, pos, pos);\
  fprintf(stderr, "Error: %d:%d Unexpected character '%c'\n", _errSpan.start.line, _errSpan.start.column, c);\
}

int scanToken(String source, size_t pos, MaybeOf(Token)* t);

/// Attempt to tokenize the given `source` as an array of `tokens`, an out parameter.
bool tokenize(String source, TokenList* tokenList) {
  assert(tokenList == NULL);
  size_t capacity = 7;
  tokenList = malloc(sizeof(TokenList));
  tokenList->length = 0;
  tokenList->tokens = calloc(capacity, sizeof(Token));

  size_t start = 0;
  size_t current = 0;

  while(!isAtEnd(source, current)) {
    start = current;
    MaybeOf(Token) t = nothing(Token);
    // Skip whitespace
    while (isblank(source.cString[current]) || isEOL(source, current)) {
      start = current += isRN_EOL(source, current) ? 2 : 1;
    }
    current += scanToken(source, start, &t);
    if (isNothing(t)) {
      lexError(source, start, source.cString[start]);
      tokenList->errored = true;
      continue;
    }

    // Append the token and, if necessary, resize and swap the the vector of Tokens
    if (capacity < tokenList->length + 1) {
      Token* _newList = calloc(capacity += 7, sizeof(Token));
      Token* _oldList = tokenList->tokens;
      memcpy(_newList, _oldList, tokenList->length * sizeof(Token));
      tokenList->tokens = _newList;
      free(_oldList);
    }
    assert(!isNothing(t));
    tokenList->tokens[tokenList->length] = t.value;
    tokenList->length += 1;
  }

  return false;
}

#include <ctype.h>

#define consume() source.cString[(pos += 1) - 1]
// See https://stackoverflow.com/a/7937139/1363247
struct peek { size_t offset; };
#define peek(...) source.cString[pos + ((struct peek){.offset = 0, __VA_ARGS__}).offset]
#define match(expected) isAtEnd(source, pos) ? false : (peek(.offset=1) == expected ? (pos += 1, true) : false)
#define tok(typ) (Token) {typ, posToSpan(source, start, pos), NULL}

int scanToken(String source, size_t pos, MaybeOf(Token)* t) {
  size_t start = pos;

  // Single character tokens
  char c = consume();
  switch (c) {
    // Syntactic Elements
    case '(': *t = just(Token, tok(ParenOpen)); break;
    case ')': *t = just(Token, tok(ParenClose)); break;
    case '{': *t = just(Token, tok(CurlyBraceOpen)); break;
    case '}': *t = just(Token, tok(CurlyBraceClose)); break;
    case '[': *t = just(Token, tok(SquareBraceOpen)); break;
    case ']': *t = just(Token, tok(SquareBraceClose)); break;
    case ',': *t = just(Token, tok(Comma)); break;
    case ':': *t = just(Token, tok(Colon)); break;
    case ';': *t = just(Token, tok(Semicolon)); break;
    case '.': {
      TokenClass class = Dot;
      if (match('*')) class = WildcardSuffix;
      else if ((match('.') && match('.'))) class = TripleDot;
      else if ((match('*') && match('*'))) class = DoubleWildcardSuffix;
      *t = just(Token, tok(class));
      break;
    }
    case '#':
      *t = just(Token, tok(match('[') ? MetaOpen : Hash));
      break;
    case '$': *t = just(Token, tok(Dollar)); break;
    case '?': *t = just(Token, tok(Question)); break;
    case '_': *t = just(Token, tok(Underscore)); break;
    // Operators
    case '=': {
      *t = just(Token, tok(match('>') ? Arrow : AssignOp));
      if (t->value.type == AssignOp) {
        t->value.data = malloc(sizeof(AssignOpData));
        AssignOpData* data = (AssignOpData*)t->value.data;
        *data = (AssignOpData) {Assign};
      }
      break;
    }
  }
  return pos - start;
}
