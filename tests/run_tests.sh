#!/bin/bash
# Runs every program and script on sample input and checks the output.
# Usage: make test (builds everything first)

root=$(cd "$(dirname "$0")/.." && pwd)
cd "$root"
tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT
passed=0
failed=0

# expect "<test name>" "<output>" "<text the output must have>"
expect() {
    if [[ "$2" == *"$3"* ]]; then
        echo "PASS  $1"
        passed=$((passed + 1))
    else
        echo "FAIL  $1 (missing: $3)"
        failed=$((failed + 1))
    fi
}

# expect_status "<test name>" <exit status> <expected exit status>
expect_status() {
    if [ "$2" -eq "$3" ]; then
        echo "PASS  $1"
        passed=$((passed + 1))
    else
        echo "FAIL  $1 (got $2, expected $3)"
        failed=$((failed + 1))
    fi
}

echo "--- Shell"
out=$(printf 'echo hello\n   \n\nuname\nnot_a_real_command\nq\n' | timeout 5 ./bin/shell 2>&1)
expect "shell runs echo" "$out" "hello"
expect "shell runs uname" "$out" "Linux"
expect "shell reports a command that doesn't exist" "$out" "Failed to execute command."
out=$(printf 'echo once\n' | timeout 5 ./bin/shell)
expect_status "shell quits at the end of input" $? 0
count=$(echo "$out" | grep -c "once")
expect_status "shell runs the last command only once" "$count" 1

echo "--- Text"
out=$(printf 'f\ntext/sample.txt\nx\nf\nnope.txt\nq\n' | timeout 5 ./bin/word_count)
expect "word_count counts lines" "$out" "Number of lines of text/sample.txt: 3"
expect "word_count counts words" "$out" "Number of words of text/sample.txt: 20"
expect "word_count averages words per line" "$out" "Average number of words per line of text/sample.txt: 6.67"
expect "word_count says when a file can't be opened" "$out" "nope.txt cannot be opened"
expect "word_count says when a command is wrong" "$out" "x is not a command"
printf 'f\n' | timeout 5 ./bin/word_count > /dev/null
expect_status "word_count quits at the end of input" $? 0

cp text/emails.txt "$tmp/emails.txt"
out=$(cd "$tmp" && printf 'emails.txt\nvalid.txt\n' | "$root/bin/regex")
expect "regex saves the valid emails" "$out" "Valid emails extracted and saved to valid.txt"
expected=$(printf 'jane.doe@example.com\nfirst.last-name@example.co.uk\njohn_smith+news@mail.example.org\nuser123@sub-domain.example.ca\na@b.io')
expect_status "regex keeps exactly the 5 valid emails" "$([ "$(cat "$tmp/valid.txt")" == "$expected" ] && echo 0 || echo 1)" 0
(cd "$tmp" && printf 'emails.txt\nout.txt;mkdir${IFS}hacked\n' | "$root/bin/regex" > /dev/null 2>&1)
expect_status "regex refuses a file name with shell commands in it" $? 1
expect_status "regex never ran the injected command" "$([ -e "$tmp/hacked" ] && echo 1 || echo 0)" 0

out=$(bash text/text_to_array.sh text/sample.txt)
expect "text_to_array prints the array" "$out" "Array elements:"
words=$(echo "$out" | tail -n +2)
expect_status "text_to_array finds all 20 words" "$(echo "$words" | wc -l)" 20
expect "text_to_array drops punctuation" "$(echo "$words" | tail -1)" "jobs"
expect_status "text_to_array never keeps a dot or comma" "$(echo "$words" | grep -c '[.,]')" 0
out=$(bash text/text_to_array.sh)
expect "text_to_array usage message" "$out" "Usage:"
out=$(bash text/text_to_array.sh no_such_file.txt)
expect "text_to_array missing file" "$out" "Error: File 'no_such_file.txt' not found."

echo "--- Files"
out=$(./bin/filecopy)
expect_status "filecopy without files fails" $? 1
expect "filecopy without files says so" "$out" "Insufficient parameters passed."
out=$(./bin/filecopy bin/shell "$tmp/copy")
expect "filecopy reports the copy" "$out" "have been successfully copied into the"
cmp -s bin/shell "$tmp/copy"
expect_status "filecopy makes an exact copy" $? 0
./bin/filecopy no_such_file.txt "$tmp/copy2" > /dev/null
expect_status "filecopy with a missing input fails cleanly" $? 1

mkdir "$tmp/dir" && touch "$tmp/dir/a.sh" "$tmp/dir/b.sh" "$tmp/dir/c.txt"
out=$(bash files/check_directory.sh "$tmp/dir" sh)
expect "check_directory counts files by extension" "$out" "':   2"
out=$(bash files/check_directory.sh "$tmp/dir")
expect "check_directory counts all files" "$out" "':   3"
out=$(sh files/check_directory.sh "$tmp/dir" txt)
expect "check_directory also works under sh" "$out" "':   1"
bash files/check_directory.sh > /dev/null
expect_status "check_directory usage fails" $? 1
bash files/check_directory.sh "$tmp/nope" > /dev/null
expect_status "check_directory missing directory fails" $? 1

echo "--- System"
out=$(bash system/system_status.sh)
expect_status "system_status runs" $? 0
expect "system_status checks the CPU" "$out" "cpu utilization:"
expect "system_status checks memory" "$out" "percent memory free is :"
expect "system_status checks the disks" "$out" "Disk usage:"
expect "system_status prints the report without an email" "$out" "No email address given"
expect_status "system_status prints no literal \\n" "$(echo "$out" | grep -c '\\n')" 0
out=$(sh system/system_status.sh)
expect "system_status also works under sh" "$out" "Disk usage:"

echo "--- Processes and threads"
expected=$(printf 'Assignment 1 - Average = 10.200000\nAssignment 2 - Average = 11.600000\nAssignment 3 - Average = 13.700000\nAssignment 4 - Average = 13.600000\nAssignment 5 - Average = 9.400000\nAssignment 6 - Average = 11.600000')
in_order=0
for run in $(seq 1 20); do
    out=$(./bin/course_average concurrency/sample_in_grades.txt)
    [ "$out" == "$expected" ] || in_order=1
done
expect_status "course_average prints the 6 averages in order, 20 runs out of 20" "$in_order" 0

echo "--- Basics"
out=$(printf '5\n' | ./bin/triangle)
expect "triangle row 5" "$out" "1    4    6    4    1"
out=$(printf '14\n' | ./bin/triangle)
expect "triangle row 14 doesn't overflow" "$out" "1    13    78    286    715    1287    1716    1716    1287    715    286    78    13    1"
out=$(printf '15\n' | ./bin/triangle)
expect "triangle rejects 15" "$out" "Invalid input."
out=$(printf 'night\n50\n' | ./bin/ticket)
expect "ticket night, 50" "$out" '$15'
out=$(printf 'day\n15\n' | ./bin/ticket)
expect "ticket day, 15" "$out" '$8'
out=$(printf 'night\n3\n' | ./bin/ticket)
expect "ticket night, 3" "$out" "free"
out=$(printf 'night\n60\n' | ./bin/ticket)
expect "ticket night, 60" "$out" '$13'
out=$(printf 'noon\n30\n' | ./bin/ticket)
expect "ticket rejects a time that isn't day or night" "$out" "Invalid time"

echo
echo "$passed passed, $failed failed"
[ "$failed" -eq 0 ]
