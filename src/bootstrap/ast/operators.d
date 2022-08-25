module kit.ast.operators;

enum Operator : string {
  assign = "=",
  inc = "++",
  dec = "--",
  add = "+",
  sub = "-",
  div = "/",
  mul = "*",
  mod = "%",
  eq = "==",
  neq = "!=",
  gte = ">=",
  lte = "<=",
  leftShift = "<<",
  rightShift = ">>",
  gt = ">",
  lt = "<",
  and = "&&",
  or = "||",
  bitAnd = "&",
  bitOr = "|",
  bitXor = "^",
  invert = "!",
  invertBits = "~",
  cons = "::"
}
