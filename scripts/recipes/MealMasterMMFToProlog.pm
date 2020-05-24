package MealMasterMMFToProlog;

use KBS2::ImportExport;
use PerlLib::SwissArmyKnife;

use Lingua::EN::Sentence qw( get_sentences add_acronyms );
use Lingua::EN::Splitter qw( paragraphs );

use Class::MethodMaker
  new_with_init => 'new',
  get_set       => [ qw / ImportExport / ];

sub init {
  my ($self,%args) = (shift,@_);
  $self->ImportExport
    (KBS2::ImportExport->new
     ());
}

sub ParseAll {
  my ($self,%args) = (shift,@_);
  my $contents = $args{Contents};
  foreach my $recipe (split /M*-+ Recipe via Meal-Master/, $contents) {
    my $res1 = $self->ImportExport->Convert
      (
       InputType => 'Interlingua',
       Input => [$self->ParseRecipe(Recipe => $recipe)],
       OutputType => 'Prolog',
      );
    if ($res1->{Success}) {
      my $output = $res1->{Output}."\n";
      $output =~ s/_prolog_list/'_prolog_list'/sg;
      print $output;
    }
  }
  print "\n\n";
}

sub ParseRecipe {
  my ($self,%args) = (shift,@_);
  my $recipecontents = $args{Recipe};

  # print STDERR $recipecontents."\n\n" if $UNIVERSAL::debug;

  my $version = '';
  if ($recipecontents =~ /\s*\(tm\)\s+v(\S+)/) {
    $version = $1;
  }

  # parse out
  my $titletext = '';
  my @categories = ('_prolog_list');
  my $yield = '';
  my @ingredients;
  my @directions;
  my $from;
  my $date;
  my $source;
  foreach my $format (qw / Title: Categories: Yield: From: Date: Source: /, "Recipe By:") {
    if ($recipecontents =~ /.*($format)\s*(.*?)[\r\n]*$/m) {
      my $match = $2;
      if ($format eq "Title:") {
	$titletext = $match;
      } elsif ($format eq 'Categories:') {
	push @categories, split /,\s*/, $match;
      } elsif ($format eq 'Yield:') {
	$yield = $match;
      } elsif ($format eq 'From:') {
	$from = $match;
      } elsif ($format eq 'Date:') {
	$date = $match;
      } elsif ($format eq 'Source:') {
	$source = $match;
      }
    }
  }

  my @additional;
  push @additional, ['v','mm',$version];
  if ($yield) {
    push @additional, ['y',$yield];
  }
  push @additional, ['c',\@categories];
  if ($from) {
    push @additional, ['f',$from];
  }
  if ($date) {
    push @additional, ['d',$date];
  }
  if ($source) {
    push @additional, ['s',$source];
  }

  # parse out ingredients
  my @para = @{(paragraphs $recipecontents)[0]};
  shift @para;
  shift @para;
  my $inglist = shift @para;

  if ($inglist) {
    $inglist =~ s/[\r\n]\s+[-;]/ /smg;
    foreach my $ingredient (split /\n/,$inglist) {

      if ($ingredient =~ /^(.{7}).(..).(.*)[\n\r]/) {
	my $a = $1 || "";
	my $b = $2 || "";
	my $c = $3 || "";

	$self->Clean($a);
	$self->Clean($b);
	$self->Clean($c);

	push @ingredients, ['ing',$a,$b,$c];
      }
    }
  }
  # parse out directions
  foreach my $parag (@para) {
    my $sentences = get_sentences($parag);
    foreach my $sentence (@{$sentences}) {
      $sentence =~ s/\n/ /g;
      $sentence =~ s/\s+/ /g;
      chomp $sentence;
      push @directions, $sentence;
    }
  }
  return
    ['recipe',$titletext,['_prolog_list',@ingredients],['_prolog_list',@directions],['_prolog_list',@additional]];
}

sub Clean {
  my ($self) = (shift);
  $_[0] =~ s/^\s*//;
  $_[0] =~ s/\s*$//;
}

1;
