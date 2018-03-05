#!/usr/bin/perl

# Find duplicate files in a specified directory

use strict;
use Digest::file qw(digest_file_hex);

my $dir = "c:/temp";  # -- change this to the path you're checking

print "Getting a list of all the files...\n";
# == get all the files
my @files = &showdir($dir);
print " *** Found " . @files . " files ***\n\n";

print "Getting their signatures...\n";
my %SIGNATURE;
foreach my $f (@files)
{
	# -- get the file size
	my @ary = stat($f);
	my $size = $ary[7];

	# -- get the SHA1 digest
	my $digest = digest_file_hex($f, "SHA-1");

	# -- record the signature
	$SIGNATURE{$f} = "$digest:$size";
}

my %DUPLICATE;
print "Finding duplicate signatures...\n";
open(DUP,">duplicate.txt");

my $cnt;
foreach my $s (keys %SIGNATURE)
{
	my $file = $s;
	my $sig = $SIGNATURE{$file};

	if($DUPLICATE{$sig} eq '')
	{
		$DUPLICATE{$sig} = $file;	# if there's nothing yet, record the original file -- this one will stay untouched
	}
	else
	{
		print " - $file\n";	# but if it's already there, record the file as a duplicate
		print DUP "$file\n";
    # unlink $file;   # -- if you actualy want to delete the duplicate file, then uncomment this file
		$cnt++;
	}
}
close DUP;

print " *** Found $cnt duplicate files ***\n\n";

print "All done - read duplicate.txt for the full log.\n";

exit(0);

sub showdir
{
	my ($d) = @_;

	my @LIST;
	opendir(DIR,$d);
	foreach my $f (readdir(DIR))
	{
		if($f eq '.' || $f eq '..')
		{
			next;
		}

		my $k = "$d/$f";

		if(-d "$d/$f")
		{
			push(@LIST,&showdir($k));
		}
		else
		{
			push(@LIST,$k);
		}
	}
	closedir(DIR);
	return @LIST;
}

