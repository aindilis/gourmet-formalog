package Gourmet::Importer::MealMaster::NL2PDDL;

use Capability::Tokenize;
use Lingua::EN::Sentence qw( get_sentences add_acronyms );
use Lingua::EN::Splitter qw( paragraphs );
use PerlLib::SwissArmyKnife;
use System::LinkParser;
use UniLang::Util::TempAgent;
use XML::Twig;

use Data::Dumper;
use File::Slurp;
use IO::File;

use Class::MethodMaker
  new_with_init => 'new',
  get_set       => [ qw / MyTempAgent Twig UnitsOfMeasure MyLinkParser / ];

sub init {
  my ($self,%args) = @_;
  $self->MyTempAgent
    (UniLang::Util::TempAgent->new);
  $self->Twig(XML::Twig->new(pretty_print => 'indented'));
  my $c = read_file("/var/lib/myfrdcsa/codebases/internal/gourmet/Gourmet/Importer/units-of-measure");
  my @lines = split /\n/,$c;
  shift @lines;
  $self->UnitsOfMeasure({});
  foreach my $line (@lines) {
    my ($code,$fractions,$half,$singular,$plural) = split /\t/,$line;
    $self->UnitsOfMeasure->{$code}->{Fractions} = $fractions;
    $self->UnitsOfMeasure->{$code}->{Half} = $half;
    $self->UnitsOfMeasure->{$code}->{Singular} = $singular;
    $self->UnitsOfMeasure->{$code}->{Plural} = $plural;
  }
  $self->MyLinkParser
    (System::LinkParser->new);
}

sub isarrayref {
  my ($item) = @_;
  my $ref = ref $item;
  return $ref eq "ARRAY";
}

sub ishashref {
  my ($item) = @_;
  my $ref = ref $item;
  return $ref eq "HASH";
}

sub Formalize {
  my ($self,$text) = @_;
  print "Start\n";
  $text =~ s/[^[:graph:]]/ /g;
  if ($text =~ /\w+/) {
    if (0) {
      my $message = $self->MyTempAgent->MyAgent->QueryAgent
	(
	 Receiver => "Formalize2",
	 Data => {
		  _DoNotLog => 1,
		  Command => "formalize",
		  OutputType => "KIF String",
		  Text => $text,
		 },
	);
      if (exists $message->Data->{Results}) {
	if (ishashref($message->Data->{Results}) and
	    isarrayref($message->Data->{Results}->{Results}) and
	    ishashref($message->Data->{Results}->{Results}->[0]) and
	    $message->Data->{Results}->{Results}->[0]->{Success}) {
	  return "$text\n".$message->Data->{Results}->{Results}->[0]->{Output};
	}
      }
    }
    print $text."\n";
  }
  return $text;
}

sub Cyc {
  my ($self,%args) = @_;
  my $item = $args{Item};
  $item =~ s/[^[:graph:]]/ /g;
  if ($item =~ /\w+/) {
    my $message = $self->MyTempAgent->MyAgent->QueryAgent
      (
       Receiver => "Cyc",
       Contents => "(ps-get-cycls-for-np \"$item\")",
       Data => {
		_DoNotLog => 1,
	       },
      );
    return $message;
  }
}

sub ParseContents {
  my ($self,%args) = @_;
  foreach my $recipe (split /---------- Recipe via Meal-Master/, $args{Contents}) {
    print Dumper($self->ParseRecipe(Recipe => $recipe));
  }
}

sub ParseRecipe {
  my ($self,%args) = @_;
  my $recipecontents = $args{Recipe};

  my @combined;

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

	my $bprime;
	if (! exists $self->UnitsOfMeasure->{$b}) {
	  # print "NO $b\n";
	  $bprime = $b;
	} else {
	  if ($a =~ /^\s*1$/) {
	    $bprime = $self->UnitsOfMeasure->{$b}->{Singular};
	  } elsif ($a =~ /^\s*1\/2$/) {
	    $bprime = $self->UnitsOfMeasure->{$b}->{Half};
	  } elsif ($a =~ /^\s*(\d+)\/(\d+)$/) {
	    $bprime = $self->UnitsOfMeasure->{$b}->{Fractions};
	  } elsif ($a =~ /^\s*(\d+)$/) {
	    $bprime = $self->UnitsOfMeasure->{$b}->{Plural};
	  } elsif ($a =~ /^\s*(\d+) (\d+)\/(\d+)$/) {
	    $bprime = $self->UnitsOfMeasure->{$b}->{Plural};
	  } else {
	    print "HUH? <<<$a>>> <<<$b>>> <<<$c>>>\n";
	  }
	}
	my $string = "$a $bprime $c";
	#print "$string\n";

	# my $res = $self->Cyc(Item => $string);
	# print $res->Data->{Result}."\n";


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

	$item->set_text($string);
	$item->paste('last_child', $ing);

	push @combined, ["You need", $string];
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
      # analyze the sentence here

      my $step = XML::Twig::Elt->new('step');
      $step->set_text($sentence);
      $step->paste('last_child', $directions);

      push @combined, ["You should",$sentence];
    }
  }
  my $entirerecipe = $header;
  $entirerecipe .= $recipeml->sprint;

  my $res3 = $self->ProcessCombined(Combined => \@combined);
  print Dumper($res3);
  my $fh = IO::File->new();
  my $filename = $titletext;
  $filename =~ s/[^a-zA-Z]+//g;
  $fh->open("> /var/lib/myfrdcsa/codebases/internal/gourmet/data/nl2pddl/sample-converted-recipes/$filename");
  print $fh join("  ",@$res3);
  $fh->close();
  return $entirerecipe;
}

sub Clean {
  my ($self) = (shift);
  $_[0] =~ s/^\s*//;
  $_[0] =~ s/\s*$//;
}

sub CleanTitle {
  my ($self,$title) = @_;
  $title =~ s/\s+/-/g;
  $title =~ s/[^A-Za-z0-9-]//g;
  return $title;
}

sub GetInfoAboutWord {
  my ($self,%args) = @_;
  # this is a really stupid function
  my $w = $args{Word};
  my $c = "wn ".shell_quote($w)." -over";
  my $r =`$c`;
  my $pos = "";
  my $item = "";
  my $hash = {};
  my $sensecount;
  my $desc;
  my $items = {};
  foreach my $line (split /\n/, $r) {
    if ($line =~ /^Overview of (\w+) (.+)$/) {
      if (scalar keys %$hash) {
	my %copy = %$hash;
	$items->{$args{Word}}->{$pos}->{$item} = \%copy;
	$hash = {};
      }
      $pos = $1;
      $item = $2;
    } elsif ($line =~ /^The (\w+) (.+?) has (\d+) senses \((.+?)\)$/) {
      $sensecount = $3;
      $desc = $4;
      $hash = {
	       Desc => $desc,
	       Count => $sensecount,
	      };
    }
  }
  if (scalar keys %$hash) {
    $items->{$args{Word}}->{$pos}->{$item} = $hash;
  }
  # print Dumper($items);
  return $items;
}

sub ProcessCombined {
  my ($self,%args) = @_;
  # should replace this with a proper data-driven method, well, for
  # now just pretend that it got it all and send to the NLP system.

  my $combined = $args{Combined};
  my @final;
  my $filters = {
		 LinkParser => 1,
		 Verbs => 1,
		};
  foreach my $entry (@$combined) {
    if ($entry->[0] eq "You should") {
      my $sentence = $entry->[1];

      $sentence =~ s/^[^a-zA-Z0-9]+//;
      my $res = tokenize_treebank($sentence);
      my @tokens = split /\s+/, $res;
      $tokens[0] = lc($tokens[0]);

      my $rejections = 0;

      if ($filters->{LinkParser}) {
	my $newsentence = "You should ".join(" ",@tokens);
	my $res3 = $self->MyLinkParser->CheckSentence
	  (
	   Sentence => $newsentence,
	  );
	if ($res3 == 0) {
	  ++$rejections;
	}
      }
      if ($filters->{Verbs}) {
	my $res2 = $self->GetInfoAboutWord(Word => $tokens[0]);
	if (! exists $res2->{$tokens[0]}->{verb}) {
	  # print "No verb senses\n";
	  # check the part of speech of the first word, do this by processing the sentence with a parser
	  ++$rejections;
	} elsif (! exists $res2->{$tokens[0]}->{verb}->{$tokens[0]}) {
	  # print "Changed verb form\n";
	  # more wrong words: past tense, e.g. posted, preposition, From (except, from time to time, beat an egg, etc)
	  ++$rejections;
	}
      }
      if ($tokens[-1] eq ".") {
	pop @tokens;
      }
      my $resultstring = "You should ".join(" ",@tokens).".";
      if ($rejections < 2) {
	# wrong words: it, best, this, "A. K.", the, a, 
	push @final, $resultstring;
      } else {
	print "Rejected: $resultstring\n";
      }
    } elsif ($entry->[0] eq "You need") {
      push @final, "You need ".$entry->[1].".";
    }
  }
  return \@final;
}

1;
