# Logrotate module for Puppet

[![Build Status](https://secure.travis-ci.org/rodjek/puppet-logrotate.png)](http://travis-ci.org/rodjek/puppet-logrotate)

A more Puppety way of managing logrotate configs.  Where possible, as many of
the configuration options have remained the same with a couple of notable
exceptions:

 * Booleans are now used instead of the `<something>`/`no<something>` pattern.
   e.g. `copy` == `copy => true`, `nocopy` == `copy => false`.
 * `create` and it's three optional arguments have been split into seperate
   parameters documented below.
 * Instead of 'daily', 'weekly', 'monthly' or 'yearly', there is a
   `rotate_every` parameter (see documentation below).

## logrotate::rule

The only thing you'll need to deal with, this type configures a logrotate rule.
Using this type will automatically include a private class that will install
and configure logrotate for you.

```
namevar         - The String name of the rule.
path            - The path String to the logfile(s) to be rotated.
ensure          - The desired state of the logrotate rule as a String.  Valid
                  values are 'absent' and 'present' (default: 'present').
compress        - A Boolean value specifying whether the rotated logs should
                  be compressed (optional).
compresscmd     - The command String that should be executed to compress the
                  rotated logs (optional).
compressext     - The extention String to be appended to the rotated log files
                  after they have been compressed (optional).
compressoptions - A String of command line options to be passed to the
                  compression program specified in `compresscmd` (optional).
copy            - A Boolean specifying whether logrotate should just take a 
                  copy of the log file and not touch the original (optional).
copytruncate    - A Boolean specifying whether logrotate should truncate the
                  original log file after taking a copy (optional).
create          - A Boolean specifying whether logrotate should create a new
                  log file immediately after rotation (optional).
create_mode     - An octal mode String logrotate should apply to the newly
                  created log file if create => true (optional).
create_owner    - A username String that logrotate should set the owner of the
                  newly created log file to if create => true (optional).
create_group    - A String group name that logrotate should apply to the newly
                  created log file if create => true (optional).
dateext         - A Boolean specifying whether rotated log files should be
                  archived by adding a date extension rather just a number
                  (optional).
dateformat      - The format String to be used for `dateext` (optional).
                  Valid specifiers are '%Y', '%m', '%d' and '%s'.
delaycompress   - A Boolean specifying whether compression of the rotated
                  log file should be delayed until the next logrotate run
                  (optional).
extension       - Log files with this extension String are allowed to keep it
                  after rotation (optional).
ifempty         - A Boolean specifying whether the log file should be rotated
                  even if it is empty (optional).
mail            - The email address String that logs that are about to be 
                  rotated out of existence are emailed to (optional).
mailfirst       - A Boolean that when used with `mail` has logrotate email the
                  just rotated file rather than the about to expire file
                  (optional).
maillast        - A Boolean that when used with `mail` has logrotate email the
                  about to expire file rather than the just rotated file
                  (optional).
maxage          - The Integer maximum number of days that a rotated log file
                  can stay on the system (optional).
minsize         - The String minimum size a log file must be to be rotated,
                  but not before the scheduled rotation time (optional).
                  The default units are bytes, append k, M or G for kilobytes,
                  megabytes and gigabytes respectively.
missingok       - A Boolean specifying whether logrotate should ignore missing
                  log files or issue an error (optional).
olddir          - A String path to a directory that rotated logs should be
                  moved to (optional).
postrotate      - A command String that should be executed by /bin/sh after
                  the log file is rotated (optional).
prerotate       - A command String that should be executed by /bin/sh before
                  the log file is rotated and only if it will be rotated
                  (optional).
firstaction     - A command String that should be executed by /bin/sh once
                  before all log files that match the wildcard pattern are
                  rotated (optional).
lastaction      - A command String that should be execute by /bin/sh once 
                  after all the log files that match the wildcard pattern are
                  rotated (optional).
rotate          - The Integer number of rotated log files to keep on disk
                  (optional).
rotate_every    - How often the log files should be rotated as a String.
                  Valid values are 'hour', 'day', 'week', 'month' and 'year'
                  (optional).  Please note, older versions of logrotate do not
                  support yearly log rotation.
size            - The String size a log file has to reach before it will be
                  rotated (optional).  The default units are bytes, append k,
                  M or G for kilobytes, megabytes or gigabytes respectively.
sharedscripts   - A Boolean specifying whether logrotate should run the 
                  postrotate and prerotate scripts for each matching file or
                  just once (optional).
shred           - A Boolean specifying whether logs should be deleted with
                  shred instead of unlink (optional).
shredcycles     - The Integer number of times shred should overwrite log files
                  before unlinking them (optional).
start           - The Integer number to be used as the base for the extensions
                  appended to the rotated log files (optional).
uncompresscmd   - The String command to be used to uncompress log files
                  (optional).
```

Further details about these options can be found by reading `man 8 logrotate`.

### Examples

```
logrotate::rule { 'messages':
  path         => '/var/log/messages',
  rotate       => 5,
  rotate_every => 'week',
  postrotate   => '/usr/bin/killall -HUP syslogd',
}

logrotate::rule { 'apache':
  path          => '/var/log/httpd/*.log',
  rotate        => 5,
  mail          => 'test@example.com',
  size          => '100k',
  sharedscripts => true,
  postrotate    => '/etc/init.d/httpd restart',
}
```
