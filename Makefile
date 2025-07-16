CC = gcc
CFLAGS = -Wall -I.
BISON = bison
FLEX = flex

# Output files
PARSER = parser.tab
LEXER = lex.yy
TARGET = build/compiler

all: $(TARGET)

$(TARGET): $(LEXER).c $(PARSER).c src/main.c
	@mkdir -p build
	$(CC) $(CFLAGS) -o $@ $^

$(PARSER).c $(PARSER).h: parser.y
	$(BISON) -d -o $(PARSER).c parser.y

$(LEXER).c: lexer.l $(PARSER).h
	$(FLEX) -o $(LEXER).c lexer.l

clean:
	rm -f $(LEXER).c $(PARSER).c $(PARSER).h $(TARGET)
	rm -rf build

.PHONY: all clean