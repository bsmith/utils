#!/bin/sh

mkdir tmp_a
mkdir tmp_b

:>tmp_a/file1
./move_and_symlink.pl tmp_a/file1 tmp_b
:>tmp_a/file2
./move_and_symlink.pl tmp_a/file2 tmp_b/file2b

:>tmp_a/file3
./move_and_symlink.pl --relative tmp_a/file3 tmp_b
:>tmp_a/file4
./move_and_symlink.pl --relative tmp_a/file4 tmp_b/file4b

:>tmp_a/file5
./move_and_symlink.pl --absolute tmp_a/file5 tmp_b
:>tmp_a/file6
./move_and_symlink.pl --absolute tmp_a/file6 tmp_b/file6b

:>tmp_a/file7
./move_and_symlink.pl tmp_a/file7 $(pwd)/tmp_b
:>tmp_a/file8
./move_and_symlink.pl $(pwd)/tmp_a/file8 tmp_b/file8b

ls -l tmp_a/ tmp_b/

rm -r tmp_b
rm -r tmp_a

