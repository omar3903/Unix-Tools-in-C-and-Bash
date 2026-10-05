# Compiler
CC = gcc

# Compiler Flags
CFLAGS = -Wall -Wextra -std=gnu99 -g

# Programs, all built into bin/
PROGS = bin/shell bin/word_count bin/regex bin/filecopy bin/course_average bin/triangle bin/ticket

# Default Target
all: $(PROGS)

bin:
	mkdir -p bin

# Shell
bin/shell: shell/shell.c | bin
	$(CC) $(CFLAGS) -o $@ $<

# Text
bin/word_count: text/word_count.c | bin
	$(CC) $(CFLAGS) -o $@ $<

bin/regex: text/regex.c | bin
	$(CC) $(CFLAGS) -o $@ $<

# Files
bin/filecopy: files/filecopy.c | bin
	$(CC) $(CFLAGS) -o $@ $<

# Processes and threads
bin/course_average: concurrency/course_average.c | bin
	$(CC) $(CFLAGS) -pthread -o $@ $<

# Basics
bin/triangle: basics/triangle.c | bin
	$(CC) $(CFLAGS) -o $@ $<

bin/ticket: basics/ticket.c | bin
	$(CC) $(CFLAGS) -o $@ $<

# Run every program and script and check the output
test: all
	bash tests/run_tests.sh

# Clean rule to remove compiled files
clean:
	rm -rf bin valid.txt output.txt

# Phony targets
.PHONY: all test clean
