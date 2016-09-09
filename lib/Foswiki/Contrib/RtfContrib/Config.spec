# ---+ Extensions
# ---++ RtfContrib
# **PERL H LABEL="SwitchBoard - rtf"** 
# This setting is required to enable executing rtf from the commandline
$Foswiki::cfg{SwitchBoard}{rtf} = {
  package => 'Foswiki::Contrib::RtfContrib', 
  function => 'export', 
  contextg => {rtf => 1}
};

1;
