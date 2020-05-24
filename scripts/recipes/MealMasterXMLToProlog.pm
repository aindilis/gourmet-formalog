package MealMasterXMLToProlog;

use KBS2::ImportExport;
use PerlLib::Collection;

use Data::Dumper;
use Lingua::EN::Sentence qw( get_sentences );
use XML::Simple;

use Try::Tiny;

use vars qw/ $VERSION /;
$VERSION = '1.00';
use Class::MethodMaker
  new_with_init => 'new',
  get_set       => [ qw / XS ImportExport / ];

sub init {
  my ($self,%args) = (shift,@_);
  # open connection to database, and open the gourmet database
  $self->XS
    (XML::Simple->new());
  $self->ImportExport
    (KBS2::ImportExport->new());
}

sub ParseAll {
  my ($self,%args) = @_;
  # print STDERR "$args{File}\n";
  # print STDERR "$args{Contents}\n";
  my $skip = 0;
  my $doc;
  try {
    $doc = $self->XS->XMLin($args{Contents});
  } catch {
    $skip = 1;
  };
  if (! $skip) {
    my $res1 = $self->ImportExport->Convert
      (
       InputType => 'Interlingua',
       Input => [$self->ParseRecipe(Doc => $doc)],
       OutputType => 'Prolog',
      );
    if ($res1->{Success}) {
      my $output = $res1->{Output}."\n";
      $output =~ s/_prolog_list/'_prolog_list'/sg;
      print $output;
    }
    print "\n\n";
  }
}

sub ParseRecipe {
  my ($self,%args) = @_;
  my $d = $args{Doc};
  print STDERR Dumper($d) if $UNIVERSAL::debug;

  # parse out
  my $system = 'mm';
  my $version = $d->{version};
  my $titletext = $d->{recipe}{head}{title};
  my $cats = $d->{recipe}{head}{categories}{cat};
  my $type0 = ref($cats);
  my @categories;
  if ($type0 eq "" and scalar $cats) {
    push @categories, $cats;
  } elsif ($type0 eq "ARRAY") {
    foreach my $cat (@$cats) {
      my $type1 = ref($cat);
      if ($type1 eq "" and scalar $cat) {
	push @categories, $cat;
      } elsif ($type0 eq "HASH") {
	# push @categories, $cat;
      }
    }
  }
  unshift @categories, '_prolog_list';

  my $yield = $d->{recipe}{head}{yield};
  my @ingredients;
  my @directions;
  my @additional;
  push @additional, ['v',$system,$version];
  push @additional, ['y',$yield];
  push @additional, ['c',\@categories];


  my $mying;
  my $ing = $d->{recipe}{ingredients}{ing};
  my $type2 = ref($ing);
  if ($type2 eq "HASH") {
    $mying = [$ing];
  } elsif ($type2 eq "ARRAY") {
    $mying = $ing;
  }

  foreach my $ing (@$mying) {
    my $myqty;
    my $qty = $ing->{amt}{qty};
    my $type3 = ref($qty);
    if ($type3 eq "" and scalar $qty) {
      $myqty = $qty;
    } elsif ($type3 eq "HASH") {
      $myqty = '';
    }

    my $myunit;
    my $unit = $ing->{amt}{unit};
    my $type5 = ref($unit);
    if ($type5 eq "" and scalar $unit) {
      $myunit = $unit;
    } elsif ($type5 eq "HASH") {
      $myunit = '';
    }

    push @ingredients, ['i',$myqty,$myunit,$ing->{item}];
  }
  my @steps;
  my $step = $d->{recipe}{directions}{step};
  my $type10 = ref($step);
  if ($type10 eq "" and scalar $step) {
    push @steps, $step;
  } elsif ($type10 eq "ARRAY") {
    @steps = @$step;
  }

  foreach my $step (@steps) {
    my $sentences = get_sentences($step);
    foreach my $sentence (@{$sentences}) {
      $sentence =~ s/\n/ /g;
      $sentence =~ s/\s+/ /g;
      chomp $sentence;
      push @directions, $sentence;
    }
  }

  return ['recipe',$titletext,['_prolog_list',@ingredients],['_prolog_list',@directions],['_prolog_list',@additional]];
}

1;
