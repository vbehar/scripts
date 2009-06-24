#!/usr/bin/perl -p

# simple perl script for colorizing crabe log output
# use with : 'tail xxx.log | colorize-crabe-logs.pl'

# extract date and context
s/(\d{4}[-]{1}\d{2}[-]{1}\d{2}[ ]{1}\d{2}[:]{1}\d{2}[:]{1}\d{2}[.]{1}\d{3})( \[\w+ \w+\] \[\w+\] \[\w+\] )(.*)/\n\e[4m$1\e[0m$2\n$3/g; # underline

# different colors for input and output
s/(Received from client \w+: )(\w+)(.*)/\e[0;32m$1\n\e[1;32m$2\e[0;32m$3/g;   # green foreground
s/(Replying to client \w+: )(\w+)(.*)/\e[0;34m$1\n\e[1;34m$2\e[0;34m$3/g;     # blue  foreground

# reset color at the end
s/\n/\e[0m\n/g;

