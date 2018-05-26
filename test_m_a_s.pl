#!/usr/bin/perl

use 5.014;
use strict;
use warnings;

use Test::More;
use Path::Tiny;
use File::stat;

path("tmp_a")->mkpath;
path("tmp_b")->mkpath;

END {
    path("tmp_a")->remove_tree;
    path("tmp_b")->remove_tree;
}

sub run_script {
    my ($args, $name) = @_;
    my $rv = system("./move_and_symlink.pl", @$args);
    cmp_ok($rv, '==', 0, $name . ": run_script");
}

sub check_result {
    my ($from, $to, $name) = @_;
    ok(-f $to, $name . ": is regular file");
    is(path($to)->slurp, "testdata", $name . ": contents okay");
    ok(stat($from)->ino == stat($to)->ino, $name . ": link okay");
}

path("tmp_a/file1")->spew("testdata");
run_script(["tmp_a/file1", "tmp_b"], "1a");
check_result("tmp_a/file1", "tmp_b/file1", "1a");
path("tmp_a/file2")->spew("testdata");
run_script(["tmp_a/file2", "tmp_b/file2b"], "1b");
check_result("tmp_a/file2", "tmp_b/file2b", "1b");

path("tmp_a/file3")->spew("testdata");
run_script(["--relative", "tmp_a/file3", "tmp_b"], "2a");
check_result("tmp_a/file3", "tmp_b/file3", "2a");
path("tmp_a/file4")->spew("testdata");
run_script(["--relative", "tmp_a/file4", "tmp_b/file4b"], "2b"); 
check_result("tmp_a/file4", "tmp_b/file4b", "2b");

path("tmp_a/file5")->spew("testdata");
run_script(["--absolute", "tmp_a/file5", "tmp_b"], "3a");
check_result("tmp_a/file5", "tmp_b/file5", "3a");
path("tmp_a/file6")->spew("testdata");
run_script(["--absolute", "tmp_a/file6", "tmp_b/file6b"], "3b");
check_result("tmp_a/file6", "tmp_b/file6b", "3b");

path("tmp_a/file7")->spew("testdata");
run_script(["tmp_a/file7", path("tmp_b")->absolute], "4a");
check_result("tmp_a/file7", "tmp_b/file7", "4a");
path("tmp_a/file8")->spew("testdata");
run_script([path("tmp_a/file8")->absolute, "tmp_b/file8b"], "4b");
check_result("tmp_a/file8", "tmp_b/file8b", "4b");

done_testing();