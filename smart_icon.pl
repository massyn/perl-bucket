#!/usr/bin/perl
# SmartIcon
# www.massyn.net
# Written by Phil Massyn (massyn@gmail.com) on 27.12.2014
#
# This perl script runs as a CGI script on a web server.  It is called as an
# <img src tag from within your HTML page.  The idea is to change the type
# of icon it displays based on the parameters being fed to it.
#
# The logic is as follow :
#
# Read the the status, the time of the event and the timeout
# Has the timeout been reached?
# 	- Yes ==> show the warning icon
# 	- No  ==> Is the status OK ?
# 		- Yes ==> Show the ok icon
#		- No ==> Show the error icon	
#	
# Call the CGI from the HTML as follow
#
# smarticon.pl?time=1419707086&to=86400&status=OK
#
# where time is the time of the event in epoch
# to is the timeout in seconds
# status is either OK or ERR

# == setup the script with basic initialization

use strict;		# -- don't do Perl without it.
use CGI;		# -- don't do CGI without it
use MIME::Base64;	# -- I am encoding the images into the script in Base64 encoding

my $cgi = new CGI;

# == read the command line parameters

my $time	= $cgi->param("time");
my $to		= $cgi->param("to");
my $status	= $cgi->param("status");

# == check if everything we got is as we expected it

# -- is time an integer?
if($time !~ /^\d+$/)
{
	&error("time is not an integer (epoch) value");
}

# -- is to an integer?
if($to !~ /^\d+$/)
{
	&error("to is not an integer value");
}

# -- is status OK or ERR?
if($status !~ /^(OK|ERR)$/)
{
	&error("status is not OK or ERR");
}

# == if we made it this far, we can start checking the logic

# == are we still within the allowed timeout ?
if(time - $time < $to)
{
	# -- we are still in time

	if($status eq 'OK')
	{
		# -- show the OK icon
		&ok_icon;
	}
	else
	{
		# -- show the ERR icon
		&error_icon;
	}
}
else
{
	# -- we missed the time
	&warning_icon;
}

# == end of the line
exit(0);


# =================================== Prodcedures =====================================
sub error
{
	print "Content-type: text/html\n\n";
	print "<html><h1>ERROR</h1><p>$_[0]</p></html>";
	exit(0);
}
sub error_icon
{
	print "Content-type: image/png\n\n";
	print decode_base64(<<TOP
iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAAAAXNSR0IArs4c6QAAAAZiS0dEAP8A
/wD/oL2nkwAAAAlwSFlzAAALEwAACxMBAJqcGAAAAAd0SU1FB9sFHRIsA2EkC3QAAAKRSURBVDjL
VZNNSFRRFMd/574P82M0bcwPLL+TURmiDDGwoIigXcvatQjCXQTRrkUF1TaqdVGLaBGtIoIIqTSk
0igFK8ukSWXUcF45znvv3ha+GacDh3Mv9/7/h/M/5wjFphRoza221sHOZOKYHfoJAaXF+jK/uPTs
5OjYE0AiN0SHfDTnofHg4cHhjqbt7bmFFMYUHo29tVoWvPXM5Iep/qG51FQemyfgWllp05ETx+fs
n98RpQAwEYOI5O/GrW+UkVfv9pya/voeEJUA2sDed/jAnJ2aNQWw1jg127CrtxUTiT+fYs++3ncX
IA6ImgIu9+0+XUcWyacCdHaNjtt3Sdx/TOhlNnUSQS2n2d+/+xKgFUDlFvdq6Pum8MkYRBTa8zBh
uFlCEUltTdUZADUAsXhtTWVxdkRAKYJMhtDLIK4LloWIRCSGqhKLK7FYt90MMdexYL0g1IaIAuHv
ZXzbIvNmDFXqosrLcLc34MTj6FyOeH1dzH4Oy0O/V6l2FRgIvVWC9CK5hXm88be4DY2IDaIE8/cv
2W9f8Bd/saWljW+fZ5YF4GFX62zT6q8dJgylUIIIbrwWVVZBdnYGKeq6MYZsa4JDoxOiaG7GU845
J1YpohSi1Eatvk/r9Zt03XuEXssVDZ9BgPSf7MX/BulBz66VnenvWw2YvKAmDMFoxHYKgwQQJvvk
/LPXZSOwriISdePTdPdKRxIBKQyOZUXgzQY6ewfk9qv3nSOQA7QVEZT8gJKnc6k7LbGars5kTxsr
aXQuZzAapZSUdnXzMSiZPDs6fuyFHywBARBI0XaVAxVAaS+0H21vSdbpoEdArTju9PDMj4mXQTDJ
RmYPyAD6v9UELMAGnCgWWwj4kesII/8AeO4EN9v1se4AAAAASUVORK5CYII=
TOP
);
}

sub warning_icon
{
	print "Content-type: image/png\n\n";
	print decode_base64(<<TOP
iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAAACXBIWXMAAA7EAAAOxAGVKw4bAAAC
h0lEQVQ4y5WSQWxUZRSFv/9//7zpvBkjtSC1pA3i1M5MqdDQRNxZ46J1YyAkgG1EE0ij3dIIJMQF
cdPKAhJISFqJtS5YaUxMFxpwaQIRF2IKCWFC0RoNMCb0vXn/e/+7LiRNpsqCs7sn95zcm3PgCVj8
iJJb4Pt0nu+uHCfgaeEWOO+uDkr64w6xc5x+KvHKOXa7bza67O6wZMtviL3Unvw2wyv/t2vWE9MH
UJue4SyVAU3aAGPQOwdNx1+XzwDD6/fVeiKcY9zf+tIXuq8LhQU/h+Sfxf7wK9GtO3vap/j6iafP
HcZP5r07bnlEwvpu6d3WJv2VoqSro5L+uVcendZLFw+2Xt0yjL3GEfViZasKUjwJuF1vEgQG5fuo
gsGrVvv2Rjfeex9m/2OwMEGbZ8wJVe1FtUUYnadQ8CgWPZT2IInJ7aqSXF86+eV+Nz92CdtisG+I
I5T7u1QpA5NHKY9i0VAqehBZJLIoG+LVKj2j0Y3DwPk1gwvv4mvtTemBPlTOgtKQCUHgEbRppLEK
YQyRxS93YX9aOvb5Hjd76CusAXjnVcborXWrEiAaSRw0Ewq+opADGqvQTMBlKPM3uVpv91vNpXHg
M3PqbZTvqaPe9iqkFrEpEloIm3z84RakmSBhjJLHuacxfmUL8fWbRz99Uy6q32cY6egvL+Ze3wHR
KhLGEMbc/yOkc/hnRODetzU6O3JraYkfEF5bofFLfcS0F5jUL5eRRuPxnzHECc/lhU8+eIHUCc+3
txZW2RC/1kPxZn3CgDeEGLJHgPNAF1DBvwWdmty8JsoEEIFMEJehtAYYUA+n2ZdTjItjgzgK4vDF
YcShyVDiQAQhIwNSwAIR8KCZcuEfrZ8DeADjnHIAAAAASUVORK5CYII=
TOP
);
}

sub ok_icon
{
	print "Content-type: image/png\n\n";
	print decode_base64(<<TOP
iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAACR0lEQVR4XqWTT0gUURzHP2921tYx
/x1COuRhoUtBBdIhiyhcrHRFKLyJHbpUEBZJHfIQFGW5K5R/ojIIjxrRrYN2CIvQtsCCxP7RIVIW
TVpTV52ZXzM9cGzx1oMv8+a93+f7vm+YnxIR/mvkGtQkqKi+wWDsOlLlyX9673KkncF4kopc1iAY
HL5Jd7FVlDobb4k9OPOQuye7aDveSnNdE/u37YjlmaFUPEE/uS4apv9E72ZZlCEZ+d4k914iPcPI
nRf8nfeNRqXn+U5p6DTES9L9T4JaL3aJZTVca+ziyVgjqW99OAqMEChPrgHz9lcwx9gVLcE0OF3X
QQWgDVZs2uO763n/o5eZxSkM0we1MMAGFh04VSmEIz8pKwXXIbFqAByMlm3h88xTbBeWPTkCLmAL
ZG04t08AiFhQVAAoDgCYAAJknQxLLjRX6sLkK0XYgGUHWjQMgBmGkAEisJpAKcjMp3VktM7vEeZs
aKkM4I4RhWmC0mxgYCiYyUySF4ZkKti+tDeAk68V+RtAGeC4CqUCA5wlRj9NfsHNllAQgeRbBRDA
bzQczoNfs4q5BbCzjK5+g+kPtE0Uph8X5BezqRw2RqDzncJ19fUsHw6BswLpNEzOCmmPWfsjWVWt
9B+9hVx8ZEhiGLk/jvR+RGscb03JhQElx24jMa8WsHzWRI+FZ1dpqb5M6YS4scy8onAKQgoAHMGL
rU/+Pc3AkFfrM+s1U3R7PY2HrjBSm0Bq2rX8ub/m7wHlQMCu084WsBWoyJG/ZuX20R9cggXgsNE2
EAAAAABJRU5ErkJggg==
TOP
);
}
