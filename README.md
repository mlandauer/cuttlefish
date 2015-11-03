[![Stories in Ready](https://badge.waffle.io/mlandauer/cuttlefish.png?label=ready&title=Ready)](https://waffle.io/mlandauer/cuttlefish)

# ![Cuttlefish](https://raw.github.com/mlandauer/cuttlefish/master/app/assets/images/cuttlefish_80x48.png) Cuttlefish

[![Build Status](https://travis-ci.org/mlandauer/cuttlefish.png?branch=master)](https://travis-ci.org/mlandauer/cuttlefish) [![Coverage Status](https://coveralls.io/repos/mlandauer/cuttlefish/badge.png?branch=master)](https://coveralls.io/r/mlandauer/cuttlefish) [![Code Climate](https://codeclimate.com/github/mlandauer/cuttlefish.png)](https://codeclimate.com/github/mlandauer/cuttlefish)

* Project site: [cuttlefish.io](https://cuttlefish.io)
* Hosted version ([free](http://poplus.org/posts/email-is-your-secret-weapon/) for [Poplus.org](http://poplus.org/) community members): [cuttlefish.oaf.org.au](https://cuttlefish.oaf.org.au)
* Github repo:  [github.com/mlandauer/cuttlefish](https://github.com/mlandauer/cuttlefish)

Cuttlefish is a lovely, easy to set up transactional email server

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

Cuttlefish is in beta. It's been used in production on three of [OpenAustralia Foundation](http://www.openaustraliafoundation.org.au)'s project for over a year and has sent well over 2 million emails.

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
Ruby 2.1.5, MySQL, Redis (2.4 or greater), Postfix
(Postfix is optional for local development or just trying it out. Some things like the email deliverability just won't show anything)

Also you need the following libraries:
imagemagick, libmagickwand-dev, libmysqld-dev

##To install:

We use [Vagrant](https://www.vagrantup.com/) and [Ansible](http://docs.ansible.com/) to automatically set up a fresh server with everything you need to run Cuttlefish. It's a fairly complicated affair as Cuttlefish does have quite a few moving
parts but all of this is with the purpose of making it easier for the developer sending mail.

These instructions are currently for installing the server at cuttlefish.oaf.org.au. They're not
yet generic. Maybe you can [help with this](https://github.com/mlandauer/cuttlefish/issues/226)?

### To install to a local test virtual machine

1. Create a file `~/.cuttlefish_ansible_vault_pass.txt` which contains the password for encrypting the secret values used in the deploy. The encrypted variables are at `provisioning/roles/cuttlefish-app/vars/main.yml`.

2. Download base box and build virtual machine with everything needed for Cuttlefish. This will take a while (at least 30 mins or so)
```
vagrant up
```

3. Deploy the application. As this is the first deploy it will take quite a while (5 mins or so). Further deploys will be much quicker
```
cap deploy:setup
cap deploy:cold
cap foreman:export
cap foreman:restart
```

4. Add to your local `/etc/hosts` file
```
127.0.0.1       cuttlefish.oaf.org.au
```

5. Point your web browser at https://cuttlefish.oaf.org.au:8443/

### To install on [Linode](https://www.linode.com/)

1. Login at the [Linode Manager](https://manager.linode.com/)

2. [Add a new Linode](https://manager.linode.com/linodes/add)

3. Select "Linode 2048" at location "Fremont, CA"

4. Select your new Linode in the dashboard

5. Click "Deploy a Linux Distribution". Choose "Ubuntu 14.04 LTS" and choose a root password. Leave everything as default.

6. Click "Boot" and wait for it to start up

8. Update `provisioning/hosts` with the name of your server (e.g. li123-45.members.linode.com)

9. Create a file `~/.cuttlefish_ansible_vault_pass.txt` which contains the password for encrypting the secret values used in the deploy. The encrypted variables are at `provisioning/roles/cuttlefish-app/vars/main.yml`.

10. Provision the server with Ansible. You'll need to supply the root password you chose in step 5. On subsequent deploys you won't need this.
```
./provision_production.sh
```

11. Update the server name in `config/deploy.rb`

12. Deploy the application. As this is the first deploy it will take quite a while (5 mins or so). Further deploys will be much quicker
```
cap deploy:setup
cap deploy:cold
cap foreman:export
cap foreman:restart
```

13. At this stage you might want to snapshot the disk

14. Make sure that DNS for cuttlefish.oaf.org.au points to the server ip address

14. Point your browser at https://cuttlefish.org.au

At this point you should have a basic working setup. You should be able to send test mail and see it getting delivered.

Some further things to ensure things work smoothly

1. Add DNS TXT record for cuttlefish.oaf.org.au with "v=spf1 ip4:your.server.ip4.address ip6:your.server.ip6.address -all"

2. Set up incoming email for cuttlefish.oaf.org.au (In OpenAustralia Foundation's case using Google Apps for domain). Add addresses contact@cuttlefish.oaf.org.au, bounces@cuttlefish.oaf.org.au and sender@cuttlefish.oaf.org.au

2. Ensure that the devise email address is set to contact@cuttlefish.oaf.org.au

3. Set up reverse DNS. In the Linode Manager under "Remote Access" click "Reverse DNS" then for the hostname put in "cuttlefish.oaf.org.au" and follow the instructions. This step is necessary in order to be able to sign up to receive [Feedback loop emails](https://en.wikipedia.org/wiki/Feedback_loop_%28email%29).


## Screenshots
Done some development work which updates the look of the main pages? To update the screenshots
```
bundle exec rspec spec/features/screenshot_feature.rb
```
Then commit the results

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
