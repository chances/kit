#pragma once

#include <stdbool.h>

struct Maybe_t {
  bool isNull;
};
typedef struct Maybe_t Maybe_t;

/// Declare an optional type derived from `T`.
#define Maybe(T) struct Maybe_##T { struct Maybe_t _state; T value; }; \
typedef struct Maybe_##T Maybe_##T;

/// The type of an optional type derived from `T`.
#define MaybeOf(T) Maybe_##T

#define nothing(T) (MaybeOf(T)) { (Maybe_t) { true }, (T) {0} }

#define just(T, value) (MaybeOf(T)) { (Maybe_t) { false }, value }
