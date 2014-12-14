Automysqlbackup
===============

[![Build Status](https://travis-ci.org/lyrasis/ansible-automysqlbackup-role.svg?branch=master)](https://travis-ci.org/MaximeThoonsen/ansible-automysqlbackup-role)

Install the automysqlbackup utility.

## Requirements

None.

---

**Variables**

```
autopostgresqlbackup_backup_directory: /var/lib/autopostgresqlbackup

# output location (log, files, stdout, quiet) and where output is sent (user / email address)
autopostgresqlbackup_mailcontent: quiet
autopostgresqlbackup_mailaddr: root

# default cron configuration
autopostgresqlbackup_cron:
  minute: 0
  hour: 0
  day: "*"
  month: "*"
  weekday: "*"

autopostgresqlbackup_latest: "yes"

```

## License

MIT

## Author Information

This role was created in 2014 by [Maxime Thoonsen](https://twitter.com/MaximeThoonsen).
