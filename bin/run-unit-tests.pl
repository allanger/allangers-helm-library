#!/usr/bin/env perl

my @failed;
foreach my $test (<./unit-tests/*>) {
  print $test . "\n";
  foreach my $case (<$test/tests/*.yaml>) {
    $case =~ s/$test\///;
    system("helm dependency build $test") == 0
        or die "Couldn't build dependencies for $test";
    system("helm dependency update $test") == 0
        or die "Couldn't update dependencies for $test";
    push(@failed, $case) if system("helm unittest $test -f $case") != 0;
  }
}

if (@failed) {
  foreach my $fail (@failed) {
    print "Test has failed: $fail\n";
  }
  exit(1);
}
