#!/usr/bin/perl
#
#  name:        twisten
#  author:      anthony kasza
#  description: this script will periodically pull a twitter account's 
#               timeline and run system commands based on tweets.
#               keywords and commands are defined in a configuration file.   
#  version:     2.0
#
use warnings;
use strict;
use LWP::Simple;
use JSON;
use Time::Local;
use constant CONF_LOCATION => qw( ./twisten.conf );
use constant SLEEP_TIME => qw( 15 );
use constant SCREEN_NAME => qw( bobboblahbah123 );

my $init_tweets_hash_ref = get_tweets();
my $init_latest_tweet_time = ( sort keys %$init_tweets_hash_ref )[-1];

open (CONF_HANDLE, CONF_LOCATION) or die $!;
my %config = ();
foreach (<CONF_HANDLE>) {
  next if (/^\#.*/);
  if (/(.+)\:{3}(.+)/) {
    %config = (%config, $1 => $2,);
  }
}
close (CONF_HANDLE);

while (1) {
  sleep(SLEEP_TIME);
  my $tweets_hash_ref = get_tweets();
  my $latest_tweet_time = ( sort keys %$tweets_hash_ref )[-1];

  if ($init_latest_tweet_time == $latest_tweet_time) {
    next;
  } elsif ( $init_latest_tweet_time < $latest_tweet_time ) {
    print "new tweet found => ",$tweets_hash_ref->{$latest_tweet_time}, "\n";	
      if (  defined $config{ ($tweets_hash_ref->{$latest_tweet_time}) }  ) {
			print "executing => ", $config{ ($tweets_hash_ref->{$latest_tweet_time}) }, "\n";
#		     exec( $config{ ($tweets_hash_ref->{$latest_tweet_time}) );
		}
		else{
	        	print "received unrecognized tweet, no command to execute\n";
		}
  } elsif ( $init_latest_tweet_time > $latest_tweet_time ) {
    die "\n supposedly new tweet has less epoch than old tweet.\n  time travel?\n";
  } else {
    die "\n not greater than, not less than, not equal to...\n  what's left to live for?\n";
  }
}

sub get_tweets {
  my %tweets;
  my $url = 'http://api.twitter.com/1/statuses/user_timeline.json?screen_name=' . SCREEN_NAME;
# no JSON validation done here
  my $json_array_ref = from_json(get $url);
  
  for my $tweet_hash_ref (@$json_array_ref) {
    %tweets = ( %tweets, convert_time( $tweet_hash_ref->{'created_at'} ) => $tweet_hash_ref->{'text'} );
  }
  return \%tweets;
}

sub convert_time {
  my $created_at = shift;
  my %months = ( Jan=>0, Feb=>1, Mar=>2, Apr=>3, May=>4, Jun=>5, 
        	     Jul=>6, Aug=>7, Sep=>8, Oct=>9, Nov=>10, Dec=>11, );
	     
# example of a 'created_at' value => Sat May 26 18:08:58 +0000 2012
  $created_at =~ /^\w{3}\s(\w{3})\s(\d{2})\s(\d{2})\:(\d{2})\:(\d{2})\s.{5}\s(\d{4})$/;
# order of values for timelocal => seconds, minutes, hour, day, month, year
  timelocal($5, $4, $3, $2, $months{$1}, $6);
}

__END__
