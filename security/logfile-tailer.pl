#!/usr/bin/perl

use strict;

my $HOMEIP = $ARGV[0];  # specify the IP address to exclude (just in case you try to lock yourself out
&log("Using home ip = $HOMEIP");

my $FILES;
$FILES->{'/var/log/auth.log'} = 'sshd.+(Authentication failure|Invalid user).+from';

# == find the web server logs
foreach my $l (`cat /etc/apache2/sites-enabled/* |grep -i errorlog`) {
        chomp($l);
        my ($log) = ($l =~ /errorlog\s+(.+)/i);
        if(-f $log) {
                &log("Adding web server log - $log");
                $FILES->{$log} = 'script .+ not found or unable to stat';
        }
}

my $to = 300;   # timeout
my $th = 5;     # threshold
my $heartbeat;          # last time a heartbeat was written
my $heartbeat_to = 60;  # write a heartbeat at least every 60 seconds

use Fcntl qw(SEEK_SET);

&log("$0 starting up - timeout of $to and threshold of $th");

my %HASH;
my $pos;
my $started=0;
while (1)
{
        my $total_tailsize = 0;
        my $total_pos = 0;

        # == cycle through each of the files
        foreach my $file (keys %{$FILES}) {
                my $tailsize;

                $tailsize->{$file} = (stat($file))[7];

                if($tailsize->{$file} < $pos->{$file})
                {
                        $pos->{$file} = 0;
                }

                $total_tailsize += $tailsize->{$file};
                $total_pos += $pos->{$file};

                # =================================================================
                     open TAILLOG, $file or die "Cannot open $file, $!";

                seek TAILLOG, $pos->{$file}, SEEK_SET if defined $pos->{$file};
                while(<TAILLOG>)
                {
                        $pos->{$file} += length($_);
                        chomp;
                        if($started)
                        {
                                &tailer($_,$FILES->{$file},$file);
                        }
                }
                close TAILLOG;
                
        }
        
        &checkhash();
        $started = 1;

        &heartbeat();
        # Improve the speed of SP - only sleep if the file hasn't changed in size
        if($total_tailsize == $total_pos)
        {
                sleep 5;
        }
}
exit(0);
# ============================================================================================
sub tailer
{
        my ($l,$filter,$file) = @_;
        # read the IP
        if($l =~ /$filter/)
        {
                my ($ip) = ($l =~ m/(\d+\.\d+\.\d+\.\d+)/);
                &log("Potential - $file - $ip - $l");
                if($ip ne $HOMEIP)
                {
                        $HASH{$ip} .= time . ";";
                }
        }

}
sub checkhash
{
        foreach my $ip (keys %HASH)
        {
                my $new;
                my $c=0;
                foreach my $t (split(/\;/,$HASH{$ip}))
                {
                        my $age = time - $t;
                        if($age < $to)
                        {
                                $new .= "$t;";
                                $c++;
                        }
                }
                &log(" -- IP $ip is on $c of $th");
                $HASH{$ip} = $new;
                if($c >= $th)
                {
                        &log("Blocking IP $ip");
                        system("iptables -A INPUT -s $ip -j DROP");
                        delete $HASH{$ip};
                }
        }
}
sub heartbeat {

        if($heartbeat + $heartbeat_to < time)   {
                &log(" ** heartbeat **");
                $heartbeat = time;
        }
}

sub log {
        my ($txt) = @_;

        open(LOG,">>$0.log");
        print LOG scalar gmtime(time) . " - $txt\n";
        #       print "LOG : $txt\n";
        close LOG;
}
