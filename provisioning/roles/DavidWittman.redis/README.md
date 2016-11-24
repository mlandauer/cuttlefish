# ansible-redis

[![Build Status](https://travis-ci.org/DavidWittman/ansible-redis.svg?branch=master)](https://travis-ci.org/DavidWittman/ansible-redis) [![Ansible Galaxy](https://img.shields.io/badge/galaxy-DavidWittman.redis-blue.svg?style=flat)](https://galaxy.ansible.com/detail#/role/730)

 - Requires Ansible 1.6.3+
 - Compatible with most versions of Ubuntu/Debian and RHEL/CentOS 6.x

## Contents

 1. [Installation](#installation)
 2. [Getting Started](#getting-started)
  1. [Single Redis node](#single-redis-node)
  2. [Master-Slave Replication](#master-slave-replication)
  3. [Redis Sentinel](#redis-sentinel)
 3. [Installing redis from a source file in the ansible role](#installing-redis-from-a-source-file-in-the-ansible-role)
 4. [Verifying checksums](#verifying-checksums)
 5. [Role Variables](#role-variables)

## Installation

``` bash
$ ansible-galaxy install DavidWittman.redis
```

## Getting started

Below are a few example playbooks and configurations for deploying a variety of Redis architectures.

This role expects to be run as root or as a user with sudo privileges.

### Single Redis node

Deploying a single Redis server node is pretty trivial; just add the role to your playbook and go. Here's an example which we'll make a little more exciting by setting the bind address to 127.0.0.1:

``` yml
---
- hosts: redis01.example.com
  vars:
    - redis_bind: 127.0.0.1
  roles:
    - DavidWittman.redis
```

``` bash
$ ansible-playbook -i redis01.example.com, redis.yml
```

**Note:** You may have noticed above that I just passed a hostname in as the Ansible inventory file. This is an easy way to run Ansible without first having to create an inventory file, you just need to suffix the hostname with a comma so Ansible knows what to do with it.

That's it! You'll now have a Redis server listening on 127.0.0.1 on redis01.example.com. By default, the Redis binaries are installed under /opt/redis, though this can be overridden by setting the `redis_install_dir` variable.

### Master-Slave replication

Configuring [replication](http://redis.io/topics/replication) in Redis is accomplished by deploying multiple nodes, and setting the `redis_slaveof` variable on the slave nodes, just as you would in the redis.conf. In the example that follows, we'll deploy a Redis master with three slaves.

In this example, we're going to use groups to separate the master and slave nodes. Let's start with the inventory file:

``` ini
[redis-master]
redis-master.example.com

[redis-slave]
redis-slave0[1:3].example.com
```

And here's the playbook:

``` yml
---
- name: configure the master redis server
  hosts: redis-master
  roles:
    - DavidWittman.redis

- name: configure redis slaves
  hosts: redis-slave
  vars:
    - redis_slaveof: redis-master.example.com 6379
  roles:
    - DavidWittman.redis
```

In this case, I'm assuming you have DNS records set up for redis-master.example.com, but that's not always the case. You can pretty much go crazy with whatever you need this to be set to. In many cases, I tell Ansible to use the eth1 IP address for the master. Here's a more flexible value for the sake of posterity:

``` yml
redis_slaveof: "{{ hostvars['redis-master.example.com'].ansible_eth1.ipv4.address }} {{ redis_port }}"
```

Now you're cooking with gas! Running this playbook should have you ready to go with a Redis master and three slaves.

### Redis Sentinel

#### Introduction

Using Master-Slave replication is great for durability and distributing reads and writes, but not so much for high availability. If the master node fails, a slave must be manually promoted to master, and connections will need to be redirected to the new master. The solution for this problem is [Redis Sentinel](http://redis.io/topics/sentinel), a distributed system which uses Redis itself to communicate and handle automatic failover in a Redis cluster.

Sentinel itself uses the same redis-server binary that Redis uses, but runs with the `--sentinel` flag and with a different configuration file. All of this, of course, is abstracted with this Ansible role, but it's still good to know.

#### Configuration

To add a Sentinel node to an existing deployment, assign this same `redis` role to it, and set the variable `redis_sentinel` to True on that particular host. This can be done in any number of ways, and for the purposes of this example I'll extend on the inventory file used above in the Master/Slave configuration:

``` ini
[redis-master]
redis-master.example.com

[redis-slave]
redis-slave0[1:3].example.com

[redis-sentinel]
redis-sentinel0[1:3].example.com redis_sentinel=True
```

Above, we've added three more hosts in the **redis-sentinel** group (though this group serves no purpose within the role, it's merely an identifier), and set the `redis_sentinel` variable inline within the inventory file.

Now, all we need to do is set the `redis_sentinel_monitors` variable to define the Redis masters which Sentinel should monitor. In this case, I'm going to do this within the playbook:

``` yml
- name: configure the master redis server
  hosts: redis-master
  roles:
    - DavidWittman.redis

- name: configure redis slaves
  hosts: redis-slave
  vars:
    - redis_slaveof: redis-master.example.com 6379
  roles:
    - DavidWittman.redis

- name: configure redis sentinel nodes
  hosts: redis-sentinel
  vars:
    - redis_sentinel_monitors:
      - name: master01
        host: redis-master.example.com
        port: 6379
  roles:
    - DavidWittman.redis
```

This will configure the Sentinel nodes to monitor the master we created above using the identifier `master01`. By default, Sentinel will use a quorum of 2, which means that at least 2 Sentinels must agree that a master is down in order for a failover to take place. This value can be overridden by setting the `quorum` key within your monitor definition. See the [Sentinel docs](http://redis.io/topics/sentinel) for more details.

Along with the variables listed above, Sentinel has a number of its own configurables just as Redis server does. These are prefixed with `redis_sentinel_`, and are enumerated in the **Role Variables** section below.


## Installing redis from a source file in the ansible role

If the environment your server resides in does not allow downloads (i.e. if the machine is sitting in a dmz) set the variable `redis_tarball` to the path of a locally downloaded tar.gz file to prevent a http download from redis.io.
Do not forget to set the version variable to the same version of the tar.gz. to avoid confusion !

For example (file was stored in same folder as the playbook that included the redis role):
```yml
vars:
  - redis_version: 2.8.14
  - redis_tarball: redis-2.8.14.tar.gz
```
In this case the source archive is copied towards the server over ssh rather than downloaded.

## Verifying checksums

Set the `redis_verify_checksum` variable to true to use the checksum verification option for `get_url`. Note that this will only verify checksums when Redis is downloaded from a URL, not when one is provided in a tarball with `redis_tarball`. Due to differences in the `get_url` module in Ansible 1.x and Ansible 2.x, this feature behaves differently depending on the version of Ansible which you are using.

### Ansible 1.x

In Ansible 1.x, the `get_url` module only support verifying sha256 checksums, which are not provided by default. If you wish to set `redis_verify_checksum`, you must also define a sha256 checksum with the `redis_checksum` variable.

``` yaml
- name: install redis on ansible 1.x and verify checksums
  hosts: all
  roles:
    - role: DavidWittman.redis
      redis_version: 3.0.7
      redis_verify_checksum: true
      redis_checksum: b2a791c4ea3bb7268795c45c6321ea5abcc24457178373e6a6e3be6372737f23
```

### Ansible 2.x

When using Ansible 2.x, this role will verify the sha1 checksum of the download against checksums defined in the `redis_checksums` variable in `vars/main.yml`. If your version is not defined in here or you wish to override the checksum with one of your own, simply set the `redis_checksum` variable. As in the example below, you will need to prefix the checksum with the type of hash which you are using.

``` yaml
- name: install redis on ansible 1.x and verify checksums
  hosts: all
  roles:
    - role: DavidWittman.redis
      redis_version: 3.0.7
      redis_verify_checksum: true
      redis_checksum: "sha256:b2a791c4ea3bb7268795c45c6321ea5abcc24457178373e6a6e3be6372737f23"
```

## Role Variables

Here is a list of all the default variables for this role, which are also available in defaults/main.yml. One of these days I'll format these into a table or something.

``` yml
---
## Installation options
redis_version: 2.8.9
redis_install_dir: /opt/redis
redis_user: redis
redis_group: "{{ redis_user }}"
redis_dir: /var/lib/redis/{{ redis_port }}
redis_download_url: "http://download.redis.io/releases/redis-{{ redis_version }}.tar.gz"
redis_verify_checksum: false
redis_tarball: false
# The open file limit for Redis/Sentinel
redis_nofile_limit: 16384

## Role options
# Configure Redis as a service
# This creates the init scripts for Redis and ensures the process is running
# Also applies for Redis Sentinel
redis_as_service: true
# Add local facts to /etc/ansible/facts.d for Redis
redis_local_facts: true
# Service name
redis_service_name: "redis_{{ redis_port }}"

## Networking/connection options
redis_bind: 0.0.0.0
redis_port: 6379
redis_password: false
redis_tcp_backlog: 511
redis_tcp_keepalive: 0
# Max connected clients at a time
redis_maxclients: 10000
redis_timeout: 0
# Socket options
# Set socket_path to the desired path to the socket. E.g. /var/run/redis/{{ redis_port }}.sock
redis_socket_path: false
redis_socket_perm: 755

## Replication options
# Set slaveof just as you would in redis.conf. (e.g. "redis01 6379")
redis_slaveof: false
# Make slaves read-only. "yes" or "no"
redis_slave_read_only: "yes"
redis_slave_priority: 100
redis_repl_backlog_size: false

## Logging
redis_logfile: '""'
# Enable syslog. "yes" or "no"
redis_syslog_enabled: "yes"
redis_syslog_ident: "{{ redis_service_name }}"
# Syslog facility. Must be USER or LOCAL0-LOCAL7
redis_syslog_facility: USER

## General configuration
redis_daemonize: "yes"
redis_pidfile: /var/run/redis/{{ redis_port }}.pid
# Number of databases to allow
redis_databases: 16
redis_loglevel: notice
# Log queries slower than this many milliseconds. -1 to disable
redis_slowlog_log_slower_than: 10000
# Maximum number of slow queries to save
redis_slowlog_max_len: 128
# Redis memory limit (e.g. 4294967296, 4096mb, 4gb)
redis_maxmemory: false
redis_maxmemory_policy: noeviction
redis_rename_commands: []
# How frequently to snapshot the database to disk
# e.g. "900 1" => 900 seconds if at least 1 key changed
redis_save:
  - 900 1
  - 300 10
  - 60 10000
redis_appendonly: "no"
redis_appendfilename: "appendonly.aof"
redis_appendfsync: "everysec"
redis_no_appendfsync_on_rewrite: "no"
redis_auto_aof_rewrite_percentage: "100"
redis_auto_aof_rewrite_min_size: "64mb"

## Redis sentinel configs
# Set this to true on a host to configure it as a Sentinel
redis_sentinel: false
redis_sentinel_dir: /var/lib/redis/sentinel_{{ redis_sentinel_port }}
redis_sentinel_bind: 0.0.0.0
redis_sentinel_port: 26379
redis_sentinel_pidfile: /var/run/redis/sentinel_{{ redis_sentinel_port }}.pid
redis_sentinel_logfile: '""'
redis_sentinel_syslog_ident: sentinel_{{ redis_sentinel_port }}
redis_sentinel_monitors:
  - name: master01
    host: localhost
    port: 6379
    quorum: 2
    auth_pass: ant1r3z
    down_after_milliseconds: 30000
    parallel_syncs: 1
    failover_timeout: 180000
    notification_script: false
    client_reconfig_script: false

```

## Facts

The following facts are accessible in your inventory or tasks outside of this role.

- `{{ ansible_local.redis.bind }}`
- `{{ ansible_local.redis.port }}`
- `{{ ansible_local.redis.sentinel_bind }}`
- `{{ ansible_local.redis.sentinel_port }}`
- `{{ ansible_local.redis.sentinel_monitors }}`

To disable these facts, set `redis_local_facts` to a false value.
