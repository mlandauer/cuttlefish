## Ansibles - PostgreSQL [![Build Status](https://travis-ci.org/Ansibles/postgresql.png)](https://travis-ci.org/Ansibles/postgresql)

Ansible role which installs and configures PostgreSQL, extensions, databases and users.


#### Requirements & Dependencies
- Tested on Ansible 1.4 or higher.
- Ansibles.monit ([Galaxy](https://galaxy.ansible.com/list#/roles/502)/[GH](https://github.com/Ansibles/monit)) if you want monit protection (in that case, you should set `monit_protection: true`)


#### Variables

```yaml
# Basic settings
postgresql_version: 9.3
postgresql_encoding: 'UTF-8'
postgresql_locale: 'en_US.UTF-8'

postgresql_admin_user: "postgres"
postgresql_default_auth_method: "trust"

postgresql_cluster_name: "main"
postgresql_cluster_reset: false

# List of databases to be created (optional)
postgresql_databases:
  - name: foobar
    hstore: yes         # flag to install the hstore extension on this database (yes/no)
    uuid-ossp: yes      # flag to install the uuid-ossp extension on this database (yes/no)

# List of users to be created (optional)
postgresql_users:
  - name: baz
    pass: pass
    encrypted: no       # denotes if the password is already encrypted.

# List of user privileges to be applied (optional)
postgresql_user_privileges:
  - name: baz          # user name
    db: foobar         # database
    priv: "ALL"        # privilege string format: example: INSERT,UPDATE/table:SELECT/anothertable:ALL
```

There's a lot more knobs and bolts to set, which you can find in the defaults/main.yml


#### License

Licensed under the MIT License. See the LICENSE file for details.

#### Thanks

To the contributors:
- [Ralph von der Heyden](https://github.com/ralph)


#### Feedback, bug-reports, requests, ...

Are [welcome](https://github.com/ansibles/postgresql/issues)!
