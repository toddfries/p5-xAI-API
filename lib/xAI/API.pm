
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

package xAI::API;

use strict;
use warnings;
use LWP::UserAgent;
use JSON;
use Data::Dumper;

our $VERSION = '0.01';

sub new {
	my ($class, %args) = @_;
	my $me = {
		_base_url => 'https://api.x.ai/v1/', # base URL
		_bearer_token => $args{bearer_token} ||
			die "Bearer token required",
	};
	bless $me, $class;
	if (!defined $args{model}) {
		$args{model} = "grok-3-mini";
	}
	if (!defined $args{temperature}) {
		$args{temperature} = 0;
	}
	if (!defined $args{searchmode}) {
		$args{searchmode} = "off";
	}
	if (!defined $args{citations}) {
		$args{citations} = "false";
	}
	$me->temperature($args{temperature});
	$me->model($args{model});
	$me->searchmode($args{searchmode});
	$me->citations($args{citations});
	#$me->sources($args{sources});
	$me->{ua} = LWP::UserAgent->new;
	$me->{ua}->agent('curl/8.10.1');
	#$me->{ua}->agent('unix2mars special code/0.0');
	$me->{ua}->agent('libwww/8.10.1');
	#$me->{ua}->agent('libwww-perl/6.77');
	$me->{ua}->agent('libwww/6.77');
	$me->{ua}->agent('curl-perl/8.10.1');
	#$me->{ua}->agent('curl-perl/6.77');
	#$me->{ua}->agent('libwww-perl/8.10.1');
	$me->{debug} = $args{debug};
	if (!defined $me->{debug}) {
		$me->{debug} = 0;
	}
	return $me;
}

# Method to make API calls
sub _mkr {
	my ($me, $method, $endpoint, $params) = @_;
	my $ua = $me->{ua};
	my $url = $me->{_base_url} . $endpoint;
	# XXX cache unique pairs ?
	my $req = HTTP::Request->new($method => $url);
	$req->header(':Authorization' => "Bearer " . $me->{_bearer_token});
	$req->content_type('application/json');
	if (defined $params) {
		my $content = JSON::encode_json($params);
		$req->content($content);
		if ($me->{debug}>0) {
			printf "content = '%s'\n", $content;
		}
	}

	my $res = $ua->request($req);
	if ($res->is_success) {
		return JSON::decode_json($res->decoded_content);
	}
	print Dumper($res);
	die $res->status_line;
}

# Example method for a query to Grok or similar AI
sub query_grok {
	my ($me, $query) = @_;
	my $temp = $me->temperature;
	my $model = $me->model;
	if (!defined $temp) {
		$temp = 0;
	}
	$temp += 0; # convert to numeric
	my $data = {
		"messages" => [
	  {
		"role" => "system",
		#"content" => "You are Grok, a chatbot inspired by the Hitchhikers Guide to the Galaxy."
		"content" => "You are a test assistant."
	  },
	  {
		"role" => "user",
		"content" => $query
	  }
	],
	"model" => $model,
	"stream" => JSON::false,
	"temperature" => $temp,
	"search_parameters" => {
		"mode" => $me->searchmode()
	},
	};
	if ($me->{citations} eq "true") {
		$data->{search_parameters}->{return_citations} = JSON::true;
	}
	if (defined $me->{fromdate}) {
		$data->{search_parameters}->{from_date} = $me->{fromdate};
	}
	if (defined $me->{todate}) {
		$data->{search_parameters}->{to_date} = $me->{todate};
	}
	if (defined $me->{maxsearch}) {
		$data->{search_parameters}->{max_search_results} =
			$me->{maxsearch};
	}
	# $me->{sources} = "x;web:excluded_websites=wikipedia.org,wokepedia.org:country=jp
	if (defined $me->{sources}) {
		my @srclist = ();
		for my $src (split(";",$me->{sources})) {
			my @list = split(/:/,$src);
			my $type = shift @list;
			my $sdata = { "type" => $type };
			for my $arg (@list) {
				my ($var, $vals) = split(/=/, $arg);
				if ($var eq "country") {
					$sdata->{$var} = $vals;
					next;
				}
				$sdata->{$var} = [ split(/,/,$vals) ];
			}
			push @srclist, $sdata;
		}

		$data->{search_parameters}->{sources} = [ @srclist ];
	}

	return $me->_mkr('POST', 'chat/completions', $data);
}

sub keyinfo {
	my ($me) = @_;
	return $me->_mkr('GET', 'api-key');
}

sub embedding_models {
	my ($me, $id) = @_;
	my $idstr = "";
	if (defined $id) {
		$idstr = "/${id}";
	}
	return $me->_mkr('GET', 'embedding-models'.$idstr);
}

sub language_models {
	my ($me, $id) = @_;
	my $idstr = "";
	if (defined $id) {
		$idstr = "/${id}";
	}
	return $me->_mkr('GET', 'language-models'.$idstr);
}

sub models {
	my ($me, $id) = @_;
	my $idstr = "";
	if (defined $id) {
		$idstr = "/${id}";
	}
	return $me->_mkr('GET', 'models'.$idstr);
}

sub temperature {
	my ($me, $temp) = @_;

	if (defined $temp) {
		$me->{temperature} = $temp;
	}
	return $me->{temperature};
}
sub searchmode {
	my ($me, $searchmode) = @_;

	if (defined $searchmode) {
		$me->{searchmode} = $searchmode
	}
	return $me->{searchmode};
}
sub citations {
	my ($me, $citations) = @_;

	if (defined $citations) {
		$me->{citations} = $citations
	}
	return $me->{citations};
}
sub sources {
	my ($me, $sources) = @_;

	if (defined $sources) {
		$me->{sources} = $sources
	}
	return $me->{sources};
}

sub model {
	my ($me, $model) = @_;
	if (defined $model) {
		$me->{model} = $model;
	}
	return $me->{model};
}

1;
