package Game::TileMap::Tile;

use v5.10;
use strict;
use warnings;

use Moo;
use Mooish::AttributeBuilder -standard;

has param ['x', 'y'] => (

	# isa => PositiveInt,
);

has param 'contents' => (
	writer => 1,

	# isa => Any,
);

has field 'type' => (
	default => sub { shift->contents },

	# isa => Any,
);

1;

