package Game::TileMap;

use v5.10;
use strict;
use warnings;

use Moo;
use Mooish::AttributeBuilder -standard;
use Storable qw(dclone);
use Carp qw(croak);

use Game::TileMap::Legend;
use Game::TileMap::Tile;
use Game::TileMap::_Utils;

has param 'legend' => (

	# isa => InstanceOf ['Game::TileMap::Legend'],
);

has field 'coordinates' => (
	writer => -hidden,

	# isa => ArrayRef [ArrayRef [Any]],
);

has field 'size_x' => (
	writer => -hidden,

	# isa => PositiveInt,
);

has field 'size_y' => (
	writer => -hidden,

	# isa => PositiveInt,
);

has field '_guide' => (
	writer => 1,

	# isa => HashRef [ArrayRef [Tuple [Any, PositiveInt, PositiveInt]]],
);

with qw(
	Game::TileMap::Role::Checks
	Game::TileMap::Role::Helpers
);

sub new_legend
{
	my $self = shift;

	return Game::TileMap::Legend->new(@_);
}

sub BUILD
{
	my ($self, $args) = @_;

	if ($args->{map}) {
		$self->from_string($args->{map})
			if !ref $args->{map};

		$self->from_array($args->{map})
			if ref $args->{map} eq 'ARRAY';
	}
}

sub from_string
{
	my ($self, $map_str) = @_;
	my $per_tile = $self->legend->characters_per_tile;

	my @map_lines =
		reverse
		grep { /\S/ }
		map { Game::TileMap::_Utils::trim $_ }
		split "\n", $map_str
		;

	my @map;
	foreach my $line (@map_lines) {
		my @objects;
		while (length $line) {
			my $marker = substr $line, 0, $per_tile, '';
			push @objects, ($self->legend->objects->{$marker} // croak "Invalid map marker '$marker'");
		}

		push @map, \@objects;
	}

	return $self->from_array(\@map);
}

sub from_array
{
	my ($self, $map_aref) = @_;
	my @map = @{$map_aref};

	my @map_size = (scalar @{$map[0]}, scalar @map);
	my %guide;

	my @new_map;
	foreach my $line (0 .. $#map) {
		croak "invalid map size on line $line"
			if @{$map[$line]} != $map_size[0];

		for my $col (0 .. $#{$map[$line]}) {
			my $prev_obj = $map[$line][$col];
			my $obj = Game::TileMap::Tile->new(contents => $prev_obj, x => $col, y => $line);

			$new_map[$col][$line] = $obj;
			push @{$guide{$self->legend->get_class_of_object($prev_obj)}}, $obj;
		}
	}

	$self->_set_coordinates(\@new_map);
	$self->_set_size_x($map_size[0]);
	$self->_set_size_y($map_size[1]);
	$self->_set_guide(\%guide);

	return $self;
}

sub to_string
{
	return shift->to_string_and_mark;
}

sub to_string_and_mark
{
	my ($self, $mark_positions, $with) = @_;
	$with //= '@' x $self->legend->characters_per_tile;

	my @lines;
	my %markers_rev = map {
		$self->legend->objects->{$_} => $_
	} keys %{$self->legend->objects};

	my $mark = \undef;
	my $coordinates = $self->coordinates;
	if ($mark_positions) {
		$coordinates = dclone $coordinates;

		foreach my $pos (@{$mark_positions}) {
			$coordinates->[$pos->[0]][$pos->[1]] = $mark;
		}
	}

	foreach my $pos_x (0 .. $#$coordinates) {
		foreach my $pos_y (0 .. $#{$coordinates->[$pos_x]}) {
			my $obj = $coordinates->[$pos_x][$pos_y];
			$lines[$pos_y][$pos_x] = $obj eq $mark ? $with : $markers_rev{$obj->type};
		}
	}

	return join "\n",
		reverse
		map { join '', @{$_} } @lines;
}

1;

