package Game::TileMap::Legend;

use v5.10;
use strict;
use warnings;

use Moo;
use Mooish::AttributeBuilder -standard;
use Carp qw(croak);

use constant TERRAIN_CLASS => 'terrain';
use constant WALL_OBJECT => '';
use constant VOID_OBJECT => '0';

has field 'classes' => (
	default => sub { {} },

	# isa => HashRef [ ArrayRef [Str]],
);

has param 'characters_per_tile' => (
	default => sub { 1 },

	# isa => PositiveInt,
);

has field '_object_map' => (
	lazy => 1,

	# isa => HashRef [Str],
);

has field 'objects' => (
	default => sub { {} },

	# isa => HashRef [Any],
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
		// croak "no such object '$obj' in map legend";
}

sub add_wall
{
	my ($self, $marker) = @_;

	return $self->add_terrain($marker, WALL_OBJECT);
}

sub add_void
{
	my ($self, $marker) = @_;

	return $self->add_terrain($marker, VOID_OBJECT);
}

sub add_terrain
{
	my ($self, $marker, $object) = @_;

	return $self->add_object(TERRAIN_CLASS, $marker, $object);
}

sub add_object
{
	my ($self, $class, $marker, $object) = @_;

	croak "marker '$marker' is already used"
		if exists $self->objects->{$marker};

	croak "marker '$marker' has wrong length"
		unless length $marker == $self->characters_per_tile;

	push @{$self->classes->{$class}}, $marker;
	$self->objects->{$marker} = $object;

	return $self;
}

1;

