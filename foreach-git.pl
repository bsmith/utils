#!/usr/bin/perl

use 5.014;
use strict;
use warnings;
use Getopt::Long;

sub usage {
  print "Usage: $0 [--dir=<dir>] [--annex-only] [--quiet] -- <cmd>\n";
  print "\n";
  print "  --dir=<dir>, -d <dir>     change directory to <dir> first\n";
  print "  --annex-only              only act on git-annex repositories\n";
  print "  --quiet                   don't announce directory changes\n";
}

Getopt::Long::Configure('require_order');
GetOptions(
  'h|help' => sub { usage; exit 0 },
  'd|dir=s' => \my $dir,
  'annex|annex-only' => \my $annex_only,
  'q|quiet' => \my $quiet,
  'list' => \my $list,
) or do { usage; exit 1 };

if (not (@ARGV or $list)) {
  warn "No command given\n";
  usage;
  exit 1;
}

if (not defined $dir) {
  $dir = ".";
}

chdir $dir or die "$0: chdir $dir: $!\n";
opendir my $dir_fh, "." or die "$0: opendir $dir: $!\n";

for my $d (glob "*") {
  next unless -d "$d";
  next unless -d "$d/.git";

  if ($annex_only) {
    next unless -d "$d/.git/annex";
  }

  if ($list) {
    print "$d\n";
    next;
  }

  if (not $quiet) {
    print "cd $dir/$d\n";
  }

  chdir $d or die "$0: chdir $dir/$d: $!\n";

  my $rv = system @ARGV;
  if ($rv == -1) { die "$0: system $ARGV[0]: $!\n"; }
  elsif ($rv != 0) { die "$0: $ARGV[0] exited: $?\n"; }

  chdir $dir_fh or die "$0: chdir $dir: $!\n";
}
