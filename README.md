# Cuttlefish

[![Build Status](https://travis-ci.org/mlandauer/cuttlefish.png?branch=master)](https://travis-ci.org/mlandauer/cuttlefish) [![Coverage Status](https://coveralls.io/repos/mlandauer/cuttlefish/badge.png?branch=master)](https://coveralls.io/r/mlandauer/cuttlefish) [![Code Climate](https://codeclimate.com/github/mlandauer/cuttlefish.png)](https://codeclimate.com/github/mlandauer/cuttlefish)

Cuttlefish is an easy to setup and easy to use open source transactional email server

It ensures that your emails arrive at their destination by continuously monitoring the deliverability of your emails.

Dependencies: Ruby 1.9.3, bundler

##To install:
```
bundle install
```

##To run:
```
bundle exec foreman start
```

##To install on your server:
Edit `config/deploy.rb`

Run:
```
cap deploy:setup
cap deploy:cold (the first time)
```

And on the server
```
cd /srv/www/cuttlefish.openaustraliafoundation.org.au/current
sudo foreman export upstart /etc/init -u deploy -a cuttlefish -f Procfile.production -l /srv/www/cuttlefish.openaustraliafoundation.org.au/shared/log --root /srv/www/cuttlefish.openaustraliafoundation.org.au/current
visudo
```

And add the following line:
```
deploy  ALL = NOPASSWD: /usr/sbin/service
```
This allows the deploy user to sudo just to manage the upstart processes

## New relic:
If you use new relic just put your configuration file in shared/newrelic.yml on the server
To record your deploys you will also need to add config/newrelic.yml on your local box. How annoying!

## How to contribute

If you find what looks like a bug:

* Check the [GitHub issue tracker](http://github.com/mlandauer/cuttlefish/issues/)
  to see if anyone else has reported issue.
* If you don't see anything, create an issue with information on how to reproduce it.

If you want to contribute an enhancement or a fix:

* Fork the project on GitHub.
* Make your changes with tests.
* Commit the changes without making changes to any files that aren't related to your enhancement or fix.
* Send a pull request.
