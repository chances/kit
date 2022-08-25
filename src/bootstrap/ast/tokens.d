module kit.ast.tokens;

import kit.ast : Span;
import kit.ast.numbers;
import kit.ast.operators;
import std.algorithm : joiner, map;
import std.array : array;
import std.conv : text, to;
import std.sumtype;
import std.traits : EnumMembers;
import std.typecons : Nullable;
import std.variant : Variant;

struct Token {
  TokenClass type;
  Span span;
  Variant* data = null;

  static Token withData(T)(TokenClass type, Span span, T data) {
    auto dataVariant = new Variant;
    *dataVariant = data;
    return Token(type, span, dataVariant);
  }
}

enum TokenClass {
  metaOpen,
  parenOpen,
  parenClose,
  curlyBraceOpen,
  curlyBraceClose,
  squareBraceOpen,
  squareBraceClose,
  comma,
  colon,
  semicolon,
  tripleDot,
  dot,
  hash,
  dollar,
  arrow,
  functionArrow,
  question,
  underscore,
  // Wildcards
  wildcardSuffix,
  doubleWildcardSuffix,
  // Keywords
  keywordAbstract,
  keywordAs,
  keywordBreak,
  keywordConst,
  keywordContinue,
  keywordDefault,
  keywordDefined,
  keywordDefer,
  keywordDo,
  keywordElse,
  keywordEmpty,
  keywordEnum,
  keywordExtend,
  keywordFor,
  keywordFunction,
  keywordIf,
  keywordImplement,
  keywordImplicit,
  keywordImport,
  keywordInclude,
  keywordInline,
  keywordIn,
  keywordMacro,
  keywordMatch,
  keywordNull,
  keywordPrivate,
  keywordPublic,
  keywordReturn,
  keywordRule,
  keywordRules,
  keywordSelf,
  keywordSizeof,
  keywordSpecialize,
  keywordStatic,
  keywordStruct,
  keywordThen,
  keywordThis,
  keywordThrow,
  keywordTokens,
  keywordTrait,
  keywordTypedef,
  keywordUndefined,
  keywordUnion,
  keywordUnsafe,
  keywordUsing,
  keywordVar,
  keywordWhile,
  keywordYield,
  // Tokens with data
  literalChar     , // "c'([^\\']|\\.)'",
  literalBool     , // "[true;false]",
  literalString   , // `"((?:\\"|[^"])*)"`,
  literalFloat    , // "([0-9]*(.[0-9]+)?)(f32|f64)",
  literalInt      , // "[0-9]+(c|i|s|u8|u16|u32|u64|i8|i16|i32|i64)",
  op              , // opRegex.to!string,
  assignOp        , // "[+=;-=;/=;*=;%=;&&=;||=;&=;;=;^=;<<=;>>=]",
  customOp        , // "[\\*\\/\\+\\-\\^\\=\\<\\>\\!\\&\\%\\~\\@\\?\\:\\.]+",
  lex             , // "[_]*[a-z][a-zA-Z0-9_]*\\!",
  lowerIdentifier , // lowerIdentifierRegex.to!string,
  upperIdentifier , // upperIdentifierRegex.to!string,
  macroIdentifier , // macroIdentifierRegex.to!string,
  inlineC         , // "```(([^`]|\\`[^`]|\\`\\`[^`]|\\n)*)```"
}

enum opRegex = "[" ~ [EnumMembers!Operator].map!(op => op.to!string).joiner(";").array ~ "]";
enum lowerIdentifierRegex = "[" ~ ["[_]*[a-z][a-zA-Z0-9_]*", "[@]([a-z][a-zA-Z0-9_]*)", "`([^`]+)`"].joiner(";").array ~ "]";
enum upperIdentifierRegex = "[" ~ ["[_]*[A-Z][a-zA-Z0-9_]*", "``(([^`]|\\`[^`])+)``"].joiner(";").array ~ "]";
enum macroIdentifierRegex = "[" ~ ["\\$([A-Za-z_][a-zA-Z0-9_]*])", "${([A-Za-z_][a-zA-Z0-9_]*)}"].joiner(";").array ~ "]";

string show(Token token) {
  import kit.ast.operators;

  switch (token.type) {
    case TokenClass.metaOpen:
      return "#[";
    case TokenClass.parenOpen:
      return "(";
    case TokenClass.parenClose:
      return ")";
    case TokenClass.curlyBraceOpen:
      return "{";
    case TokenClass.curlyBraceClose:
      return "}";
    case TokenClass.squareBraceOpen:
      return "[";
    case TokenClass.squareBraceClose:
      return "]";
    case TokenClass.comma:
      return ",";
    case TokenClass.colon:
      return ":";
    case TokenClass.semicolon:
      return ";";
    case TokenClass.tripleDot:
      return "...";
    case TokenClass.dot:
      return ".";
    case TokenClass.hash:
      return "#";
    case TokenClass.dollar:
      return "$";
    case TokenClass.arrow:
      return "=>";
    case TokenClass.functionArrow:
      return "->";
    case TokenClass.question:
      return "?";
    case TokenClass.underscore:
      return "_";
    case TokenClass.wildcardSuffix:
      return ".*";
    case TokenClass.doubleWildcardSuffix:
      return ".**";
    // Keywords
    case TokenClass.keywordAbstract:
      return "abstract";
    case TokenClass.keywordAs:
      return "as";
    case TokenClass.keywordBreak:
      return "break";
    case TokenClass.keywordConst:
      return "const";
    case TokenClass.keywordContinue:
      return "continue";
    case TokenClass.keywordDefault:
      return "default";
    case TokenClass.keywordDefined:
      return "defined";
    case TokenClass.keywordDefer:
      return "defer";
    case TokenClass.keywordDo:
      return "do";
    case TokenClass.keywordElse:
      return "else";
    case TokenClass.keywordEmpty:
      return "empty";
    case TokenClass.keywordEnum:
      return "enum";
    case TokenClass.keywordExtend:
      return "extend";
    case TokenClass.keywordFor:
      return "for";
    case TokenClass.keywordFunction:
      return "function";
    case TokenClass.keywordIf:
      return "if";
    case TokenClass.keywordImplement:
      return "implement";
    case TokenClass.keywordImplicit:
      return "implicit";
    case TokenClass.keywordImport:
      return "import";
    case TokenClass.keywordInclude:
      return "include";
    case TokenClass.keywordInline:
      return "inline";
    case TokenClass.keywordIn:
      return "in";
    case TokenClass.keywordMacro:
      return "macro";
    case TokenClass.keywordMatch:
      return "match";
    case TokenClass.keywordNull:
      return "null";
    case TokenClass.keywordPrivate:
      return "private";
    case TokenClass.keywordPublic:
      return "public";
    case TokenClass.keywordReturn:
      return "return";
    case TokenClass.keywordRule:
      return "rule";
    case TokenClass.keywordRules:
      return "rules";
    case TokenClass.keywordSelf:
      return "self";
    case TokenClass.keywordSizeof:
      return "sizeof";
    case TokenClass.keywordSpecialize:
      return "specialize";
    case TokenClass.keywordStatic:
      return "static";
    case TokenClass.keywordStruct:
      return "struct";
    case TokenClass.keywordThen:
      return "then";
    case TokenClass.keywordThis:
      return "this";
    case TokenClass.keywordThrow:
      return "throw";
    case TokenClass.keywordTokens:
      return "tokens";
    case TokenClass.keywordTrait:
      return "trait";
    case TokenClass.keywordTypedef:
      return "typedef";
    case TokenClass.keywordUndefined:
      return "undefined";
    case TokenClass.keywordUnion:
      return "union";
    case TokenClass.keywordUnsafe:
      return "unsafe";
    case TokenClass.keywordUsing:
      return "using";
    case TokenClass.keywordVar:
      return "var";
    case TokenClass.keywordWhile:
      return "while";
    case TokenClass.keywordYield:
      return "yield";
    case TokenClass.literalChar:
      return "char literal `" ~ token.data.get!char ~ "`";
    case TokenClass.literalBool:
      return "bool `" ~ (token.data.get!bool ? "true" : "false") ~ "`";
    case TokenClass.literalString:
      return "string literal `" ~ token.data.get!string ~ "`";
    case TokenClass.literalFloat:
      return text("float literal `", token.data.get!float, "`");
    case TokenClass.literalInt:
      return text("int literal `", token.data.get!double, "`");
    case TokenClass.op:
      return "operator op " ~ token.data.get!Operator.to!string;
    case TokenClass.assignOp:
      return "operator " ~ token.data.get!string ~ "=";
    case TokenClass.customOp:
      return "custom operator " ~ token.data.get!string;
    case TokenClass.lex:
      assert(0, "Unimplemented");
      // TODO: return "lex `" ~ token.data.get!string ~ "!`";
    case TokenClass.lowerIdentifier:
      return "identifier `" ~ token.data.get!string ~ "`";
    case TokenClass.upperIdentifier:
      return "type constructor `" ~ token.data.get!string ~ "`";
    case TokenClass.macroIdentifier:
      return "macro identifier `" ~ token.data.get!string ~ "`";
    case TokenClass.inlineC:
      return "inline c `" ~ token.data.get!string ~ "`";
    default:
      assert(0, "Unknown token type.");
  }
}
