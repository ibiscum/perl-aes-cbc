#!/usr/bin/env perl

use strict;
use warnings;
use Crypt::CBC;
use IO::Prompter;
use MIME::Base64;
use Getopt::Long;
use Data::Dumper;
use JSON qw(decode_json);

my $file;

GetOptions(
  'file=s' => \$file
) or die "invalid options passed to $0\n";

die "$0 requires the file argument (--file)\n" unless $file;

my $password = prompt 'Enter your password:', -echo=>'*';

my $json_out = aes_cbc_dec($file, $password);

print Dumper($json_out);

sub aes_cbc_dec {
    my ($file, $password) = @_;

    my $obj = do {
        local $/ = undef;
        open my $fh, "<:encoding(UTF-8)", $file or die "could not open $file: $!\n";
        <$fh>;
    };

    my $decoded = decode_base64($obj);
    my $cipher = Crypt::CBC->new(
        -key    => $password,
        -cipher => "Crypt::OpenSSL::AES",
        -pbkdf  => 'pbkdf2',
    );

    my $decrypted = $cipher->decrypt($decoded);
    my $json_out = eval { decode_json($decrypted) };

    if ($@) {
        print "wrong password, decode_json failed, invalid json. error: $@\n";
        exit 1;
    }
    else {
        return $json_out;
    }
}
