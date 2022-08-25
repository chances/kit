module kit.ast;

struct Position {
  ulong line;
  ulong column;

  static Position zero() {
    return Position(0, 0);
  }
}

struct Span {
  string file;
  Position start;
  Position end;
}

enum noPos = Span(null, Position.zero, Position.zero);

Position posToPosition(string source, ulong pos) {
  Position position;

  ulong line = 1;
  ulong col = 0;
  for (ulong i = 0; i <= pos; i += 1) {
    if (source[i] == '\n') {
      line++;
      col = 0;
    }
    else col += 1;
  }
  position.line = line;
  position.column = col;

  return position;
}

Span posToSpan(string source, ulong startPos, ulong endPos) {
  auto start = posToPosition(source, startPos);
  auto end = posToPosition(source, endPos);
  return Span(null, start, end);
}
