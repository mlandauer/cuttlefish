Simple Debian Installation
==========================

Here is a simple and neutral install recipe.

    vagrant up

Patch your /etc/hosts

    192.168.33.22 cuttlefish.example.com

Ansible it

    ansible-playbook -i host.vagrant -vv playbook.yml

Enjoy the web interface

    http://cuttlefish.example.com

And the SMTP server

    telnet cuttlefish.example.com 2525

Now you can write your own host file, with production settings.

TODO
----
 * Using _deploy.yml_ playbook with cuttlefish user
