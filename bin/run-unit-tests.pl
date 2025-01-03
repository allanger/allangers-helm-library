#!/usr/bin/env perl

use File::Temp qw/ tempfile tempdir /;
$dir = tempdir( CLEANUP => 1 );
$ENV{HELM_REPOSITORY_CACHE} = $dir;
$ENV{HELM_CACHE_HOME} = $dir;
my @failed;
foreach my $test (<./unit-tests/*>) {
  print $test . "\n";
  foreach my $case (<$test/tests/*.yaml>) {
    $case =~ s/$test\///;
    system("helm dependency update $test") == 0
        or die "Couldn't update dependencies for $test";
    push(@failed, "$test/$case") if system("helm unittest $test -f $case") != 0;
  }
}

if (@failed) {
  foreach my $fail (@failed) {
    print "Test has failed: $fail\n";
  }
  exit(1);
}
