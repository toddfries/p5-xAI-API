
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
		$args{model} = "grok-beta";
	}
	if (!defined $args{temperature}) {
		$args{temperature} = 0;
	}
	$me->temperature($args{temperature});
	$me->model($args{model});
	$me->{ua} = LWP::UserAgent->new;
	$me->{ua}->agent('curl/8.10.1');
	#$me->{ua}->agent('unix2mars special code/0.0');
	$me->{ua}->agent('libwww/8.10.1');
	#$me->{ua}->agent('libwww-perl/6.77');
	$me->{ua}->agent('libwww/6.77');
	$me->{ua}->agent('curl-perl/8.10.1');
	#$me->{ua}->agent('curl-perl/6.77');
	#$me->{ua}->agent('libwww-perl/8.10.1');
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
		printf "content = '%s'\n", $content;
	}

	my $res = $ua->request($req);
	if ($res->is_success) {
		return JSON::decode_json($res->decoded_content);
	}
	use Data::Dumper;
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
	return $me->_mkr('POST', 'chat/completions', {
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
	"temperature" => $temp
	});
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

sub model {
	my ($me, $model) = @_;
	if (defined $model) {
		$me->{model} = $model;
	}
	return $me->{model};
}

1;
