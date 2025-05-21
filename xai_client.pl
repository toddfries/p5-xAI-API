#!/usr/bin/env perl

# Copyright (c) 2024 Todd T. Fries <todd@fries.net>
#
# Permission to use, copy, modify, and distribute this software for any
# purpose with or without fee is hereby granted, provided that the above
# copyright notice and this permission notice appear in all copies.
#
# THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
# WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
# MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
# ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
# WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
# ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
# OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.

use strict;
use warnings;
use xAI::API;
use ReadConf;
use Getopt::Std;
use Data::Dumper;

our $opt_c = $ENV{HOME}."/.config/cxai/grok.conf";
our $opt_s = "creds"; # section
our $opt_m = "grok-3-mini"; # model
our $opt_a = "search"; # action
our $opt_S = "x:x_hanldles=unix2mars;web:excluded_websites=wikipedia.org"; # sources
our $opt_Q = "What is the meaning of life?"; # query
our $opt_Y = "You are a history professor answering questions with accurate, detailed, and engaging explanations."; # sYstem setup

getopts("a:c:m:s:Q:S:Y:");

my $rc = ReadConf->new();
my $conf = $rc->readconf($opt_c);
my $section = $opt_s;
my $c = $conf->{$section};
if (!defined($c)) {
        die "[creds] not found in ".$opt_c;
}
my $token = $c->{bearer};
if (!defined($token)) {
	die "Token not in config file!";
}

if (!defined($token)) {
	die "Token not in ${opt_c} section [${opt_s}] var bearer";
}

# Assuming you've set your token in an environment variable for security
my $api = xAI::API->new(bearer_token => $token, model => $opt_m);

# Example query
my $res;

if ($opt_a eq "models") {
	$res = $api->models;
}
if ($opt_a eq "query") {
	$res = $api->query_grok("Testing. Just say hi and hello world and nothing else.");

	# Print the response
	print "Grok says: ".${ $res->{choices} }[0]->{message}->{content}."\n";
}
if ($opt_a eq "search") {
	$api->var("searchmode","on");
	$api->var("citations","true");
	$api->var("sources",$opt_S);
	$api->var("system", $opt_Y);
	$res = $api->query_grok($opt_Q);
	my $i=0;
	for my $choice (@{ $res->{choices}}) {
		$i++;
		printf "\n------------- Result:\n%3d. '%s'\n",
			$i, $choice->{message}->{content};
		printf "------------- Reasoning:\n%s\n",
			$choice->{message}->{'reasoning_content'};
		#print Dumper($choice);
	}
}	

if (0) {
	$res = $api->keyinfo;
}
if (0) {
	$res = $api->list_embedding_models;
}
if (0) {
	$res = $api->language_models;
}
print "Usage:\n".Dumper($res->{usage});
printf "Date: %s\n", $res->{created};
printf "id: %s\n", $res->{id};
print Dumper($res);
