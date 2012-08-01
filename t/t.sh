#!/bin/sh
#
# Copyright (C) 2012 Jean Privat

# run alterner.pl in a controled way
# $1: file to run trough alterner.pl
# rest: additional options to alterner.pl
test_run() {
	test_count=$(($test_count + 1))
	if output=`test_run_ "$@" 2>&1`; then
		echo "ok $test_count $1"
	else
		echo "not ok $test_count $1"
	fi
	test -z "$output" || printf "%s\n" "$output" | sed 's/^/# /'
}
test_run_() {
	f="$1" &&
	shift &&
	d="out/$f.alt" &&
	rm -rf "$d/" 2>/dev/null || : &&
	mkdir -p "$d/" &&
	../alterner.pl -d "$d" "$@" "$f" > "$d/list" &&
	diff -u "$d/" "sav/$f.alt/"
}

# try to be in the good directory
ls t/*.java >/dev/null 2>&1 && cd t
ls *.java >/dev/null 2>&1 || {
	echo "1..0 # skip cannot find files to test. bad pwd? `pwd`"
	exit 0
}

test_count=0
total_count=`ls -1 *.java *.c | wc -l`

echo "1..$total_count"

for f in *.java; do
	test_run "$f"
done

for f in *.c; do
	test_run "$f" --start '/*' --end '*/'
done

exit 0
