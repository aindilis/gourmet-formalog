package Gourmet::Importer::Standardizer;

use Manager::Dialog qw ( Choose Message );
use MyFRDCSA;
use PerlLib::Collection;

use Data::Dumper;
use Lingua::EN::Tagger;
use String::Similarity;
use XML::Simple;

use strict;
use Carp;

use vars qw/ $VERSION /;
$VERSION = '1.00';
use Class::MethodMaker
  new_with_init => 'new',
  get_set       => [ qw / XS FoodDes Translations Tagger Freq FreqDBFile
                          Total / ];

sub init {
  my ($self,%args) = (shift,@_);
  # open connection to database, and open the gourmet database
  $self->XS
    (XML::Simple->new());
#   $self->FoodDes
#     ($UNIVERSAL::gourmet->DB->GetAOH
#      ("select * from food_des"));
  $self->Tagger(Lingua::EN::Tagger->new(stem => 0));
#   $self->Translations
#     (PerlLib::Collection->new
#      (Type => "String",
#       StorageFile => ConcatDir
#       ($UNIVERSAL::systemdir,
#        "var","lib","gourmet","translations")));
#  $self->GenerateLanguageModel();
}

sub Standardize {
  my ($self,%args) = (shift,@_);
  my $doc = $args{Document};
  # normalize ingrediants
  foreach my $ing (@{$doc->{recipe}->{ingrediants}->{ing}}) {
    # lets normalize it to a well known item, or leave it alone.
    $ing->{item} = $self->StandardizeIngredient($ing)
  }
}

sub StandardizeIngredient {
  my ($self,$ing) = (shift,shift);
  return $self->LookupSimilar($ing->{item});
  # now fix the quantity
}

sub LookupSimilar {
  my ($self,$query) = (shift,shift);
  print "<<<$query>>>\n";
  my ($limit,$similarity,@matches) = (0,0,());

  if (0) {
    foreach my $f (@{$self->FoodDes}) {
      $similarity = similarity($query,$f->{long_desc},0);
      push @matches, [$f->{long_desc}, sprintf("%0.5f",$similarity)];
    }
    my @tmp = sort {$b->[1] <=> $a->[1]} @matches;
    my @sorted = splice(@tmp,0,15);
    my @items = map {"<<<" . $_->[1] . ">\t<" . $_->[0] . ">>>"} @sorted;
    my $ans = Choose(@items);
    print "$ans\n";
    # return $sorted[$ans]->[0];
  }

  if (0) {
    my $tagged_text = $self->Tagger->add_tags($query);
    print Dumper($self->Tagger->get_max_noun_phrases($tagged_text));
  }

  if (1) {
    my $contentsfile = $ARGV[0];
    my $num = 0;
    my @results;
    print Dumper($self->ChooseBestScore(Query => $query));
  }
}

sub GenerateLanguageModel {
  my ($self,%args) = (shift,@_);
  Message(Message => "Generating Language Model...");
  $self->FreqDBFile("/tmp/freq.db");
  my $freqdbfile = $self->FreqDBFile;
  my ($num,%freq);
  if (0) {			#-e $freqdbfile) {
    ($num,%freq) = eval `cat $freqdbfile`;
  } else {
    foreach my $line (map {$_->{'long_desc'}} @{$self->FoodDes}) {
      foreach my $word (map {lc($_)} split '\W+', $line) {
	if (defined $freq{$word}) {
	  $freq{$word} += 1;
	} else {
	  $freq{$word} = 1;
	}
	++$num;
      }
    }
    my $OUT;
    open(OUT,">$freqdbfile") or die "ouch!";
    print OUT Dumper($num,%freq);
    close(OUT);
  }
  print "NUM: ".$self->Total."\n";
  $self->Total($num);
  $self->Freq(\%freq);
}

sub ChooseBestScore {
  my ($self,%args) = (shift,@_);
  my $line = $args{Query};
  my %score;
  chomp $line;
  my @results;
  my @keywords = map {lc($_)} split '\W+',$line;
  foreach my $keyword (@keywords) {
    if ($self->Freq->{$keyword} and length $keyword > 3) {
      print $self->Total."\t".$self->Freq->{$keyword}."\t".$keyword."\n";
      foreach my $result (map {$_->{'long_desc'}}
	 @{$UNIVERSAL::gourmet->MyMySQL->Do
	     (Statement => "select long_desc from food_des ".
	      "where long_desc like '%$keyword%'",
	      Array => 1)}) {
	$score{$result} += ($self->Total / $self->Freq->{$keyword});
      }
    }
  }
  my @top = sort {$score{$a} <=> $score{$b}} keys %score;
  print "\n\n<$line>\n";
  my $none = "none of the below";
  my $result = Choose(($none,reverse (scalar @top < 21 ? @top : splice (@top,-20))));
  if ($result !~ /$none/) {
    $result =~ s/ - .*//;
    push @results, $result;
  }
  return \@results;
}

sub MapSR16FoodDesToHierarchy {
  # system to try to ease mapping between recipes and SR16 by
  # structuring the SR16 a little better.
  foreach my $ref
    ($UNIVERSAL::gourmet->MyMySQL->Do
     (Statement => "select long_desc from food_des",
      Array => 1)) {
    # my @words = split /\s+/, $ref->{long_desc};
  }
}

1;
