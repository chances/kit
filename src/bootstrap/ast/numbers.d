module kit.ast.numbers;

import std.traits : EnumMembers;

import kit : Maybe, just, nothing;

enum NumSpec : string {
  cChar   = "c",
  cInt    = "i",
  cSize   = "s",
  uInt8   = "u8",
  uInt16  = "u16",
  uInt32  = "u32",
  uInt64  = "u64",
  int8    = "i8",
  int16   = "i16",
  int32   = "i32",
  int64   = "i64",
  float32 = "f32",
  float64 = "f64"
}

struct Number(T) {
  T value;
  Maybe!NumSpec type;
}

private static numSpecs = [EnumMembers!NumSpec];

const(Maybe!NumSpec) numSuffix(string input) {
  foreach(numSpec; numSpecs) if (input == numSpec) return just(numSpec);
  return nothing!NumSpec;
  assert(0, "Unrecognized number suffix: " ~ input);
}

string show(NumSpec numSpec) {
  switch (numSpec) {
    case NumSpec.cChar: return "Char";
    case NumSpec.cInt: return "Int";
    case NumSpec.cSize: return "Size";
    case NumSpec.int8: return "Int8";
    case NumSpec.int16: return "Int16";
    case NumSpec.int32: return "Int32";
    case NumSpec.int64: return "Int64";
    case NumSpec.uInt8: return "Uint8";
    case NumSpec.uInt16: return "Uint16";
    case NumSpec.uInt32: return "Uint32";
    case NumSpec.uInt64: return "Uint64";
    case NumSpec.float32: return "Float32";
    case NumSpec.float64: return "Float64";
    default: assert(0, "Unreachable");
  }
}
