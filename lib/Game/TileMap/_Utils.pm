package Game::TileMap::_Utils;

use v5.10;
use strict;
use warnings;

sub trim
{
	my $str = shift;
	$str =~ s/\A \s+ | \s+ \z//gx;
	return $str;
}

1;

