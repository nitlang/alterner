#!/usr/bin/perl

# Alterner.pl
#
# Copyright 2011 Jean Privat <jean@pryen.org>
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

use strict;
use File::Basename;

# Default values for options
my $directory = "alt"; # The directory where alternatives will be generated.
my $start = "//"; # The marker at the begin of a directive (usually the start of a comment).
my $end = ""; # The marker at the end of the line (usually the end of a comment)

sub usage(;$) {
	my $msg = shift;
	my $usage = "Usage: alterner.pl [-d dir] [--start pat] [--end pat] file...";
	if (defined $msg) {
		print STDERR $msg . "\n" . $usage . "\n";
		exit 1;
	} else {
		print $usage . "\n";
		exit 0;
	}
}

# Process arguments.
my $stop = 0;
while (@ARGV && !$stop) {
	my $arg = $ARGV[0];
	my $val = $ARGV[1];
	if ($arg eq "-d") {
		$directory = $val or usage "$arg requires a directory.";
		shift @ARGV;
		shift @ARGV;
	} elsif ($arg eq "--start") {
		$start = $val or usage "$arg requires a pattern.";
		shift @ARGV;
		shift @ARGV;
	} elsif ($arg eq "--end") {
		$end = $val or usage "$arg requires a pattern.";
		shift @ARGV;
		shift @ARGV;
	} elsif ($arg eq "-h" || $arg eq "--help") { 
		shift @ARGV;
		usage
	} elsif ($arg eq "--") { 
		shift @ARGV;
		$stop = 1;
	} elsif ($arg =~ /^-/) {
		usage "Unknown argument $arg.";
	} else {
		$stop = 1;
	}
}

if ($#ARGV == -1) {
	usage("No input file.");
}

# Generate alternatives from the specified input-file
sub process_alts($) {
	my $file = shift;
	# Read the file
	open my $in, "<", $file or die "$file: $!";
	my @lines = <$in>;
	close($file);

	# Collect alternatives
	my %alt;
	foreach my $l (@lines) {
		while ($l =~ /(\Q$start\E(alt\d*\b))/g) {
			$alt{$1} = $2;
		}
	}
	my @alt = sort(keys(%alt));

	# Process each alternatives
	foreach my $alt (@alt) {
		# Exctact the basename and the suffix
		my ($name, $path, $suffix) = fileparse($file, qr/\.[^\.]*/);

		# Compute filename of the alternative
		my $outfile = $name . "." . $alt{$alt} . $suffix;
		if (defined $directory && $directory ne ".") {
			$outfile = $directory . "/" . $outfile;
			if (! -d $directory) {
				mkdir $directory or die "$directory: $!";
			}
		}

		# Write the alternative
		open my $out, ">", $outfile or die "$outfile: $!";
		print "$outfile\n";
		foreach my $l (@lines) {
			my $l2 = $l;
			if ($l =~ /^(\s*)(.*)(\s*)\Q$alt\E\b([ \t]*)(.*)([ \t]*\Q$end\E\s*)$/) {
				$l2 = "$1$5$3$alt$4$2$6";
			}
			print $out $l2 or die "$outfile: $!";
		}
		close $out;
	}
}

# Do the job
foreach my $file (@ARGV) {
	process_alts($file);
}
