module kit;

import std.sumtype;
import std.typecons : Nullable, nullable;

import kit.lexer : LexError;
import kit.parser : ParseError;

struct Document {
  string file;
  string contents;
  size_t lineLength;
}

Document document(string[] lines, string fileName) {
  import std.algorithm : joiner;
  import std.array : array;
  import std.conv : to;

  return Document(fileName, lines.joiner("\n").array.to!string, lines.length);
}

alias KitError = SumType!(LexError, ParseError);

alias Maybe = Nullable;

Maybe!T nothing(T)() {
  return Nullable!T.init;
}

Maybe!T just(T)(T value) {
  return value.nullable;
}

@property bool isNothing(T)(Maybe!T optional) {
  return optional.isNull;
}

@property T value(T)(Maybe!T optional) {
  assert(!optional.isNull);
  return optional.get;
}
