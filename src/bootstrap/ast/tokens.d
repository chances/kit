module kit.ast.tokens;

import kit.ast : Span;
import kit.ast.numbers;
import kit.ast.operators;
import std.algorithm : joiner, map;
import std.array : array;
import std.conv : text, to;
import std.sumtype;
import std.traits : EnumMembers;
import std.typecons : Tuple;

struct SimpleToken {
  TokenClass type;
  Span span;
}

struct TokenData(T) {
  TokenClass type;
  Span span;
  T data;
}

// Tokens with data
alias LiteralChar = TokenData!char;
alias LiteralBool = TokenData!bool;
alias LiteralString = TokenData!string;
alias LiteralFloat = TokenData!(Number!string);
alias LiteralInt = TokenData!(Number!int);
alias Op = TokenData!(Tuple!(Operator, "operator"));
alias AssignOp = TokenData!(Tuple!(Operator, "operator"));
alias CustomOp = TokenData!(Tuple!(string, "operator"));
// TODO: alias Lex = TokenData!(Tuple!(string, "macro"));
alias Identifier = TokenData!(Tuple!(string, "value"));
alias InlineC = TokenData!(Tuple!(string, "source"));

alias Token = SumType!(
  SimpleToken,
  LiteralChar,
  LiteralBool,
  LiteralString,
  LiteralFloat,
  LiteralInt,
  Op,
  CustomOp,
  // TODO: Lex,
  Identifier,
  InlineC
);

enum TokenClass : string {
  metaOpen          = "#[",
  parenOpen         = "(",
  parenClose        = ")",
  curlyBraceOpen    = "{",
  curlyBraceClose   = "}",
  squareBraceOpen   = "[",
  squareBraceClose  = "]",
  comma             = ",",
  colon             = ":",
  semicolon         = ";",
  tripleDot         = "...",
  dot               = ".",
  hash              = "#",
  dollar            = "$",
  arrow             = "=>",
  functionArrow     = "->",
  question          = "?",
  underscore        = "_",
  // Wildcards
  wildcardSuffix        = ".*",
  doubleWildcardSuffix  = ".**",
  // Keywords
  keywordAbstract   = "abstract",
  keywordAs         = "as",
  keywordBreak      = "break",
  keywordConst      = "const",
  keywordContinue   = "continue",
  keywordDefault    = "default",
  keywordDefined    = "defined",
  keywordDefer      = "defer",
  keywordDo         = "do",
  keywordElse       = "else",
  keywordEmpty      = "empty",
  keywordEnum       = "enum",
  keywordExtend     = "extend",
  keywordFor        = "for",
  keywordFunction   = "function",
  keywordIf         = "if",
  keywordImplement  = "implement",
  keywordImplicit   = "implicit",
  keywordImport     = "import",
  keywordInclude    = "include",
  keywordInline     = "inline",
  keywordIn         = "in",
  keywordMacro      = "macro",
  keywordMatch      = "match",
  keywordNull       = "null",
  keywordPrivate    = "private",
  keywordPublic     = "public",
  keywordReturn     = "return",
  keywordRule       = "rule",
  keywordRules      = "rules",
  keywordSelf       = "self",
  keywordSizeof     = "sizeof",
  keywordSpecialize = "specialize",
  keywordStatic     = "static",
  keywordStruct     = "struct",
  keywordThen       = "then",
  keywordThis       = "this",
  keywordThrow      = "throw",
  keywordTokens     = "tokens",
  keywordTrait      = "trait",
  keywordTypedef    = "typedef",
  keywordUndefined  = "undefined",
  keywordUnion      = "union",
  keywordUnsafe     = "unsafe",
  keywordUsing      = "using",
  keywordVar        = "var",
  keywordWhile      = "while",
  keywordYield      = "yield",
  // Tokens with data
  literalChar     = "c'([^\\']|\\.)'",
  literalBool     = "[true;false]",
  literalString   = "__literalString",
  literalFloat    = "__literalFloat",
  literalInt      = "__literalInt",
  op              = opRegex.to!string,
  assignOp        = "[+=;-=;/=;*=;%=;&&=;||=;&=;;=;^=;<<=;>>=]",
  customOp        = "[\\*\\/\\+\\-\\^\\=\\<\\>\\!\\&\\%\\~\\@\\?\\:\\.]+",
  lex             = "[_]*[a-z][a-zA-Z0-9_]*\\!",
  lowerIdentifier = lowerIdentifierRegex.to!string,
  upperIdentifier = upperIdentifierRegex.to!string,
  macroIdentifier = macroIdentifierRegex.to!string,
  inlineC         = "```(([^`]|\\`[^`]|\\`\\`[^`]|\\n)*)```"
}

enum opRegex = "[" ~ [EnumMembers!Operator].map!(op => op.to!string).joiner(";").array ~ "]";
enum lowerIdentifierRegex = "[" ~ ["[_]*[a-z][a-zA-Z0-9_]*", "[@]([a-z][a-zA-Z0-9_]*)", "`([^`]+)`"].joiner(";").array ~ "]";
enum upperIdentifierRegex = "[" ~ ["[_]*[A-Z][a-zA-Z0-9_]*", "``(([^`]|\\`[^`])+)``"].joiner(";").array ~ "]";
enum macroIdentifierRegex = "[" ~ ["\\$([A-Za-z_][a-zA-Z0-9_]*])", "${([A-Za-z_][a-zA-Z0-9_]*)}"].joiner(";").array ~ "]";

string show(TokenClass type) {
  assert(!type.isComplexLexeme);
  string t = type;
  return t;
}

bool isComplexLexeme(TokenClass type) {
  switch (type) {
    case TokenClass.literalChar:
    case TokenClass.literalBool:
    case TokenClass.literalString:
    case TokenClass.literalFloat:
    case TokenClass.literalInt:
    case TokenClass.op:
    case TokenClass.assignOp:
    case TokenClass.customOp:
    case TokenClass.lex:
    case TokenClass.lowerIdentifier:
    case TokenClass.upperIdentifier:
    case TokenClass.macroIdentifier:
    case TokenClass.inlineC:
      return true;
    default: return false;
  }
}

string show(Token token) {
  return token.match!(
    (SimpleToken t) => t.type.show,
    (LiteralBool t) => "bool `" ~ (t.data ? "true" : "false") ~ "`",
    (LiteralChar t) => "char literal `" ~ t.data ~ "`",
    (LiteralString t) => "string literal `" ~ t.data ~ "`",
    (LiteralFloat t) => "float literal `" ~ t.data.value ~ "`",
    (LiteralInt t) => text("int literal `", t.data.value, "`"),
    (Op t) {
      switch (t.type) {
        case TokenClass.op: return "operator " ~ t.data.operator.to!string;
        case TokenClass.assignOp: return "operator " ~ t.data.operator.to!string ~ "=";
        default: assert(0, "Invalid operator type");
      }
    },
    (CustomOp t) => "custom operator " ~ t.data.operator,
    // TODO: (Lex t) => "inline c `" ~ t.data.macro ~ "!`",
    (Identifier t) {
      switch (t.type) {
        case TokenClass.lowerIdentifier: return "identifier `" ~ t.data.value ~ "`";
        case TokenClass.upperIdentifier: return "type constructor `" ~ t.data.value ~ "`";
        case TokenClass.macroIdentifier: return "macro identifier `" ~ t.data.value ~ "`";
        default: assert(0, "Invalid identifier type");
      }
    },
    (InlineC t) => "inline c `" ~ t.data.source ~ "`"
  );
}
