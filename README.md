# Unix Tools in C and Bash

Small Linux command-line programs in C and Bash: a shell, a version of `wc`, an email validator built on `grep`, file and directory tools, a system status monitor, and a grade calculator that splits its work across processes and threads. I wrote them in 2024 during my Computer Science degree at Wilfrid Laurier University.

| Folder | Program | What it does |
|---|---|---|
| `shell/` | `shell` | A basic Unix shell. It reads a command at the `myshell>` prompt, splits it into arguments, and runs it in a child process with `fork`, `execvp` and `wait` |
| `text/` | `word_count` | Prints a file and counts its lines, words and words per line, like `wc` |
| | `regex` | Saves the valid email addresses from a file to another file, using a regular expression with `grep` |
| | `text_to_array.sh` | Reads a file one character at a time and splits it into an array of words |
| `files/` | `filecopy` | Copies one file into another |
| | `check_directory.sh` | Counts the regular files in a directory, optionally only the ones with a given extension |
| `system/` | `system_status.sh` | Checks CPU use, free memory and disk use against thresholds, and can email the report |
| `concurrency/` | `course_average` | A teacher process starts one process per chapter, and each of those starts two threads that average one assignment each |
| `basics/` | `triangle`, `ticket` | Pascal's triangle, and movie ticket prices by time of day and age |

## Build and run

Needs Linux (or WSL on Windows) with `gcc` and `make`.

```bash
make        # builds the C programs into bin/
make test   # runs every program and script and checks the output
```

For example:

```bash
./bin/shell
./bin/word_count
./bin/course_average concurrency/sample_in_grades.txt
bash text/text_to_array.sh text/sample.txt
bash system/system_status.sh
```

`text_to_array.sh` uses bash arrays, so run it with `bash`, not `sh`.

## Fixed in 2026

I put these programs together as one project and tested them on a current Linux, which turned up bugs I fixed:

- `shell` and `word_count` kept running forever when their input ended (Ctrl+D).
- `regex` passed the file names you typed straight to the shell, so a name like `out.txt;mkdir${IFS}x` ran a command. It now only accepts plain file names, and its buffers can't overflow. Its regular expression also rejected valid usernames such as `first.last-name`.
- `text_to_array.sh` had a syntax error and didn't run.
- `system_status.sh` warned about memory the wrong way round, failed to compare decimal numbers, printed `\n` literally under bash, and only sent the report by email instead of also printing it.
- `course_average` sometimes printed the averages out of order.
- `triangle` overflowed an `int` on its 14th row, and `ticket` overflowed its buffer on `night`.
- `filecopy` crashed when a file couldn't be opened.
