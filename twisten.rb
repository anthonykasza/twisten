#!/usr/bin/ruby

require 'rubygems'
require 'yajl'
require 'rest_client'
require 'time'

CONF_LOCATION 	= "twisten.conf";
SLEEP_TIME 	= 15;
USERNAME	= "bobboblahbah123";

def main
	initial_tweets = get_tweets();
	initial_latest_tweet_epoch = initial_tweets.keys.sort.reverse[0];
	config = Hash.new;

	File.open(CONF_LOCATION, 'r').each_line do |line|
		next if ( (line =~ /^\#/) or (line.split(':::').length != 2) );
		config.merge!( line.split(':::').first => line.split(':::').last )
	end

	while 1
		sleep SLEEP_TIME;
		tweets = get_tweets();
		latest_tweet_epoch = tweets.keys.sort.reverse[0];
		if (initial_latest_tweet_epoch == latest_tweet_epoch)
			next;
		elsif (initial_latest_tweet_epoch < latest_tweet_epoch)
			puts "new tweet found => #{tweets[latest_tweet_epoch]}";
			if ( config.has_key?(tweets[latest_tweet_epoch]) )
				puts "executing => #{config[ tweets[latest_tweet_epoch] ]}";
				system(config[ tweets[latest_tweet_epoch]);
			end
			initial_latest_tweet_epoch = latest_tweet_epoch;
		elsif (initial_latest_tweet_epoch > latest_tweet_epoch)
			die "\n supposedly new tweet has less epoch than old tweet.\n  time travel?\n";
		else
			die "\n not greater than, not less than, not equal to...\n  what's left to live for?\n";
		end
	end
end

def get_tweets
	t = Hash.new;
	url = 'http://api.twitter.com/1/statuses/user_timeline.json?screen_name=' + USERNAME;
	tweets = Yajl::Parser.parse(RestClient.get(url));
	tweets.each do |hash| 
		t.merge!(Time.parse(hash['created_at']).to_i => hash['text']);
	end
	return t;
end

main();
