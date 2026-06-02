use v5.42;
use Test2::V1 -Pip;

use API::hCaptcha;

my $mock = Test2::Mock->new(class => 'REST::Client');

# Network problems
{
    # Invalid return code
    my $h = API::hCaptcha->new(secret => undef);

    $mock->override(responseCode => sub { 1 });
    like(
        dies { $h->verify(0) },
        qr/connection/i,
        'dies if network returns < 200'
    );
    $mock->restore('responseCode');

    $mock->override(responseCode => sub { 1000 });
    like(
        dies { $h->verify(0) },
        qr/connection/i,
        'dies if network returns > 200'
    );
    $mock->restore('responseCode');

    # Bad JSON response
    $mock->override(responseContent => sub { 'bad}json' });

    like(
        dies { $h->verify(0) },
        qr/parse/i,
        'dies if bad json received'
    );

    $mock->restore('responseContent');
}

# Bad response
{
    my $h = API::hCaptcha->new(secret => undef);
    $mock->override(responseContent => sub { '{}' });

    like(
        dies { $h->verify(0) },
        qr/invalid/i,
        'dies if bad response received'
    );

    $mock->restore('responseContent');
}

# Incorrect data
{
    my $h = API::hCaptcha->new(secret => undef);

    ok !$h->verify(0), 'fails with bad secret';
    like $h->error, qr/secr/i, 'reports invalid secret';
}

# Fake a good call
{
    my $h = API::hCaptcha->new(secret => undef);
    $mock->override(responseContent => sub { '{"success":true}' });

    ok $h->verify(0, 1), 'works with good response';

    $mock->restore('responseContent');
}

done_testing;
