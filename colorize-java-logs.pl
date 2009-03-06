#!/usr/bin/perl -p

# simple perl script for colorizing java log output
# use with : 'tail xxx.log | colorize-java-logs.pl'

s/SEVERE/\e[1;33m$&\e[0;31m/g;
s/GRAVE/\e[1;35m$&\e[0;31m/g;
s/ATTENTION/\e[1;31m$&\e[0;31m/g;
s/INFO/\e[1;34m$&\e[0;34m/g;
s/CONFIG/\e[1;34m$&\e[0;34m/g;
s/FIN/\e[1;32m$&\e[0;32m/g;

s/(\d{1,2}[ ]{1}.+\d{4}[ ]{1}\d{2}[:]{1}\d{2}[:]{1}\d{2})/\n\e[4m$&\e[0m/g;

s/\n/\e[0m\n/g;

