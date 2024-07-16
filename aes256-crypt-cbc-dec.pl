#!/usr/bin/env perl

use strict;
use warnings;
use Crypt::CBC;
use Term::Prompt;
use MIME::Base64;
use Getopt::Long;
use Data::Dumper;
use JSON qw(decode_json);

my $file;

GetOptions(
  'file=s' => \$file
) or die "invalid options passed to $0\n";

die "$0 requires the file argument (--file)\n" unless $file;

my $password = prompt('p', 'Enter your password:', '', '' );

my $json_out = aes_cbc_dec($file, $password);
print "\n";
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
        -pass    => $password,
        -cipher  => "Crypt::OpenSSL::AES",
        -pbkdf   => 'pbkdf2'
        # -keysize => '32',
        # -iter    => '500000'
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
