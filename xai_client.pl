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

getopts("c:m:s:");

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
	$api->searchmode("on");
	$api->citations("true");
	$api->sources("x:x_handles=RapidResponse47,potus,whitehouse,presssec,lauraloomer,vigilantfox;web:excluded_websites=wikipedia.org,wokepedia.org:country=US;news:excluded_websites=abc.com,nbc.com,msnbc.com,cnn.com");
	$res = $api->query_grok("What has President Trump done in the last week?");
	my $i=0;
	for my $choice (@{ $res->{choices}}) {
		$i++;
		printf "%3d. '%s'\n", $i, $choice->{message}->{content};
		print Dumper($choice);
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
use Data::Dumper;
print Dumper($res);
