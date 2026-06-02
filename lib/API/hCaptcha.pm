use v5.42;
use experimental 'class';

class API::hCaptcha v0.1.0;

use JSON;
use REST::Client;
use URI;

field $client;
field $error   :reader = undef;
field $secret  :param;

ADJUST {
    $client = REST::Client->new({
            host => 'https://api.hcaptcha.com',
        });

    $client->addHeader(
            'Content-type' => 'application/x-www-form-urlencoded'
        );
}

method verify ($token, $ip = undef)
{
    # Build body query
    my $body = do {
        my %data = (
            secret => $secret,
            response => $token,
        );
        $data{remoteip} = $ip if defined $ip;
        my $u = URI->new('http:');
        $u->query_form(%data);
        $u->query;
    };

    # Call the API
    $client->POST('/siteverify', $body);

    # Check if we had a valid response
    my $code = $client->responseCode;
    my $res;

    die "hCaptcha connection returned $code\n"
        if ($code < 200 || $code >= 300);

    try {
        $res = decode_json $client->responseContent;
    } catch ($e) {
        die "Failed to parse hCaptcha response\n";
    }

    die "Invalid API response\n" unless exists $res->{success};

    # Assert result
    if ($res->{success}) {
        $error = undef;
        return true;
    }

    $error = join ', ', $res->{'error-codes'}->@*;
    return false;
}
