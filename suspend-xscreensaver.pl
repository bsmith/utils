die "unimpl";

__END__
$|++; my $ST = time; while ((my $m = $ARGV[0] - (time - $ST) / 60) > 0) { my $rv = system("xscreensaver-command -deactivate 2>&1 >/dev/null"); printf "%.1f mins remaining (%s)\r", $m, $rv; sleep($m > 2 ? 113 : $m * 60) } system("tput el")
perl -E'$|++; my $ST = time; while ((my $m = $ARGV[0] - (time - $ST) / 60) > 0) { system("xscreensaver-command -deactivate >/dev/null"); printf "%.1f mins remaining\r", $m; sleep($m > 2 ? 113 : $m * 60) } system("tput el")' 85