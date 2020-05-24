#!/usr/bin/perl -w

use Algorithm::CheckDigits;

$upc = CheckDigits('UPC');
$cn = $upc->complete($ARGV[0]);
print $cn;
