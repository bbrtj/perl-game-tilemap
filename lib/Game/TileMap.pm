package Game::TileMap;

use v5.10;
use strict;
use warnings;

use Moo;
use Mooish::AttributeBuilder -standard;
use Storable qw(dclone);

use Game::TileMap::_Utils;

has param 'legend' => (

	# isa => InstanceOf ['Game::TileMap::Legend'],
);

has field 'coordinates' => (
	writer => -hidden,

	# isa => ArrayRef [ArrayRef [Int]],
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

	my @map_lines =
		reverse
		grep { /\S/ }
		map { Game::TileMap::_Utils::trim $_ }
		split "\n", $map_str
		;

	my @map;
	foreach my $line (@map_lines) {
		my @objects = map {
			$self->legend->objects->{$_} // die "Invalid map character $_"
		} split '', $line;

		push @map, \@objects;
	}

	return $self->from_array(\@map);
}

sub from_array
{
	my ($map_aref) = @_;
	my @map = @{$map_aref};

	my @map_size = (scalar $map[0], scalar @map);
	my %guide;

	my $line_num = 0;
	foreach my $line (@map) {
		die "invalid map size on line $line_num"
			if @{$line} != $map_size[0];

		my $col_num = 0;
		for my $obj (@{$line}) {
			push @{$guide{$self->legend->get_class_of_object($obj)}}, [$obj, $col_num, $line_num];

			$col_num += 1;
		}

		$line_num += 1;
	}

	$self->_set_coordinates(\@map);
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
	$with //= '@';

	my @lines;
	my %characters_rev = map {
		$self->legend->objects->{$_} => $_
	} keys $self->legend->objects->%*;

	my $mark = \undef;
	my $coordinates = $self->coordinates;
	if ($mark_positions) {
		$coordinates = dclone $coordinates;

		foreach my $pos (@{$mark_positions}) {
			$coordinates->[$pos->[1]][$pos->[0]] = $mark;
		}
	}

	foreach my $coords ($coordinates->@*) {
		push @lines, join '', map {
			$_ eq $mark ? $with : $characters_rev{$_}
		} $coords->@*;
	}

	return join "\n", @lines;
}

1;

