# Podman Quadlet PoC

This repo demonstrates a small orchestration of containers using Systemd and Podman.

Containers that will be running
- Keycloak (1 instance)
- PostgreSQL database server for Keycloak (1 instance)
- Caddy as a reverse proxy for Keycloak (1 instance)

## Launch the environment

To launch the environment you will need [Vagrant](https://www.vagrantup.com/) and [VirtualBox](https://www.virtualbox.org/) installed on your system.

The caddy web server proxies requests from https://keycloak.local to the Keycloak container, so you will need to add an entry in your `/etc/hosts` file like this (or `c:\Windows\System32\Drivers\etc\hosts` if you're on Windows):
```shell
# ...

# this IP address is specified inside the Vagrantfile, you can change it if needed
10.10.10.10 keycloak.local
```

To launch the VM, run the `vagrant up` command.

To ssh into the VM, you can run `vagrant ssh`.

The Cockpit web UI is also installed and available on https://10.10.10.10:9090 (default credentials: vagrant, vagrant)
Keycloak creds are admin, admin
