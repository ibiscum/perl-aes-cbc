#!/usr/bin/env perl

use strict;
use warnings;
use Crypt::CBC;
use IO::Prompter;
use MIME::Base64;
use Getopt::Long;

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

my $password = prompt 'Enter your password:', -echo=>'*';

my $cipher = Crypt::CBC->new(
    -key    => $password,
    -cipher => "Crypt::OpenSSL::AES",
    -pbkdf  => 'pbkdf2',
);

my $encrypted = $cipher->encrypt($obj);
my $encoded = encode_base64($encrypted);

my ($base_name, $type) = split(/\./, $file);
my $file_enc = $base_name . "_enc.cnf";

my $fh_out;
open($fh_out, '>', $file_enc) or die "can't create $file_enc: $!\n";
print $fh_out $encoded;
close $fh_out;

exit 0;