# Minimalistic installation for Debian

## Test it

### Spawn your VM

    vagrant up

Your public key is authorized for root user.

### Do admin stuff

    ansible-playbook -i host.vagrant -vv playbook.yml

Root authorized keys are copied in cuttlefish user.

### Do dev stuff

    ansible-playbook -i host.vagrant -vv deploy.yml
