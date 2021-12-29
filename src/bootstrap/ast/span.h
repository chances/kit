#pragma once

#include "../maybe.h"
#include "../string.h"

struct Position {
  int line;
  int column;
};
typedef struct Position Position;

struct Span {
  String file;
  Position start;
  Position end;
};
typedef struct Span Span;

Span NoPos = { NilString, { 0, 0 }, { 0, 0 } };

Maybe(Span);

Position posToPosition(String source, int pos) {
  Position position;

  int line = 1;
  int col = 0;
  for (int i = 0; i <= pos; i += 1) {
    if (source.cString[i] == '\n') {
      line++;
      col = 0;
    }
    else col += 1;
  }
  position.line = line;
  position.column = col;

  return position;
}

Span posToSpan(String source, int startPos, int endPos) {
  Position start = posToPosition(source, startPos);
  Position end = posToPosition(source, endPos);
  return (Span) { source, start, end };
}
