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
  my $query = $args{Query};
  foreach my $file (split /\n/, $query) {
    my $contents = read_file($file);
    foreach my $recipe (split /---------- Recipe via Meal-Master/, $contents) {
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
}

sub ParseRecipe {
  my ($self,%args) = (shift,@_);
  my $recipecontents = $args{Recipe};

  # parse out
  my $titletext = "";
  my @ingredients;
  my @directions;
  foreach my $format (qw / Title: Categories: Yield: From: Date: /, "Recipe By:") {
    if ($recipecontents =~ /.*($format)\s*(.*?)[\r\n]*$/m) {
      if ($format eq "Title:") {
	$titletext = $2;
      }
    }
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
    ['recipe',$titletext,['_prolog_list',@ingredients],['_prolog_list',@directions]];
}

sub Clean {
  my ($self) = (shift);
  $_[0] =~ s/^\s*//;
  $_[0] =~ s/\s*$//;
}

1;
