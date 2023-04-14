# Makefile to set up a Docker server on a Debian-based workstation
# Usage: make

IP := 192.168.1.2
PORT ?= 2375
PUBKEY ?= $(shell pwd)/id_rsa.pub

.PHONY: all setup_ssh setup_firewall install_docker configure_docker

all:
	@echo "-----------------------------------------------------------------"
	@echo "Makefile to set up a Docker server on a Debian-based workstation"
	@echo "-----------------------------------------------------------------"
	@read -p "Enter workstation IP (default $(IP)): " ip; \
	[ -n "$$ip" ] && IP=$$ip; \
	echo "Using IP: $$IP"; \
	read -p "Enter Docker port (default $(PORT)): " port; \
	[ -n "$$port" ] && PORT=$$port; \
	echo "Using port: $$PORT"; \
	read -p "Enter path to SSH public key (default $(PUBKEY)): " pubkey; \
	[ -n "$$pubkey" ] && PUBKEY=$$pubkey; \
	echo "Using public key: $$PUBKEY"; \
	make setup_ssh IP=$$IP PUBKEY=$$PUBKEY; \
	make setup_firewall IP=$$IP PORT=$$PORT; \
	make install_docker; \
	make configure_docker IP=$$IP PORT=$$PORT; \
	echo "-----------------------------------------------------------------"
	@echo "Docker server set up successfully on $$IP!"
	@echo "Use the following command to connect to the Docker server:"
	@echo "ssh -i $(PUBKEY) root@$$IP"

setup_ssh:
	ssh-copy-id -i $(PUBKEY) root@$(IP)

setup_firewall:
	ufw allow OpenSSH
	ufw allow $(PORT)/tcp
	ufw --force enable

install_docker:
	apt-get update
	apt-get install -y apt-transport-https ca-certificates curl gnupg lsb-release
	curl -fsSL https://download.docker.com/linux/debian/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
	echo "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/debian $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null
	apt-get update
	apt-get install -y docker-ce docker-ce-cli containerd.io

configure_docker:
	mkdir -p /etc/docker
	openssl req -newkey rsa:4096 -nodes -sha256 -keyout /etc/docker/server-key.pem -out /etc/docker/server-csr.pem -subj '/CN=$(IP)'
	openssl x509 -req -days 365 -in /etc/docker/server-csr.pem -signkey /etc/docker/server-key.pem -out /etc/docker/server-cert.pem
	openssl genrsa -out /etc/docker/ca-key.pem 4096
	openssl req -new -x509 -days 365 -key /etc/docker/ca-key.pem -out /etc/docker/ca.pem -subj '/CN=$(IP)'
	printf '{\n  "hosts": ["tcp://0.0.0.0:$(PORT)", "unix:///var/run/docker.sock"],\n  "tls": true,\n  "tlscacert": "/etc/docker/ca.pem",\n  "tlscert": "/etc/docker/server-cert.pem",\n 
