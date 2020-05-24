package Gourmet::Importer::MealMaster::Original;

use KBFS::Cache;

use Lingua::EN::Sentence qw( get_sentences add_acronyms );
use Lingua::EN::Splitter qw( paragraphs );
use XML::Twig;

use strict;
use Carp;

use vars qw/ $VERSION /;
$VERSION = '1.00';
use Class::MethodMaker
  new_with_init => 'new',
  get_set       => [ qw / Cache SourceDir TargetDir Twig / ];

sub init {
  my ($self,%args) = (shift,@_);
  $self->Cache(KBFS::Cache->new
	       (CacheType => $args{CacheType},
		CacheDir => $args{CacheDir}));
  $self->SourceDir($args{SourceDir});
  $self->TargetDir($args{TargetDir});
  if (! -d $self->TargetDir) {
    if (-f $self->TargetDir) {
      die "Cannot create recipe dir since there is file there.";
    } else {
      system "mkdir ".$self->TargetDir;
    }
  }
  $self->Twig(XML::Twig->new(pretty_print => 'indented'));
  $self->Populate;
  print $self->Cache->ExportMetadata;
}

sub Populate {
  my ($self,%args) = (shift,@_);
  my $query = "find ".$self->SourceDir;
  foreach my $file (split /\n/, `$query`) {
    chomp $file;
    if (-f $file) {
      $self->Cache->CacheNewItem(URI => $file);
    }
  }
}

sub ParseAll {
  my ($self,%args) = (shift,@_);
  foreach my $item ($self->Cache->ListContents) {
    my $query = "gunzip -c ".$item->Loc;
    my $contents = `$query`;
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

  # parse out ingrediants

  my $ingrediants = XML::Twig::Elt->new('ingrediants');
  $ingrediants->paste('last_child', $recipe);

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
	$ing->paste('last_child', $ingrediants);

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
  my $entirerecipe = $header;
  $entirerecipe .= $recipeml->sprint;
  $self->SaveRecipe($self->CleanTitle($titletext), $entirerecipe);
  if (0) {
    my $it = <>;
    $it = "";
  } else {
    print ".";
  }
}

sub Clean {
  my ($self) = (shift);
  $_[0] =~ s/^\s*//;
  $_[0] =~ s/\s*$//;
}

sub SaveRecipe {
  my ($self,$title,$contents) = (shift,shift,shift);
  if ($title) {
    my $file = $self->TargetDir."/".$title.".xml";
    my $filename = $self->RenameUniquely($file);
    my $OUT;
    open (OUT,">$filename") or
      die "Cannot open file: <<<".$filename.">>>.\n";
    print OUT $contents;
    close (OUT);
  }
}

sub CleanTitle {
  my ($self,$title) = (shift,shift);
  $title =~ s/\s+/-/g;
  $title =~ s/[^A-Za-z0-9-]//g;
  return $title;
}

sub RenameUniquely {
  my ($self,$filename) = (shift,shift);
  if (! -e $filename) {
    return $filename;
  } else {
    my $i = 0;
    my $header = $filename;
    $header =~ s/.xml$//;
    do {
      ++$i;
      $filename = "$header-$i.xml";
    } while (-e $filename);
    return $filename;
  }
}

1;
