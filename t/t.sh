#!/bin/sh
#
# Copyright (C) 2012 Jean Privat

# run alterner.pl in a controled way
# $1: file to run trough alterner.pl
# rest: additional options to alterner.pl
test_run() {
	test_count=$(($test_count + 1))

	output=`mktemp`
	directive=
	if test_run_ "$@" >$output 2>&1; then
		echo "ok $test_count $1 $directive"
	else
		echo "not ok $test_count $1 $directive"
	fi
	sed 's/^/# /' $output
	rm $output
}
test_run_() {
	# Warning, this function is not executed in a subshell
	f="$1" &&
	shift &&
	d="out/$f.alt" &&
	rm -rf "$d/" 2>/dev/null || : &&
	mkdir -p "$d/" &&
	../alterner.pl -d "$d" "$@" "$f" > "$d/list" &&
	if test -d "sav/$f.alt/"; then
		diff -u "$d/" "sav/$f.alt/"
	else
		directive="# SKIP no sav/$f.alt/ directory"
	fi
}

# try to be in the good directory
ls t/*.java >/dev/null 2>&1 && cd t
ls *.java >/dev/null 2>&1 || {
	echo "1..0 # skip cannot find files to test. bad pwd? `pwd`"
	exit 0
}

test_count=0
total_count=`ls -1 *.java *.c *.pl | wc -l`

echo "1..$total_count"

for f in *.java; do
	test_run "$f"
done

for f in *.c; do
	test_run "$f" --start '/*' --end '*/'
done

for f in *.pl; do
	test_run "$f" --start '#'
done

exit 0
