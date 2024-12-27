ip = '10.10.10.10'

def provisionUnits(files, config)
    for file in files do
        config.vm.provision :file, source: file, destination: "/tmp/units/#{file}"
    end
end

Vagrant.configure('2') do |config|
    config.vm.box = "rockylinux/9"
    config.vm.hostname = "quadlet-testing"
    config.vm.network :private_network, ip: ip

    config.vm.provider :virtualbox do |v|
        v.name = "quadlet-testing"
        v.memory = 2048
        v.cpus = 2
    end

    config.vm.provision :shell, inline: <<-SHELL
        # Installing cockpit just to have some nice web ui to manage the vm, not mandatory.
        # cockpit-podman allows us to manage podman containers through the web ui.
        # The only required package here is podman
        dnf update -y
        dnf install podman cockpit cockpit-podman -y
        firewall-cmd --permanent --add-service=cockpit
        firewall-cmd --permanent --add-service=http
        firewall-cmd --permanent --add-service=https
        systemctl enable --now cockpit.socket
        systemctl enable --now firewalld.service
        systemctl enable --now podman.service
    SHELL

    # Provision units and config files in /tmp
    provisionUnits [
        'caddy.container',
        'keycloak.container',
        'playground.network',
        'postgresql.container',
        'postgresql.volume',
        'entrypoints/init-postgres.sh',
        'http/Caddyfile',
    ], config

    config.vm.provision :shell, inline: <<-SHELL
        # Containers will need to read secrets, the redirect of stderr to /dev/null is just
        # to avoid blocking the re-provisioning when the secrets already exist inside the vm
        printf "admin" | podman secret create keycloak_admin_password - 2> /dev/null
        printf ")V3ry-S3Cr3t!!!11!!" | podman secret create postgres_password - 2> /dev/null
        printf "#S3Cr3t!!1!!1" | podman secret create postgres_keycloak_password - 2> /dev/null

        # /etc/containers/systemd/ is the directory for system admin services.
        # For user services, unit files will need to go to /etc/containers/systemd/users/
        # or ~/.config/containers/systemd/ for example.
        # https://docs.podman.io/en/latest/markdown/podman-systemd.unit.5.html#podman-rootful-unit-search-path
        rsync -r --delete /tmp/units/* /etc/containers/systemd/
        rm -rf /tmp/units/*

        # We need to either reboot, or do a daemon-reload and start the services manually.
        # We don't need to start the services for networks or volumes, because
        # they have a direct dependency with the containers, and systemd will
        # know it needs to be started before the containers.
        # https://docs.podman.io/en/latest/markdown/podman-systemd.unit.5.html#description
        systemctl daemon-reload
        systemctl start caddy.service
        systemctl start keycloak.service
        systemctl start postgresql.service
    SHELL
end
