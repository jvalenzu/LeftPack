#!/bin/perl -w

use strict;

print "Name\tHash\tCounters\tFunction count\n";

open (my $fh, "llvm-profdata show --detailed-summary --all-functions --color default.profraw  | c++filt |");
while (<$fh>)
{
  next if m/Counters/;
  m/^  \w/ && do
  {
    (my $name = $_) =~ s/(^\s)|(\n)|(\s$)|.*\.cpp://g;
    (my $hash = <$fh>) =~ s/(^\s)|(\n)|(\s$)|Hash: //g;
    (my $counters = <$fh>) =~ s/(^\s)|(\n)|(\s$)|Counters: //g;
    (my $fc = <$fh>) =~ s/(^\s)|(\n)|(\s$)|Function count: //g;
    
    print "$name\t$hash\t$counters\t$fc\n";
  };
}
close($fh);

#  dump(int, char const*, long long __vector(2), char const*):
#    Hash: 0x0000000000000000
#    Counters: 1
#    Function count: 0

