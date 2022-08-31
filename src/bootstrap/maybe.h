#pragma once

#include <stdbool.h>

typedef struct {
  bool isNull;
} Maybe_t;

/// Declare an optional type derived from `T`.
#define Maybe(T) typedef struct { Maybe_t _state; T value; } Maybe_##T;

/// The type of an optional type derived from `T`.
#define MaybeOf(T) Maybe_##T

#define nothing(T) (MaybeOf(T)) { (Maybe_t) { true }, (T) {0} }

#define just(T, value) (MaybeOf(T)) { (Maybe_t) { false }, value }

/// Whether the given optional value is nothing.
#define isNothing(maybe) (maybe)._state.isNull
