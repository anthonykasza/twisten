#!/usr/bin/perl
############################################################
###  		akasza	        15 April 2011            ###
###                                                      ###
### This script will listen to a user defined twitter    ###
### account and run system commands mapped to specified  ###
### tweets.                                              ###
############################################################
use warnings;
use strict;
use LWP::Simple;
use XML::Simple;
use Time::Local;
############################################################
###          read and parse configuration file           ###
############################################################
open (CONF, "twisten.conf") or die $!;
#
# add twisten.conf santity checking here
#
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
############################################################
### call tweet procesor and begin main script	         ###
############################################################
my $initialHighest; my $newTweetFlag=0; my %tweets; my $highest;
%tweets=&pullXML;
$initialHighest=&findHighest(%tweets);
while (1){ 
	sleep (15);
	%tweets=&pullXML;
	$highest=&findHighest(%tweets);
	########################################################
	### determine if new tweet has happened, sets flag   ###
	########################################################
	if ($highest > $initialHighest){
        	$newTweetFlag=1;
	        $initialHighest=$highest;
	    }
	elsif ($highest < $initialHighest){
	        die "ERROR:: HOW DID THIS HAPPEN?\n";
	}
	else{
	        $newTweetFlag=0;
	}
	########################################################
	### checks for new tweet flag, runs command if       ###
	### correlating tweet is found in the config file    ###
	########################################################
	if ($newTweetFlag==1){
		print "NEW TWEET FOUND...$tweets{$highest}\n";
		$newTweetFlag=0;		
		if (  defined $config{( $tweets{$highest} )}  ){
			print "executing..." . $config{( $tweets{$highest} )} . "\n";
#		       	exec( $config{$input} );
		}
		else{
	        	print "received unrecognized command\n";
		}
	}
}

############################################################
### returns highest key (epoch time) in tweets hash      ###
############################################################
sub findHighest{
	my $highest=0;
    	my $tweets= shift;
	foreach my $keys (keys %tweets){
        	if ($keys > $highest){
                	$highest=$keys;
        	}
    	}
    	return $highest;
}

############################################################
### pulls xml into hash, parses xml to get tweets        ###  
### and timestamps, then sets key of tweets to           ###
###               epoch timestamp                        ###
############################################################
sub pullXML{
    	my %months=(
        	Jan=>0, Feb=>1, Mar=>2, Apr=>3, May=>4, Jun=>5, 
        	Jul=>6, Aug=>7, Sep=>8, Oct=>9, Nov=>10, Dec=>11,
   	);
    	my ($secs, $mins, $hours, $day, $month, $year); my %tweets;
    
    	#  $url = website of the public account's rss feed
    	my $url = 'http://twitter.com/statuses/user_timeline/bobboblahbah123.rss';
    	my $rssPage = get $url;
    	die "Error: Couldn't find page\ncheck your internet connection" unless defined $rssPage;
    
    	# create anonymous hash of date=>tweet
    	my $xml = new XML::Simple(KeyAttr=>'pubDate');
    	my $xmlHashRef = $xml->XMLin( "$rssPage" );
    	my $xmlHashRefPiece = ( $xmlHashRef->{channel}->{item} );
    	foreach my $keys (keys %$xmlHashRefPiece){
        	# convert twitter time to epoch time
        	($keys =~ /^(\D+)(\d+) (\w+) (\d+) (\d+):(\d+):(\d+)/);
        	$day=$2; $month=$months{$3}; $year=$4; $hours=$5; $mins=$6; $secs=$7;
        	my $keyDate=timelocal($secs,$mins,$hours,$day,$month,$year);
        	# place sanitized epoch=>tweet pairs into new hash
        	($xmlHashRefPiece->{$keys}->{description}=~/^(\w+)\W (.+)/); my $tweet=$2;  
        	if (%tweets){
            		%tweets=( 
				%tweets,$keyDate=> $tweet,
           		);  
        	}
        	unless (%tweets){
            		%tweets=(
                		$keyDate=> $tweet,
            		);
        	}
   	}
    	return %tweets;
}

