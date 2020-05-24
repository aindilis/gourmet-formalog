#!/usr/bin/perl -w

use PerlLib::SwissArmyKnife;

use lib "/var/lib/myfrdcsa/codebases/minor/gourmet-formalog/scripts/recipes";

use MealMasterMMFToProlog;
use MealMasterXMLToProlog;

use Archive::Zip qw( :ERROR_CODES );

my $mmmmf = MealMasterMMFToProlog->new;
my $mmxml = MealMasterXMLToProlog->new;

sub ProcessListing {
  my (%args) = @_;
  foreach my $file (split /\n/, $args{Listing}) {
    if (-f $file) {
      my $contents = read_file($file);
      ProcessFile
	(
	 File => $file,
	 Contents => $contents,
	);
    }
  }
}

sub ProcessFile {
  my (%args) = @_;
  my @mmffiles;
  my @xmlfiles;
  my @zipfiles;
  my $file = $args{File};
  if ((exists $args{InZip} or -f $file) and $file =~ /\.(xml|zip|mmf|txt)$/i) {
    if ($file =~ /\.txt$/i) {
      if (TestIfContentsAreInMealMasterFormat(Contents => $args{Contents})) {
    	$mmmmf->ParseAll
    	  (
    	   File => $file,
    	   Contents => $args{Contents},
    	  );
      }
    }
    if ($file =~ /\.mmf$/i) {
      $mmmmf->ParseAll
    	(
    	 File => $file,
    	 Contents => $args{Contents},
    	);
    }
    # if ($file =~ /\.xml$/i) {
    #   $mmxml->ParseAll
    # 	(
    # 	 File => $file,
    # 	 Contents => $args{Contents},
    # 	);
    # }
    if (! exists $args{InZip} and $file =~ /\.zip$/i) {
      # Process Zip File
      print STDERR "ZIPFILE: $file\n" if $UNIVERSAL::debug;
      my $zip = Archive::Zip->new();
      if ( $zip->read( $file ) == AZ_OK ) {
    	my @names = $zip->memberNames();
    	print STDERR Dumper(\@names) if $UNIVERSAL::debug;
    	foreach my $name (@names) {
    	  my $archivefilecontents = $zip->contents($name);
    	  ProcessFile
    	    (
    	     File => $file.'///'.$name,
    	     Contents => $archivefilecontents,
    	     InZip => 1,
    	    );
    	}
      } else {
    	print STDERR "Cannot read $file\n" if $UNIVERSAL::debug;
      }
    }
  }
}

sub TestIfContentsAreInMealMasterFormat {
  my (%args) = @_;
  my @matches = $args{Contents} =~ /(.*?)(Recipe via Meal-Master)(.*?)/sg;
  my $count = scalar @matches;
  print STDERR "Count: $count\n" if $UNIVERSAL::debug;
  return ($count > 0);
}

my $c = read_file('listing.txt');
ProcessListing(Listing => $c);
