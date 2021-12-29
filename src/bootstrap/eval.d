/// A Kit interpreter that bootstraps a self-hosted Kit compiler
/// http://bootstrappable.org/best-practices.html
import core.stdc.stdlib;
import std.file;
import std.stdio;

void main(string[] args) {
  import kit : KitError, document;
  import kit.parser : parseModule;
  import std.array : array;
  import std.exception : ErrnoException;

	if (args.length < 2) {
    stderr.writefln("Usage: kitc <input.kit> [-o output_binary]");
    exit(EXIT_FAILURE);
  }

  auto inputFileName = args[1];
  if(!inputFileName.exists) {
    stderr.writefln("%s: cannot open '%s' (No such file or directory)", inputFileName, inputFileName);
    exit(EXIT_FAILURE);
  }

  auto inputFile = File(inputFileName, "r");
  auto input = inputFile.byLineCopy.array.document(inputFileName);
  try {
    inputFile.close();
  } catch (ErrnoException) {
    stderr.writefln("%s: cannot close '%s'", inputFileName, inputFileName);
    exit(EXIT_FAILURE);
  }

  // Parse and interpret the input module
  auto errors = parseModule(input.contents);
  if (errors.length) exit(EXIT_FAILURE);
  // TODO: Dynamically interpret the parsed module

  exit(EXIT_SUCCESS);
}
