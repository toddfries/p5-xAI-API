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

my $token = $ENV{XAI_BEARER_TOKEN};
if (!defined($token)) {
	die "Token not in XAI_BEARER_TOKEN environment variable";
}

# Assuming you've set your token in an environment variable for security
my $api = xAI::API->new(bearer_token => $ENV{XAI_BEARER_TOKEN});

# Example query
my $res;

#$res = $api->query_grok("What is the current weather in San Francisco?");
if (0) {
	$res = $api->query_grok("Testing. Just say hi and hello world and nothing else.");

	# Print the response
	print "Grok says: ".$res->{response}."\n";
}

if (0) {
	$res = $api->keyinfo;
}
if (0) {
	$res = $api->list_embedding_models;
}
if (1) {
	$res = $api->language_models;
}
use Data::Dumper;
print Dumper($res);
