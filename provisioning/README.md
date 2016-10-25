# Provisioning

This directory contains an [Ansible](https://www.ansible.com/) playbook that
you can use to setup your own machine to run Cuttlefish on. It assumes you have
a fresh server - if you try to run this against one that you use for something
else it is likely to break things and destroy your data.

To use this you don't need to be familiar with Ansible, but first you need to
install it on your machine to run the playbook. On OS X you can use brew:

    brew install ansible

## Configuration

All the configuration will be stored in `group_vars/all`, this file doesn't
exist yet, so copy over the sample file:

    cp group_vars/all{.example,}

Then open it up in your editor, and follow the instructions. Note that the file
is in YAML format, so spacing is important.

Next create a file `hosts` in this directory, which should contain a single
line with the IP or domain name of the server you want to provision. Ansible
will connect to this server via SSH as `root`, so you'll either need the
password or your SSH key setup.

If you want to commit these files to Git, you'll need to remove them from the
`.gitignore` in this directory. Beware these contain sensitive information! You
probably want to use [Ansible Vault](http://docs.ansible.com/ansible/playbooks_vault.html)
to encrypt them before committing.

## Walkthrough: Deploying on [Linode](https://www.linode.com/)

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

