package Game::TileMap::Legend;

use v5.10;
use strict;
use warnings;

use Moo;
use Mooish::AttributeBuilder -standard;

use constant TERRAIN_CLASS => 'terrain';
use constant WALL_OBJECT => '';
use constant VOID_OBJECT => '0';

has field 'classes' => (
	# isa => HashRef [ ArrayRef [StrLength [1, 1]]],
	default => sub { {} },
);

has field '_object_map' => (
	# isa => HashRef [Str],
	lazy => 1,
);

has field 'objects' => (
	# isa => HashRef [Any],
	default => sub { {} },
);

sub _build_object_map
{
	my $self = shift;
	my %classes = %{$self->classes};
	my %objects = %{$self->objects};
	my %map_reverse;

	foreach my $class (keys %classes) {
		my @objects = map { $objects{$_} } @{$classes{$class}};
		foreach my $obj (@objects) {
			$map_reverse{$obj} = $class;
		}
	}

	return \%map_reverse;
}

sub get_class_of_object
{
	my ($self, $obj) = @_;

	return $self->_object_map->{$obj}
		// die "no such object $obj";
}

sub add_wall
{
	my ($self, $character) = @_;

	return $self->add_terrain($character, WALL_OBJECT);
}

sub add_void
{
	my ($self, $character) = @_;

	return $self->add_terrain($character, VOID_OBJECT);
}

sub add_terrain
{
	my ($self, $character, $object) = @_;

	return $self->add_object(TERRAIN_CLASS, $character, $object);
}

sub add_object
{
	my ($self, $class, $character, $object) = @_;

	die "character $character is already used"
		if exists $self->objects->{$character};

	push @{$self->classes->{$class}}, $character;
	$self->objects->{$character} = $object;

	return $self;
}

1;

