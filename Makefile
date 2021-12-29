.DEFAULT_GOAL := kitc
all: kitc

kitc: build/kitc
.PHONY: kitc

build/kitc: build/eval
	build/eval bin/kitc/main.kit

EVAL_SOURCES := $(shell find src/bootstrap -name '*.d')
build/eval: $(EVAL_SOURCES) src/bootstrap/eval.d
	dub build

clean:
	rm -rf build
.PHONY: clean
