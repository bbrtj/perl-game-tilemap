package Game::TileMap::Role::Checks;

use v5.10;
use strict;
use warnings;

use Moo::Role;
use Mooish::AttributeBuilder -standard;

use Game::TileMap::Legend;

requires qw(
	size_x
	size_y
	coordinates
);

sub check_within_map
{
	my ($self, $x, $y) = @_;

	return $x >= 0 && $x < $self->size_x
		&& $y >= 0 && $y < $self->size_y
		&& $self->coordinates->[$x][$y] ne Game::TileMap::Legend::WALL_OBJECT;
}

sub check_can_be_accessed
{
	my ($self, $x, $y) = @_;

	return $x >= 0 && $x < $self->size_x
		&& $y >= 0 && $y < $self->size_y
		&& $self->coordinates->[$x][$y];
}


1;

