#!/usr/bin/perl

# Phil's Google Authenticator code in Perl

use strict;
use Digest::SHA qw(hmac_sha1);
use Convert::Base32;

my $otp = &generateOTP('abcd efgh ijkl mnop');
print "Your OTP is $otp\n";

sub generateOTP
{
my ($key,$interval) = @_;

# Turn the key into a standard string, no spaces, all upper case
$key = uc($key);
$key =~ s/\ //g;

# decode the key from base32
my $key_decoded = decode_base32($key);

# Read the time, and produce the 30 second slice
my $time = int(time / 30) + $interval;

# Pack the time to binary
$time = chr(0) . chr(0) . chr(0) . chr(0) . pack('N*',$time);

# hash the time with the key
my $hmac = hmac_sha1 ($time,$key_decoded);

# get the offset
my $offset = ord(substr($hmac,-1)) & 0x0F;

# use the offset to get part of the hash
my $hashpart = substr($hmac,$offset,4);

# get the first number
my @val = unpack("N",$hashpart);
my $value = $val[0];

# grab the first 32 bits
$value = $value & 0x7FFFFFFF;
$value = $value % 1000000;

return $value;
}
