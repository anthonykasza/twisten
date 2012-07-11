#!/usr/bin/perl
############################################################
### 		akasza         25 May 2012               ###
###                                                      ###
### This script will parse twisten configuration files   ###
### and wait for user input. This script is meant to     ###
### help debug how twisten will react when observing     ###
### specific tweets.                                     ###
############################################################
use warnings;
use strict;

open (CONF, "twisten.conf") or die $!;
my @fullConfFile=<CONF>;
close (CONF);
my %config=();

foreach (@fullConfFile){
	unless ($_=~/^\#/){
		if ($_=~/(.+)\:\:\:(.+)/){
			%config=(%config, $1=>$2);
		}
	}
}

my $input = <>;
chomp ($input);
if (exists $config{$input}){
	print $config{$input} . "\n";
}
else{
	print "key does not exist\n";
}
