#pragma once

#include <inttypes.h>
#include <stdlib.h>

#include "../maybe.h"

enum NumSpec {
  CChar,
  CInt,
  CSize,
  Int8,
  Int16,
  Int32,
  Int64,
  Uint8,
  Uint16,
  Uint32,
  Uint64,
  Float32,
  Float64
};
typedef enum NumSpec NumSpec;
Maybe(NumSpec);

float parseFloat(char* str) {
  char* end;
  return strtof(str, &end);
}

int parseInt(char* str, int base) {
  char* end;
  return strtoimax(str, &end, base);
}

MaybeOf(NumSpec) parseNumSuffix(char* suffix) {
  if (strcmp(suffix, "c") == 0) return just(NumSpec, CChar);
  else if (strcmp(suffix, "i") == 0) return just(NumSpec, CInt);
  else if (strcmp(suffix, "s") == 0) return just(NumSpec, CSize);
  else if (strcmp(suffix, "u8") == 0) return just(NumSpec, Uint8);
  else if (strcmp(suffix, "u16") == 0) return just(NumSpec, Uint16);
  else if (strcmp(suffix, "u32") == 0) return just(NumSpec, Uint32);
  else if (strcmp(suffix, "u64") == 0) return just(NumSpec, Uint64);
  else if (strcmp(suffix, "i8") == 0) return just(NumSpec, Int8);
  else if (strcmp(suffix, "i16") == 0) return just(NumSpec, Int16);
  else if (strcmp(suffix, "i32") == 0) return just(NumSpec, Int32);
  else if (strcmp(suffix, "i64") == 0) return just(NumSpec, Int64);
  else if (strcmp(suffix, "f32") == 0) return just(NumSpec, Float32);
  else if (strcmp(suffix, "f64") == 0) return just(NumSpec, Float64);
  else return nothing(NumSpec);
}

char* showNumSpec(NumSpec numSpec) {
  switch (numSpec) {
  case CChar:
    return "Char";
  case CInt:
    return "Int";
  case CSize:
    return "Size";
  case Int8:
    return "Int8";
  case Int16:
    return "Int16";
  case Int32:
    return "Int32";
  case Int64:
    return "Int64";
  case Uint8:
    return "Uint8";
  case Uint16:
    return "Uint16";
  case Uint32:
    return "Uint32";
  case Uint64:
    return "Uint64";
  case Float32:
    return "Float32";
  case Float64:
    return "Float64";
  default:
    return NULL;
  }
}
