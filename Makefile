CC := clang
CFLAGS := -std=c99 -W -Wall -pedantic

.DEFAULT_GOAL := kitc
all: kitc

kitc: build/kitc
.PHONY: kitc

build/kitc: build/eval
	build/eval bin/kitc/main.kit

EVAL_SOURCES := $(shell find src/bootstrap -name '*.h')
build/eval: $(EVAL_SOURCES) src/bootstrap/eval.c
	@mkdir -p build
	${CC} -Ibuild/gen -Isrc/bootstrap -Isrc/bootstrap/ast -Isrc/bootstrap/parser \
	src/bootstrap/eval.c -o build/eval \
	${CFLAGS} \
	-g \
	-Wno-extra-semi -Wno-implicit-function-declaration -Wno-nullability-completeness -Wno-nullability-extension

clean:
	rm -rf build
.PHONY: clean
