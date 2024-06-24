#!/usr/bin/env perl

use strict;
use warnings;
use Crypt::CBC;
use IO::Prompter;
use MIME::Base64;
use Getopt::Long;
use JSON qw(decode_json);

my $file;

GetOptions(
  'file=s' => \$file
) or die "invalid options passed to $0\n";

die "$0 requires the file argument (--file)\n" unless $file;

my $obj = do {
    local $/ = undef;
    open my $fh, "<:encoding(UTF-8)", $file or die "could not open $file: $!\n";
    <$fh>;
};

my $decoded = decode_base64($obj);

my $password = prompt 'Enter your password:', -echo=>'*';

# my $plaintext = '{"parameter_a": "parameter_a_value","parameter_b": "parameter_b_value"}';
# my $password = 'observing congrats exhume diabolic';
my $cipher = Crypt::CBC->new(
        -key    => $password,
        -cipher => "Crypt::OpenSSL::AES",
        -pbkdf  => 'pbkdf2',
);

# my $encrypted = $cipher->encrypt($plaintext);
my $decrypted = $cipher->decrypt($decoded);

my $json_out = eval { decode_json($decrypted) };
if ($@) {
    print "decode_json failed, invalid json. error:$@\n";
}
else {
    my $parameter_a = $json_out->{'parameter_a'};
    my $parameter_b = $json_out->{'parameter_b'};
    print "result: $parameter_a, $parameter_b\n";
}
