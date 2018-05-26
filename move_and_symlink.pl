#!/usr/bin/perl

use 5.014;
use strict;
use warnings;

use Getopt::Long;
use Path::Tiny;
use String::ShellQuote qw/shell_quote_best_effort/;

sub usage {
    my $fh = $_[0] // \*STDERR;
    print $fh "Usage: move_and_symlink [OPTIONS] from to\n";
    print $fh "\n";
    print $fh "... document options here ...\n";
}

my $ln_target_type = 'auto';
my $dry_run;
my $verbose = 1;
GetOptions(
    'absolute' => sub { $ln_target_type = "absolute" },
    'relative' => sub { $ln_target_type = "relative" },
    'dry-run|d' => \$dry_run,
    'help|usage|h' => sub { usage(\*STDOUT); exit 0 },
    'verbose' => sub { $verbose = 2 },
    'quiet' => sub { $verbose = 0 },
) or do {
    warn "$0: unrecognised flags\n";
    usage();
    exit 1;
};

if (@ARGV != 2) {
    warn "$0: incorrect number of arguments\n";
    usage();
    exit 1;
}

my ($from_arg, $to_arg) = @ARGV;
$from_arg = path($from_arg);
$to_arg = path($to_arg);

if (!$from_arg->is_file) {
    die "$from_arg: Not a file\n";
}

if ($to_arg->is_dir) {
    my $basename = $from_arg->basename;
    $to_arg = $to_arg->child($basename);
}

my ($from_mv, $to_mv) = ($from_arg, $to_arg);
my ($from_ln, $to_ln) = ($from_arg, $to_arg);

# is_relative, is_absolute
if ($ln_target_type eq "auto") {
    if ($from_arg->is_absolute or $to_arg->is_absolute) {
        $ln_target_type = "absolute";
    } else {
        $ln_target_type = "relative";
    }
}

if ($ln_target_type eq "relative") {
    # NB $from_ln eq $from_arg and $from_arg->is_file
    $to_ln = $to_ln->relative($from_ln->parent);
} elsif ($ln_target_type eq "absolute") {
    # this is relative to PWD which is where the arguments are specified relative to
    $to_ln = $to_ln->absolute;
} else {
    die "internal error: ln_target_type=$ln_target_type";
}

if ($dry_run) {
    say "# dry run";
    say "# ln_target_type=$ln_target_type";
}

sub run_command {
    my (@command) = @_;

    if ($verbose) {
        print join(" ", map shell_quote_best_effort($_), @command), "\n";
    }

    return !0 if $dry_run;

    my $rv = system(@command);
    if ($rv == -1) {
        die "system $command[0]: $!\n";
    } elsif ($rv != 0) {
        if ($rv >> 8) {
            die "$command[0]: exited with " . ($rv >> 8);
        } else {
            die "$command[0]: exit failure, status $rv\n";
        }
    }

    # success
    return !0;
}

run_command("mv", $from_mv, $to_mv);
run_command("ln", "-s", $to_ln, $from_ln);
