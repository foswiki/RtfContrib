#!/usr/bin/perl -w
BEGIN {
    unshift @INC, split( /:/, $ENV{FOSWIKI_LIBS} );
}
use Foswiki::Contrib::Build;

$build = new Foswiki::Contrib::Build('RtfContrib');
$build->build( $build->{target} );

