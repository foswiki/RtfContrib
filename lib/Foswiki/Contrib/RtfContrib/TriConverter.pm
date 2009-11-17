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

package Foswiki::Contrib::RtfContrib::TriConverter;

use strict;
use Foswiki::Contrib::RtfContrib::Converter ();
use Foswiki::Plugins::DBCachePlugin::Core ();
use Foswiki::Plugins::EmployeePortalPlugin::Core ();
use Foswiki::Plugins::ClassificationPlugin::Core ();
use Foswiki::Attrs ();
use vars qw(%strings $debug);


%strings = (
  DE => {
    'description' => 'Projektumfang',
    'tasks' => 'Aufgaben',
    'technologies' => 'Technologien',
    'tools' => 'Tools',
    'skills' => 'Kenntnisse',
    'MainFocus' => 'Schwerpunkte',
    'Programming' => 'Programmiersprachen',
    'Operating Systems' => 'Betriebssysteme',
    'Databases' => 'Datenbanken',
    'Methods' => 'Methoden/Werkzeuge',
    'Communication' => 'Kommunikation',
    'Middleware' => 'Middleware',
    'Frameworks' => 'Frameworks'
  },
  EN => {
    'description' => 'Description',
    'tasks' => 'Role',
    'technologies' => 'Technologies',
    'tools' => 'Tools',
    'skills' => 'Skills',
    'MainFocus' => 'Main Focus',
    'Programming' => 'Programming Languages',
    'Operating Systems' => 'Operating Systems',
    'Databases' => 'Databases',
    'Methods' => 'Methods/Tools',
    'Communication' => 'Communication',
    'Middleware' => 'Middleware',
    'Frameworks' => 'Frameworks'
  },
  FR => {
    'description' => 'Description',
    'tasks' => 'R\\\'f4le',
    'technologies' => 'Technologies',
    'tools' => 'Tools',
    'skills' => 'Connaissances',
    'MainFocus' => 'Points forts',
    'Programming' => 'Langues de programmation',
    'Operating Systems' => 'Syst\\\'e8me d\'exploitation',
    'Databases' => 'Base de donn\\\'e9es',
    'Methods' => 'M\\\'e9thodes',
    'Communication' => 'Communication',
    'Middleware' => 'Middleware',
    'Frameworks' => 'Frameworks'
  },
);

@Foswiki::Contrib::RtfContrib::TriConverter::ISA = ("Foswiki::Contrib::RtfContrib::Converter");

$debug = $Foswiki::cfg{RtfContrib}{Debug} || 0;

################################################################################
# static
sub writeDebug {
  print STDERR "TriConverter - $_[0]\n" if $debug;
}

###############################################################################
sub new {
  my ($class, $session) = @_;

  my $this = $class->SUPER::new($session);

  return $this;
}

################################################################################
sub processTemplate {
  my $this = shift;

  $this->SUPER::processTemplate(@_);  
  $_[0] =~ s/\%JOBSTABLE%/$this->handleJobsTable()/ge;
  $_[0] =~ s/\%JOBSTABLE\\{(.*?)\\}%/$this->handleJobsTable($1)/ge;
  $_[0] =~ s/\%PROJECTS%/$this->handleProjects()/ge;
  $_[0] =~ s/\%PROJECTS\\{(.*?)\\}%/$this->handleProjects($1)/ge;
  $_[0] =~ s/\%SKILLSTABLE%/$this->handleSkills()/ge;
  $_[0] =~ s/\%SKILLSTABLE\\{(.*?)\\}%/$this->handleSkills($1)/ge;
  $_[0] =~ s/\%EDUCATIONTABLE%/$this->handleEducationTable()/ge;
  $_[0] =~ s/\%EDUCATIONTABLE\\{(.*?)\\}%/$this->handleEducationTable($1)/ge;
}

################################################################################
sub handleJobsTable {
  my ($this, $params) = @_;

  $params ||= '';
  writeDebug("handleJobsTable($params)");
  $params = new Foswiki::Attrs($params);
  my $theLang = $params->{lang} || $params->{language} || 'DE';
  $theLang = uc($theLang);
  my $theTopic = $params->{topic} || $this->{topic}.'CVJobs'.$theLang;
  my $theHeader = $params->{header} || '';
  my $theFooter = $params->{footer} || '';

  # get jobs topic
  my $theWeb = $this->{web};
  ($theWeb, $theTopic) = Foswiki::Func::normalizeWebTopicName($theWeb, $theTopic);
  my $db = $this->{db};
  if ($theWeb ne $this->{web}) {
    $db = Foswiki::Plugins::DBCachePlugin::Core::getDB($theWeb);
  }

  my $topicObj = $this->{db}->fastget($theTopic);
  return '' unless $topicObj; # not found

  # process jobs table
  my $result = '{\pard'."\n";
  my $temp = $topicObj->fastget('_sectiondefault');
  my $isFirst = 1;
  my $nrRows = 0;
  while ($temp =~ /\n\|\s*(.*?)\s*\|\s*(.*?)\s*\|\s*(.*?)\s*\|\s*(.*?)\s*\|/g) {
    $nrRows++;
    next if $nrRows == 1; # skip table header

    my $cell1 = $this->tml2rtf($1);
    my $cell2 = $this->tml2rtf($2);
    my $cell3 = $this->tml2rtf($3);
    my $cell4 = $this->tml2rtf($4);
    strip($cell1);
    strip($cell2);
    strip($cell3);
    strip($cell4);
    writeDebug("found jobs row '$cell1', '$cell2', '$cell3', '$cell4'");
    unless ($cell1 || $cell2 || $cell3 || $cell4) { # skipp empty rows
      $nrRows--;
      next;
    }

    $result .= 
      '\trowd'."\n".
      '\ts24\trgaph108\trleft0'.
      '\trbrdrt\brdrs\brdrw15'.
      '\trbrdrl\brdrs\brdrw15'.
      '\trbrdrb\brdrs\brdrw15'.
      '\trbrdrr\brdrs\brdrw15'.
      '\trbrdrh\brdrs\brdrw15'.
      '\trbrdrv\brdrs\brdrw15'.
      '\trftsWidth3\trwWidth9127\trftsWidthB3\trftsWidthA3'.
      '\trautofit1'.
      '\trpaddl108\trpaddr108'.
      '\trpaddfl3\trpaddft3'.
      '\trpaddfb3\trpaddfr3'.
      '\tbllkhdrrows\tbllkhdrcols'.
      '\tbllklastrow\tbllklastcol'.
      '\tblind94\tblindtype3'.
      '\clvertalt'.
      '\clbrdrt\brdrs\brdrw15'.
      '\clbrdrl\brdrs\brdrw15'.
      '\clbrdrb\brdrs\brdrw15'.
      '\clbrdrr\brdrs\brdrw15'.
      '\cltxlrtb\clftsWidth3\clwWidth1668\clshdrawnil'.
      '\cellx1654'.
      '\clvertalt'.
      '\clbrdrt\brdrs\brdrw15'.
      '\clbrdrl\brdrs\brdrw15'.
      '\clbrdrb\brdrs\brdrw15'.
      '\clbrdrr\brdrs\brdrw15'.
      '\cltxlrtb\clftsWidth3\clwWidth5103\clshdrawnil'.
      '\cellx6757'.
      '\clvertalt'.
      '\clbrdrt\brdrs\brdrw15'.
      '\clbrdrl\brdrs\brdrw15'.
      '\clbrdrb\brdrs\brdrw15'.
      '\clbrdrr\brdrs\brdrw15'.
      '\cltxlrtb\clftsWidth3\clwWidth2356\clshdrawnil'.
      '\cellx9113'.
      '\pard\plain'.
      '\ltrpar\ql\li0\ri0\widctlpar'.
      '\intbl'."\n".
      '{\af0\cs30\f37\fs24 '.$cell1.'\par\cell}'."\n".
      '{\af0\cs30\f37\fs24 '.$cell3.':\par}{\af0\cs33\f37\fs20 '.$cell4.'\par\cell}'."\n".
      '{\af0\cs30\f37\fs24 '.$cell2.'\par\cell}'."\n".
      '\row'."\n";
  }
  $result .= '}'."\n";
  #writeDebug("result=$result");

  return ($nrRows>1)?$theHeader.$result.$theFooter:'';
}

################################################################################
sub handleEducationTable {
  my ($this, $params) = @_;

  $params ||= '';
  writeDebug("handleEducationTable($params)");
  $params = new Foswiki::Attrs($params);
  my $theLang = $params->{lang} || $params->{language} || 'DE';
  $theLang = uc($theLang);
  my $theTopic = $params->{topic} || $this->{topic}.'CVEducation'.$theLang;
  my $theHeader = $params->{header} || '';
  my $theFooter = $params->{footer} || '';

  # get education topic
  my $theWeb = $this->{web};
  ($theWeb, $theTopic) = Foswiki::Func::normalizeWebTopicName($theWeb, $theTopic);
  my $db = $this->{db};
  if ($theWeb ne $this->{web}) {
    $db = Foswiki::Plugins::DBCachePlugin::Core::getDB($theWeb);
  }

  my $topicObj = $this->{db}->fastget($theTopic);
  return '' unless $topicObj; # not found

  # process education table
  my $result = '{\pard'."\n";
  my $temp = $topicObj->fastget('_sectiondefault');
  my $isFirst = 1;
  my $nrRows = 0;
  while ($temp =~ /\n\|\s*(.*?)\s*\|\s*(.*?)\s*\|\s*(.*?)\s*\|/g) {
    $nrRows++;
    next if $nrRows == 1; # skip table header

    my $cell1 = $this->tml2rtf($1);
    my $cell2 = $this->tml2rtf($2);
    my $cell3 = $this->tml2rtf($3);
    strip($cell1);
    strip($cell2);
    strip($cell3);
    writeDebug("found education row '$cell1', '$cell2', '$cell3'");
    unless ($cell1 || $cell2 || $cell3 ) { # skipp empty rows
      $nrRows--;
      next;
    }

    $result .= 
      '\trowd'."\n".
      '\ts24\trgaph108\trleft0'.
      '\trbrdrt\brdrs\brdrw15'.
      '\trbrdrl\brdrs\brdrw15'.
      '\trbrdrb\brdrs\brdrw15'.
      '\trbrdrr\brdrs\brdrw15'.
      '\trbrdrh\brdrs\brdrw15'.
      '\trbrdrv\brdrs\brdrw15'.
      '\trftsWidth3\trwWidth9127\trftsWidthB3\trftsWidthA3'.
      '\trautofit1'.
      '\trpaddl108\trpaddr108'.
      '\trpaddfl3\trpaddft3'.
      '\trpaddfb3\trpaddfr3'.
      '\tbllkhdrrows\tbllkhdrcols'.
      '\tbllklastrow\tbllklastcol'.
      '\tblind94\tblindtype3'.
      '\clvertalt'.
      '\clbrdrt\brdrs\brdrw15'.
      '\clbrdrl\brdrs\brdrw15'.
      '\clbrdrb\brdrs\brdrw15'.
      '\clbrdrr\brdrs\brdrw15'.
      '\cltxlrtb\clftsWidth3\clwWidth1668\clshdrawnil'.
      '\cellx1654'.
      '\clvertalt'.
      '\clbrdrt\brdrs\brdrw15'.
      '\clbrdrl\brdrs\brdrw15'.
      '\clbrdrb\brdrs\brdrw15'.
      '\clbrdrr\brdrs\brdrw15'.
      '\cltxlrtb\clftsWidth3\clwWidth5103\clshdrawnil'.
      '\cellx6757'.
      '\clvertalt'.
      '\clbrdrt\brdrs\brdrw15'.
      '\clbrdrl\brdrs\brdrw15'.
      '\clbrdrb\brdrs\brdrw15'.
      '\clbrdrr\brdrs\brdrw15'.
      '\cltxlrtb\clftsWidth3\clwWidth2356\clshdrawnil'.
      '\cellx9113'.
      '\pard\plain'.
      '\ltrpar\ql\li0\ri0\widctlpar'.
      '\intbl'."\n".
      '{\af0\cs30\f37\fs24 '.$cell1.'\par\cell}'."\n".
      '{\af0\cs30\f37\fs24 '.$cell2.'\par\cell}'."\n".
      '{\af0\cs30\f37\fs24 '.$cell3.'\par\cell}'."\n".
      '\row'."\n";
  }
  $result .= '}'."\n";
  #writeDebug("result=$result");

  return ($nrRows>1)?$theHeader.$result.$theFooter:'';
}

################################################################################
sub handleSkills {
  my ($this, $params) = @_;

  $params ||= '';
  writeDebug("handleSkills($params)");
  $params = new Foswiki::Attrs($params);
  my $theLang = $params->{lang} || $params->{language} || 'DE';
  my $theHeader = $params->{header} || '';
  my $theFooter = $params->{footer} || '';
  my $theTopic = $params->{topic} || $this->{topic};
  my $theWeb = $params->{web} || $this->{web};

  ($theWeb, $theTopic) = Foswiki::Func::normalizeWebTopicName($theWeb, $theTopic);

  writeDebug("theWeb=$theWeb, theTopic=$theTopic");

  my $db = $this->{db};
  if ($theWeb ne $this->{web}) {
    $db = Foswiki::Plugins::DBCachePlugin::Core::getDB($theWeb);
  }

  my $topicObj = $db->fastget($theTopic);
  return '' unless $topicObj;

  my $formName = $topicObj->fastget('form');
  return '' unless $formName;

  my $formObj = $topicObj->fastget($formName);
  return '' unless $formObj;

  my $skillsString = translate($theLang, 'skills');
  my $result = <<'HERE';
{\pagebb $skillsString:\par \ltrrow}
\trowd\ts24\trgaph108\trleft0
\trftsWidth3\trwWidth9072\trftsWidthB3\trftsWidthA3
\trautofit1
\trpaddl108\trpaddb397\trpaddr108\trpaddfl3\trpaddft3\trpaddfb3\trpaddfr3
\tblrsid11032946\tbllkhdrrows\tbllklastrow\tbllkhdrcols\tbllklastcol\tblind108\tblindtype3 
\clvertalt\clbrdrt\brdrtbl 
\clbrdrl\brdrtbl 
\clbrdrb\brdrtbl 
\clbrdrr\brdrtbl 
\cltxlrtb\clftsWidth3\clwWidth3260\clshdrawnil 
\cellx3260\clvertalt
\clbrdrt\brdrtbl 
\clbrdrl\brdrtbl 
\clbrdrb\brdrtbl 
\clbrdrr\brdrtbl 
\cltxlrtb\clftsWidth3\clwWidth5812\clshdrawnil 
\cellx9072
HERE
  $result =~ s/\$skillsString/$skillsString/g;

  my $rowTemplate = <<'HERE';
\pard\plain\ql\li0\ri0\sa120\widctlpar\intbl\wrapdefault\aspalpha\aspnum\faauto\adjustright\rin0\lin0\yts24\fcs1\af0\afs20\alang1025\fcs0\fs20\cgrid 
{\fcs1\af0\afs24\fcs0\cs29\b\f37\fs24 $label:\cell }
{\fcs1 \af0\afs24 \fcs0 \cs30\f37\fs24 $value}
{\fcs1 \af0\afs24 \fcs0 \cs30\f37\fs24 \cell }
\pard\plain\ql\li0\ri0\widctlpar\intbl\wrapdefault\aspalpha\aspnum\faauto\adjustright\rin0\lin0\fcs1\af0\afs20\alang1025\fcs0 \fs20\cgrid 
{\fcs1 \af0\afs24 \fcs0 
\f37\fs24 
\trowd\ts24\trgaph108\trleft0
\trftsWidth3\trwWidth9072\trftsWidthB3\trftsWidthA3
\trautofit1
\trpaddl108\trpaddb397\trpaddr108\trpaddfl3\trpaddft3\trpaddfb3\trpaddfr3
\tblrsid11032946\tbllkhdrrows\tbllklastrow\tbllkhdrcols\tbllklastcol\tblind108\tblindtype3 
\clvertalt\clbrdrt\brdrtbl 
\clbrdrl\brdrtbl 
\clbrdrb\brdrtbl 
\clbrdrr\brdrtbl 
\cltxlrtb\clftsWidth3\clwWidth3260\clshdrawnil 
\cellx3260\clvertalt
\clbrdrt\brdrtbl 
\clbrdrl\brdrtbl 
\clbrdrb\brdrtbl 
\clbrdrr\brdrtbl 
\cltxlrtb\clftsWidth3\clwWidth5812\clshdrawnil 
\cellx9072
\row}
HERE

  # collect skills 
  my %skillsTable = ();

  # extract skills from skills module
  my $skillsMatrix = Foswiki::Plugins::EmployeePortalPlugin::Core::getSkills($theWeb, $theTopic);
  my $hierarchy = Foswiki::Plugins::ClassificationPlugin::Core::getHierarchy($theWeb);
  if ($skillsMatrix && $hierarchy) {

    foreach my $skill (sort keys %$skillsMatrix) {
      $skill =~ s/^\s+//go;
      $skill =~ s/\s+$//go;
      next if $skillsMatrix->{$skill} < 2;
      
      my $cat = $hierarchy->getCategory($skill);
      next unless $cat;
      my $parentCategory;
      foreach my $parent ($cat->getParents()) {
        my %grantParents = map {$_->{name} => $_} $parent->getParents();
        next unless $grantParents{'SkillsCategory'};
        $parentCategory = $parent;
        last;
      }
      next unless $parentCategory;

      my $skillTitle = $cat->{title};
      my $parentTitle = $parentCategory->{title};
      $skillTitle =~ s/<nop>//go;
      $parentTitle =~ s/<nop>//go;

      push @{$skillsTable{$parentTitle}}, $skillTitle;
    }

  }


  # merge skills from CV module
  my %cvToSkillsMap = (
    'MainFocus' => 'MainFocus', 
    'ProgrammingLanguages' => 'Programming', 
    'OperatingSystems' => 'Operating Systems', 
    'Databases' => 'Databases',
    'Methods' => 'Methods', # ???
    'Technologies' => 'Technologies', # ???
    'Communication' => 'Communication', # ???
    'Middleware' => 'Middleware', 
    'Frameworks' => 'Application Frameworks'
  );

  foreach my $key (keys %cvToSkillsMap) {
    $key =~ s/^\s+//o;
    $key =~ s/\s+$//o;

    my $value = $formObj->fastget($key.uc($theLang)) || '';
    $value =~ s/^\s+//o;
    $value =~ s/\s+$//o;
    next unless $value;

    my @values = split(/\s*,\s*/, $value);
    my $label = translate($theLang, $cvToSkillsMap{$key});

    push @{$skillsTable{$cvToSkillsMap{$key}}}, @values;
  }


  # create RTF table row
  my $found = 0;
  foreach my $key (sort keys %skillsTable) {
    my $value = join(', ', sort @{$skillsTable{$key}});
    my $label = translate($theLang, $key);
    my $row = $rowTemplate;
    $row =~ s/\$value/$value/g;
    $row =~ s/\$label/$label/g;

    $result .= $row;
    $found = 1;
  }
  

  return '' unless $found;

  #writeDebug("result=$result");

  return $result;
}

################################################################################
sub handleProjects {
  my ($this, $params) = @_;

  $params ||= '';
  #writeDebug("handleProjects($params)");
  $params = new Foswiki::Attrs($params);
  my $theLang = $params->{lang} || $params->{language} || 'DE';
  $theLang = uc($theLang);
  my $theTopic = $params->{topic} || $this->{topic}.'CVProjects'.$theLang;
  my $theHeader = $params->{header} || '';
  my $theFooter = $params->{footer} || '';

  # get projects topic
  my $theWeb = $this->{web};
  ($theWeb, $theTopic) = Foswiki::Func::normalizeWebTopicName($theWeb, $theTopic);
  my $db = $this->{db};
  if ($theWeb ne $this->{web}) {
    $db = Foswiki::Plugins::DBCachePlugin::Core::getDB($theWeb);
  }

  my $topicObj = $this->{db}->fastget($theTopic);
  return '' unless $topicObj; # not found

  my $bullet =<< 'BULLET';
{\fcs0\b\f37\fs24
{\listtext
{\*\shppict
{\pict
{\*\picprop\shplid1031
{\sp{\sn shapeType}{\sv 75}}
{\sp{\sn pibFlags}{\sv 2}}
{\sp{\sn fLine}{\sv 0}}
{\sp{\sn fLayoutInCell}{\sv 1}}
{\sp{\sn fIsBullet}{\sv 1}}
{\sp{\sn fLayoutInCell}{\sv 1}}}
\picscalex107\picscaley107
\piccropl0\piccropr0\piccropt0\piccropb0
\picw397\pich397
\picwgoal225\pichgoal225
\pngblip
89504e470d0a1a0a0000000d494844520000000f0000000f020300000046b87dd9000000017352474200aece1ce900000006504c5445c0c0c0ff0000954f954b
0000000c636d50504a436d7030373132020000047c6d2e940000000174524e530040e6d86600000011494441541857636040058ca1a121641200611c0bf53be592b50000000049454e44ae426082}}
}}
BULLET

  my $result = '{\pard';
  my $temp = $topicObj->fastget('_sectiondefault');
  my $nrRows = 0;
  # | 1. Client | 2. Branch | 3. Duration | 4. Extend | 5. Role | 6. Technology | 7. Tools |
  while ($temp =~ /\n\|\s*(.*?)\s*\|\s*(.*?)\s*\|\s*(.*?)\s*\|\s*(.*?)\s*\|\s*(.*?)\s*\|\s*(.*?)\s*\|\s*(.*?)\s*\|/g) {
    $nrRows++;
    next if $nrRows == 1; # skipp table header
    my $cell1 = $this->tml2rtf($1); # won't be used but we still parse it in
    my $cell2 = $this->tml2rtf($2);
    my $cell3 = $this->tml2rtf($3);
    my $cell4 = $this->tml2rtf($4);
    my $cell5 = $this->tml2rtf($5);
    my $cell6 = $this->tml2rtf($6);
    my $cell7 = $this->tml2rtf($7);
    strip($cell1);
    strip($cell2);
    strip($cell3);
    strip($cell4);
    strip($cell5);
    strip($cell6);
    strip($cell7);
    writeDebug("found projects row '$cell1', '$cell2', '$cell3', '$cell4', '$cell5', '$cell6', '$cell7'");
    unless ($cell1 || $cell2 || $cell3 || $cell4 || $cell5 || $cell6 || $cell7) { # skipp empty rows
      $nrRows--;
      next;
    }

    $result .= 
      $bullet.
      '{\plain\s34\ql'.
      '\fi-567\li1134\ri0\widctlpar'.
      '\tx0\jclisttab\tx1134\tx3119\tx9072\wrapdefault'.
      '\aspalpha\aspnum\faauto\ls18\adjustright\rin0\lin1134\itap0\pararsid3155115'.
      '\fcs1\af0\afs28\fcs0'. 
      '\f37\fs28\cgrid'.
      '\b\sb240\keep '.
      $cell2.' ('.$cell3.') \par}'.
      '{\pard\li1134\ri0\cs29\b\f37\fs24\sb120\keep '.
      translate($theLang, 'description').':\par}'.
      '{\pard\li1134\ri0\fcs0\cs30\f37 '.$cell4.'\par}'.
      '{\pard\li1134\ri0\cs29\b\f37\fs24\sb120\keep '.
      translate($theLang, 'tasks').':\par}'.
      '{\pard\li1134\ri0\fcs0\cs30\f37 '.$cell5.'\par}'.
      '{\pard\li1134\ri0\cs29\b\f37\fs24\sb120\keep '.
      translate($theLang, 'technologies').':\par}'.
      '{\pard\li1134\ri0\fcs0\cs30\f37 '.$cell6.'\par}'.
      '{\pard\li1134\ri0\cs29\b\f37\fs24\sb120\keep '.
      translate($theLang, 'tools').':\par}'.
      '{\pard\li1134\ri0\fcs0\cs30\f37 '.$cell7.'\par}';
  }
  $result .= '}'."\n";
  writeDebug("result=$result");

  return ($nrRows>1)?$theHeader.$result.$theFooter:'';
}

################################################################################
sub translate {
  my ($lang, $key) = @_;

  $lang = uc($lang);

  writeDebug("translate($lang, $key)");

  return "undefined language '$lang'" 
    unless $strings{$lang};

  return $strings{$lang}{$key} || $key;
}

################################################################################
sub strip {
  $_[0] =~ s/^\s+//o;
  $_[0] =~ s/\s+$//o;
}

1;
