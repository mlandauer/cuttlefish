[![Stories in Ready](https://badge.waffle.io/mlandauer/cuttlefish.png?label=ready&title=Ready)](https://waffle.io/mlandauer/cuttlefish)

# ![Cuttlefish](https://raw.github.com/mlandauer/cuttlefish/master/app/assets/images/cuttlefish_80x48.png) Cuttlefish

[![Build Status](https://travis-ci.org/mlandauer/cuttlefish.png?branch=master)](https://travis-ci.org/mlandauer/cuttlefish) [![Coverage Status](https://coveralls.io/repos/mlandauer/cuttlefish/badge.png?branch=master)](https://coveralls.io/r/mlandauer/cuttlefish) [![Code Climate](https://codeclimate.com/github/mlandauer/cuttlefish.png)](https://codeclimate.com/github/mlandauer/cuttlefish)

Cuttlefish is a lovely, easy to setup transactional email server

Sending a few emails from your app is easy. Sending lots becomes painful. There are so many hidden gotchas. Do your emails get delivered? Are you being considered a spammer? What about all those bounced emails?

Let's make sending lots of emails fun again!

And without the hidden dangers of vendor lock in of commercial transactional email services.

* Send email from your application using smtp in the usual way and get all sorts of added benefits for no effort
* A lovely web UI to browse what's happening
* Monitor in real time which emails arrive at their destination and which bounce
* Works with any web framework and language
* Automatically not send emails to destinations that have hard bounced in the past
* Track which emails are opened and which links are clicked
* Statistics on emails sent, soft/hard bounced and held back
* View the full email content for recently sent emails
* Multiple applications can each have their own SMTP authentication
* Check your IP reputation with one click
* Easy to install and get going quickly
* Built in, super easy to set up, automatic DKIM signing
* Postfix, which you know and trust, handles email delivery
* Open source, so no vendor lock in.

Cuttlefish is in beta. It's been used in production on one of [OpenAustralia Foundation](http://www.openaustraliafoundation.org.au)'s project for over a year and has sent more than 2 million emails.

##Screenshots

![Sign up](https://raw.github.com/mlandauer/cuttlefish/master/app/assets/images/screenshots/1.png)
![Dashboard](https://raw.github.com/mlandauer/cuttlefish/master/app/assets/images/screenshots/2.png)
![Email](https://raw.github.com/mlandauer/cuttlefish/master/app/assets/images/screenshots/3.png)

##Things on the cards

* REST API for deep integration with your application
* Web callbacks on succesful delivery, hard bounces, open and click events
* "out of office" and bounce reply filtering
* Incoming email

##Dependencies
Ruby 1.9.3, MySQL, Postfix
(Postfix is optional for local development or just trying it out. Some things like the email deliverability just won't show anything)

Also you need the following libraries:
imagemagick, libmagickwand-dev, libmysqld-dev

##To install:
```
bundle install
```
and edit `config/database.yml` with your database settings

```
bundle exec rake db:setup
bundle exec foreman start
```

and point your browser at [http://localhost:3000](http://localhost:3000)

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

### New Relic
If you use new relic just put your configuration file in shared/newrelic.yml on the server
To record your deploys you will also need to add config/newrelic.yml on your local box. How annoying!

### Honeybadger
Copy `config/initializers/honeybadger.rb-example` to `config/initializers/honeybadger.rb` and fill in your API key.

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
