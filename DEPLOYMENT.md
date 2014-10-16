# Deploying Cuttlefish for production

## Summary

- [Ensure you need Cuttlefish](#need)
- [Install postfix](#postfix)
- [Add new user](#user) - **All the commands after
  this will be run through this new user account**
- [Install RVM](#rvm)
- [Fork Cuttlefish](#fork)
- [Deploy code on server](#deploy)
- [Setup Foreman](#foreman)
- [Install Passenger with Nginx](#passenger)
- [Configure Nginx for cuttlefish](#nginx)
- [Setup Cloudflare for HTTPS](#cloudflare)
- [Enjoy!](#fun)



### <a name='need'></a> Need for cuttlefish

There are plenty of awesome transactional mail
services such as: Mandrill, SendGrid, PostMark,
MailJet - all of these provide a sufficient free
quota of around 10,000 emails per month.

If you use Amazon AWS for hosting, then you can
even use Amazon SES service which provides 60,000
free emails per month (for 1 year).

If your usage is enormous, however, then these
services will cost you a (hell) lot of money. If
you are worried about spending that much amount,
then Cuttlefish is for you.



### <a name='need'></a> Install Postfix

You will need to have Postfix installed to send
out the mails through Cuttlefish.

[**Follow this guide to install Postfix**][postfix]
[postfix]: https://www.digitalocean.com/community/tutorials/how-to-install-and-setup-postfix-on-ubuntu-12-04

For Amazon Linux AMI on AWS: replace `apt-get`
with `yum`. The default `main.cf`
might have the entries for `myhostname` commented.
Uncomment these lines as required in the [above guide][postfix].



### <a name='user'></a> Add new user

It is easier and safer to deploy the webapp
through a non-root user account.

[**Follow this guide to add a user account**][user].

After creating the user account, you will also need to
enable shell access for the account.

    $ sudo su - NEWUSERNAME
    $ mkdir .ssh
    $ chmod 700 .ssh
    $ touch .ssh/authorized_keys
    $ chmod 600 .ssh/authorized_keys
    $ nano .ssh/authorized_keys
    # Paste your system's public key
    # and try `ssh NEWUSERNAME@YOURHOST` from local system

You can follow this [detailed guide for Amazon Linux AMI on AWS][aws-user].

[user]: https://www.digitalocean.com/community/tutorials/how-to-add-and-delete-users-on-ubuntu-12-04-and-centos-6
[aws-user]: http://docs.aws.amazon.com/AWSEC2/latest/UserGuide/managing-users.html

#### All the commands now will be run through this new user account - with or without `sudo` as required



### <a name='rvm'></a> Install RVM

From this new user account do: `\curl -sSL https://get.rvm.io | bash -s stable`


### <a name='fork'></a> Fork / Clone Cuttlefish

Clone Cuttlefish on your local system.

Create a new *production branch* for modifications: `git checkout -b production`

Create a new private repository: check Bitbucket or Gitlab.

Add this new repository: `git remote add bitbucket git@bitbucket.org:USERNAME/REPO.git`

Edit these files:

`config/database.yml` - for database settings

`config/deploy.rb` - For production server and repository settings

`config/envoirments/production.rb` - For domain name and secret keys

Push the changes in the *production branch* to the private
repository: `git push -u bitbucket producttion`



### <a name='deploy'></a> Deploy code on server

**Run following on local machine:**

Push the code to server and install the
dependencies:

    bundle exec cap deploy:setup

Setup the database configs (**run only first time**):

    bundle exec cap deploy:cold

*Troubleshoot 1: If `gem install mysql2` fails
then [have a look here.][mysql-dev]*

*Troubleshoot 2: The above might also fail if
MySQL is not already installed or the database is
not created on the database. To install and create
database, check [this guide][mysql-ubuntu] or this or this for
AWS.*

[mysql-ubuntu]: https://help.ubuntu.com/community/ApacheMySQLPHP#Installing_MYSQL_with_PHP_5
[mysql-do]: https://www.digitalocean.com/community/tutorials/how-to-install-linux-apache-mysql-php-lamp-stack-on-ubuntu
[mysql-aws]: http://docs.aws.amazon.com/gettingstarted/latest/computebasics-linux/getting-started-deploy-app-download-app.html
[mysql-dev]: http://stackoverflow.com/questions/5219855/gem-install-mysql2-fails/9400208#9400208



### <a name='foreman'></a> Setup Foreman

We use the *upstart* service to create commands
for running the Cuttlefish processes. To install
the service, run the command from local machine:

    $ bundle exec cap foreman:export

The command will install the cuttlefish service
on server - you should now be able to do `sudo service
cuttlefish restart` or `sudo restart cuttlefish`.

*(Replace `cuttlefish` with the application name
set in `deploy.rb`.)*



### <a name='passenger'></a> Install Passenger with Nginx

Passenger is an easy way to deploy rails
applications using either Nginx or Apache. For
this tutorial, we will be using nginx.

    $ rvm list
    # ensure the right ruby installation is selected
    $ gem install passenger
    $ rvmsudo passenger-install-nginx-module

The last command will install passenger as well as
Nginx. It will also automatically configure Nginx
to work with Passenger.

To start Nginx as a service, however, we will need
to add it to `/etc/init.d/`. For this run the
following:

    $ wget "https://gist.githubusercontent.com/dannguyen/5415991/raw/3a67b40730e554ef2b60aed25caa73fb76bc25f6/centos-nginx.sh"
    $ sudo mv centos-nginx.sh /etc/init.d/nginx

    # make script executable
    $ sudo chmod +x /etc/init.d/nginx

    # Auto-start nginx on startup
    $ sudo /sbin/chkconfig nginx on

    $ sudo /etc/init.d/nginx start



### <a name='nginx'></a> Configure Nginx for cuttlefish

Edit `nginx.conf` (probably located at
`/opt/nginx/conf/nginx.conf`) and add the
application configuration, something like:

    ...
    server {
        listen       80;
        server_name  domainname.com;
        passenger_enabled on;
        root /home/users/path/to/deploy/current/public;

        error_log /home/users/logs/nginx_error.log;
        access_log /home/users/logs/nginx_access.log main;
    }
    ...

**Ensure that the root is set to the `public`
folder inside the `current` folder.**



### <a name='cloudflare'></a> Setup Cloudflare for HTTPS

Cuttlefish currently works only with SSL
connections. This ensures your as your users
safety. You can use CloudFlare's **free**
Universal SSL service to enable SSL connections
for your website in a click.



### <a name='fun'></a> Enjoy!

The Cuttlefish self-hosted transaction mail
service should be live and running now.

For updates in code or configuration, you can do
`bundle exec cap deploy:update`.

**Enjoy!!!**
