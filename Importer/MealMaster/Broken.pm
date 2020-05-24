package Gourmet::Importer::MealMaster::Broken;

use UniLang::Util::TempAgent;

use Lingua::EN::Sentence qw( get_sentences add_acronyms );
use Lingua::EN::Splitter qw( paragraphs );

use Data::Dumper;

use Class::MethodMaker
  new_with_init => 'new',
  get_set       => [ qw / MyTempAgent / ];

sub init {
  my ($self,%args) = @_;
  $self->MyTempAgent
    (UniLang::Util::TempAgent->new);
}

sub ParseContents {
  my ($self,%args) = @_;
  foreach my $recipe (split /---------- Recipe via Meal-Master/, $args{Contents}) {
    print Dumper($self->ParseRecipe(Recipe => $recipe));
  }
}

sub ParseRecipe {
  my ($self,%args) = @_;
  print "Recipe...\n";
  my $recipecontents = $args{Recipe};

  my $data;
  foreach my $format (qw / Title: Categories: Yield: From: Date: /, "Recipe By:") {
    if ($recipecontents =~ /.*($format)\s*(.*?)[\r\n]*$/m) {
      $data->{$format} = $2;
    }
  }

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

    print "Ingrediants...\n";
    foreach my $ingrediant (split /\n/,$inglist) {
      if ($ingrediant =~ /^(.{7}).(..).(.*)[\n\r]/) {
	my $a = $1 || "";
	my $b = $2 || "";
	my $c = $3 || "";

	$self->Clean($a);
	$self->Clean($b);
	$self->Clean($c);

	# qty, unit, item
	my $formalized = $self->Formalize("You have ".$c);
      }
    }
  }
  print "Instructions...\n";
  foreach my $parag (@para) {
    my $sentences = get_sentences($parag);
    foreach my $sentence (@{$sentences}) {
      $sentence =~ s/\n/ /g;
      $sentence =~ s/\s+/ /g;
      chomp $sentence;
      # analyze the sentence here

      my $formalized = $self->Formalize("You should ".$sentence);
    }
  }
}

sub isarrayref {
  my ($item) = @_;
  my $ref = ref $item;
  return $ref eq "ARRAY";
}

sub Formalize {
  my ($self,$text) = @_;
  # my $pre = $text;
  $text =~ s/[^[:graph:]]/ /g;
  #   if ($pre ne $text) {
  #     print Dumper([$pre,$text]);
  #     exit(0);
  #   }
  if ($text =~ /\w+/) {
    print "\t".$text."\n";
    my $message = $self->MyTempAgent->MyAgent->QueryAgent
      (Agent => "Formalize",
       Contents => $text);
    if (exists $message->Data->{Results}) {
      if (isarrayref($message->Data->{Results}) and
	  isarrayref($message->Data->{Results}->[0]) and
	  isarrayref($message->Data->{Results}->[0]->[1])) {
	print "\t".join ("  ",@{$message->Data->{Results}->[0]->[1]})."\n\n";
      }
    }
  }
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

1;
