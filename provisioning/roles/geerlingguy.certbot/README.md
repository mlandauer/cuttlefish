# Ansible Role: Certbot (for Let's Encrypt)

[![Build Status](https://travis-ci.org/geerlingguy/ansible-role-certbot.svg?branch=master)](https://travis-ci.org/geerlingguy/ansible-role-certbot)

Installs and configures Certbot (for Let's Encrypt).

## Requirements

If installing from source, Git is required. You can install Git using the `geerlingguy.git` role.

Generally, installing from source (see section `Source Installation from Git`) leads to a better experience using Certbot and Let's Encrypt, especially if you're using an older OS release.

## Role Variables

The variable `certbot_install_from_source` controls whether to install Certbot from Git or package management. The latter is the default, so the variable defaults to `no`.

    certbot_auto_renew: true
    certbot_auto_renew_user: "{{ ansible_user }}"
    certbot_auto_renew_hour: 3
    certbot_auto_renew_minute: 30
    certbot_auto_renew_options: "--quiet --no-self-upgrade"

By default, this role configures a cron job to run under the provided user account at the given hour and minute, every day. The defaults run `certbot renew` (or `certbot-auto renew`) via cron every day at 03:30:00 by the user you use in your Ansible playbook. It's preferred that you set a custom user/hour/minute so the renewal is during a low-traffic period and done by a non-root user account.

### Automatic Certificate Generation

Currently there is one built-in method for generating new certificates using this role: `standalone`. Other methods (e.g. using nginx or apache and a webroot) may be added in the future.

**For a complete example**: see the fully functional test playbook in [tests/test-standalone-nginx-aws.yml](tests/test-standalone-nginx-aws.yml).

    certbot_create_if_missing: no
    certbot_create_method: standalone

Set `certbot_create_if_missing` to `yes` or `True` to let this role generate certs. Set the method used for generating certs with the `certbot_create_method` variable—current allowed values include: `standalone`.

    certbot_admin_email: email@example.com

The email address used to agree to Let's Encrypt's TOS and subscribe to cert-related notifications. This should be customized and set to an email address that you or your organization regularly monitors.

    certbot_certs: []
      # - email: janedoe@example.com
      #   domains:
      #     - example1.com
      #     - example2.com
      # - domains:
      #     - example3.com

A list of domains (and other data) for which certs should be generated. You can add an `email` key to any list item to override the `certbot_admin_email`.

    certbot_create_command: "{{ certbot_script }} certonly --standalone --noninteractive --agree-tos --email {{ cert_item.email | default(certbot_admin_email) }} -d {{ cert_item.domains | join(',') }}"

The `certbot_create_command` defines the command used to generate the cert.

#### Standalone Certificate Generation

    certbot_create_standalone_stop_services:
      - nginx

Services that should be stopped while `certbot` runs it's own standalone server on ports 80 and 443. If you're running Apache, set this to `apache2` (Ubuntu), or `httpd` (RHEL), or if you have Nginx on port 443 and something else on port 80 (e.g. Varnish, a Java app, or something else), add it to the list so it is stopped when the certificate is generated.

These services will only be stopped the first time a new cert is generated.

### Source Installation from Git

You can install Certbot from it's Git source repository if desired. This might be useful in several cases, but especially when older distributions don't have Certbot packages available (e.g. CentOS < 7, Ubuntu < 16.10 and Debian < 8).

    certbot_install_from_source: no
    certbot_repo: https://github.com/certbot/certbot.git
    certbot_version: master
    certbot_keep_updated: yes

Certbot Git repository options. To install from source, set `certbot_install_from_source` to `yes`. This clones the configured `certbot_repo`, respecting the `certbot_version` setting. If `certbot_keep_updated` is set to `yes`, the repository is updated every time this role runs.

    certbot_dir: /opt/certbot

The directory inside which Certbot will be cloned.

## Dependencies

None.

## Example Playbook

    - hosts: servers
    
      vars:
        certbot_auto_renew_user: your_username_here
        certbot_auto_renew_minute: 20
        certbot_auto_renew_hour: 5
    
      roles:
        - geerlingguy.certbot

See other examples in the `tests/` directory.

### Manually creating certificates with certbot

_Note: You can have this role automatically generate certificates; see the "Automatic Certificate Generation" documentation above._

You can manually create certificates using the `certbot` (or `certbot-auto`) script (use `letsencrypt` on Ubuntu 16.04, or use `/opt/certbot/certbot-auto` if installing from source/Git. Here are some example commands to configure certificates with Certbot:

    # Automatically add certs for all Apache virtualhosts (use with caution!).
    certbot --apache

    # Generate certs, but don't modify Apache configuration (safer).
    certbot --apache certonly

If you want to fully automate the process of adding a new certificate, but don't want to use this role's built in functionality, you can do so using the command line options to register, accept the terms of service, and then generate a cert using the standalone server:

  1. Make sure any services listening on ports 80 and 443 (Apache, Nginx, Varnish, etc.) are stopped.
  2. Register with something like `certbot register --agree-tos --email [your-email@example.com]`
    - Note: You won't need to do this step in the future, when generating additional certs on the same server.
  3. Generate a cert for a domain whose DNS points to this server: `certbot certonly --noninteractive --standalone -d example.com -d www.example.com`
  4. Re-start whatever was listening on ports 80 and 443 before.
  5. Update your webserver's virtualhost TLS configuration to point at the new certificate (`fullchain.pem`) and private key (`privkey.pem`) Certbot just generated for the domain you passed in the `certbot` command.
  6. Reload or restart your webserver so it uses the new HTTPS virtualhost configuration.

### Certbot certificate auto-renewal

By default, this role adds a cron job that will renew all installed certificates once per day at the hour and minute of your choosing.

You can test the auto-renewal (without actually renewing the cert) with the command:

    /opt/certbot/certbot-auto renew --dry-run

See full documentation and options on the [Certbot website](https://certbot.eff.org/).

## License

MIT / BSD

## Author Information

This role was created in 2016 by [Jeff Geerling](https://www.jeffgeerling.com/), author of [Ansible for DevOps](https://www.ansiblefordevops.com/).
