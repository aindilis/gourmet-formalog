#!/usr/bin/perl -w

use PerlLib::SwissArmyKnife;

my $c = read_file('receipt.txt');

foreach my $token (split /\s+/, $c) {
  if ($token =~ /^[0-9]{12}$/) {
    print "inventoryImport('$token').\n";
  }
}
