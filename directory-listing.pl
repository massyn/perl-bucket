#!/usr/bin/perl

# Read an entire directory and return all the filenames in an array

use strict;

my $dir = "c:/data";

my @files = &showdir($dir);

foreach my $f (@files)
{
	print "--> $f\n";
}

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
