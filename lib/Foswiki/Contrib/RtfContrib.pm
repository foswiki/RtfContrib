# Plugin for Foswiki Collaboration Platform, http://foswiki.org/
#
# Copyright (C) 2007-2009 MichaelDaum http://michaeldaumconsulting.com
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version. For
# more details read LICENSE in the root of this distribution.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

package Foswiki::Contrib::RtfContrib;
use strict;

use vars qw($VERSION $RELEASE);

$VERSION = '$Rev$';
$RELEASE = 'v1.00';

################################################################################
sub export {
  my $session = shift;

  $Foswiki::Plugins::SESSION = $session;
  my $query = Foswiki::Func::getCgiQuery();
  my $converterName = $query->param('converter');
  my $impl;
  if ($converterName) {
    $impl = 
      $Foswiki::cfg{RtfContrib}{Converters}{$converterName} ||
      $Foswiki::cfg{RtfContrib}{Converters}{$converterName} ;
  }

  # create a new converter
  my $converter = newConverter($session, $impl);

  # generate the rtf
  my ($result, $errorMsg) = $converter->genRtf();

  if ($errorMsg) {
    $session->writeCompletePage("ERROR: $errorMsg\n\n", 'view');
    return;
  } 

  # write the rtf file
  $converter->cacheRtf($result);
  
  # prepair the answer to the request
  my $viewNow = $query->param('view') || '';
  $viewNow = ($viewNow eq 'on')?1:0;

  if ($viewNow) {
    $session->writeCompletePage($result, 'rtf', 'application/rtf');
  } else {
    my $url = 
      $session->getScriptUrl(1, 'oops', $converter->{web}, $converter->{topic},
        template => 'oopsrtf',
        param1 => $converter->getUrlName(),
      );

    $session->redirect($url);
  }
}

################################################################################
sub newConverter {
  my ($session, $impl) = @_;

  $impl ||= $Foswiki::cfg{RtfContrib}{DefaultConverter} 
    || $Foswiki::cfg{RtfContrib}{DefaultConverter}
    || 'Foswiki::Contrib::RtfContrib::Converter';

  #print STDERR "impl=$impl\n";

  eval 'use '.$impl;
  die $@ if $@;

  return $impl->new($session);
}

1;
