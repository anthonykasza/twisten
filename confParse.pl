#!/usr/bin/perl
#
#  name:        twisten configuration parser
#  author:      anthony kasza
#  description: this script will parse a twisten configuration file and
#               give feedback for debugging purposes
#  version:     2.0
#
use warnings;
use strict;
use constant CONF_LOCATION => qw( ./twisten.conf );

open (CONF_HANDLE, CONF_LOCATION) or die $!;
my %config=();

while (<CONF_HANDLE>) {
  next if (/^\#.*/);
  if (/(.+)\:{3}(.+)/) {
    %config=(%config, $1=>$2);
  }
}
close (CONF_HANDLE);

my $input = <>;
chomp ($input);
if ($config{$input}) {
	print $config{$input} . "\n";
}
else{
	print "key does not exist\n";
}
