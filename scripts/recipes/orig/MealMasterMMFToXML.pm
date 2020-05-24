package MealMasterMMF;

use PerlLib::SwissArmyKnife;

use Lingua::EN::Sentence qw( get_sentences add_acronyms );
use Lingua::EN::Splitter qw( paragraphs );
use XML::Twig;

use Class::MethodMaker
  new_with_init => 'new',
  get_set       => [ qw / Cache SourceDir TargetDir Twig / ];

sub init {
  my ($self,%args) = (shift,@_);
  $self->Twig(XML::Twig->new(pretty_print => 'indented'));
}

sub ParseAll {
  my ($self,%args) = (shift,@_);
  my $query = $args{Query};
  foreach my $file (split /\n/, $query) {
    my $contents = read_file($file);
    foreach my $recipe (split /---------- Recipe via Meal-Master/, $contents) {
      $self->ParseRecipe(Recipe => $recipe);
    }
  }
}

sub ParseRecipe {
  my ($self,%args) = (shift,@_);
  my $recipecontents = $args{Recipe};

  # parse out

  my $header = '<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE recipeml PUBLIC "-//FormatData//DTD RecipeML 0.5//EN"
"http://www.formatdata.com/recipeml/recipeml.dtd">
<?xml-stylesheet href="dessert1.css" type="text/css"?>
';
  my $titletext = "";
  my $recipeml = XML::Twig::Elt->new('recipeml');
  $recipeml->set_att(version => "0.5");

  my $recipe = XML::Twig::Elt->new('recipe');
  $recipe->paste('last_child', $recipeml);

  my $head = XML::Twig::Elt->new('head');
  $head->paste('last_child', $recipe);

  my $title = XML::Twig::Elt->new('title');

  foreach my $format (qw / Title: Categories: Yield: From: Date: /, "Recipe By:") {
    if ($recipecontents =~ /.*($format)\s*(.*?)[\r\n]*$/m) {
      if ($format eq "Title:") {
	$title->set_text($2);
	$titletext = $2;
      }
    }
  }

  $title->paste('last_child', $head);

  # parse out ingredients

  my $ingredients = XML::Twig::Elt->new('ingredients');
  $ingredients->paste('last_child', $recipe);

  my @para = @{(paragraphs $recipecontents)[0]};
  shift @para;
  shift @para;
  my $inglist = shift @para;

  if ($inglist) {
    $inglist =~ s/[\r\n]\s+[-;]/ /smg;

    #  #  my @results = ($inglist =~ /^(.*?)[\r\n]$/smg);
    #  my @results = ($inglist =~ /^(.*?)[\r\n]$/smg);
    #  # (^\s+-(.*?)[\n\r]$)?)/smg)
    #  foreach my $result (@results) {
    #    print "<<<$result>>>\n";
    #  }

    foreach my $ingrediant (split /\n/,$inglist) {
      if ($ingrediant =~ /^(.{7}).(..).(.*)[\n\r]/) {
	my $a = $1 || "";
	my $b = $2 || "";
	my $c = $3 || "";

	$self->Clean($a);
	$self->Clean($b);
	$self->Clean($c);

	my $ing = XML::Twig::Elt->new('ing');
	$ing->paste('last_child', $ingredients);

	my $amt = XML::Twig::Elt->new('amt');
	$amt->paste('last_child', $ing);

	my $qty = XML::Twig::Elt->new('qty');
	$qty->set_text($a);
	$qty->paste('last_child', $amt);

	my $unit = XML::Twig::Elt->new('unit');
	$unit->set_text($b);
	$unit->paste('last_child', $amt);

	my $item = XML::Twig::Elt->new('item');
	$item->set_text($c);
	$item->paste('last_child', $ing);
      }
    }
  }
  # parse out directions

  my $directions = XML::Twig::Elt->new('directions');
  $directions->paste('last_child', $recipe);

  foreach my $parag (@para) {
    my $sentences = get_sentences($parag);
    foreach my $sentence (@{$sentences}) {
      $sentence =~ s/\n/ /g;
      $sentence =~ s/\s+/ /g;
      chomp $sentence;
      my $step = XML::Twig::Elt->new('step');
      $step->set_text($sentence);
      $step->paste('last_child', $directions);
    }
  }
  # my $entirerecipe = $header;
  print $recipeml->sprint."\n";
}

sub Clean {
  my ($self) = (shift);
  $_[0] =~ s/^\s*//;
  $_[0] =~ s/\s*$//;
}

1;
