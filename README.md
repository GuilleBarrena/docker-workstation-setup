# Docker Server Setup on Debian-based Workstation

This Makefile automates the process of setting up a Docker server on a Debian-based workstation. It performs the following tasks:

- Sets up SSH access to the workstation
- Configures the firewall to allow incoming traffic on the specified Docker port
- Installs Docker and its dependencies
- Configures Docker to listen on the specified IP address and port, and to use TLS encryption with a self-signed certificate

## Configuration

Before running the Makefile, you need to configure the following variables:

- `IP`: The IP address of the workstation on which to set up the Docker server. This should be a private IP address that is reachable from your other devices on the network. The default value is `192.168.1.2`.
- `PORT`: The port on which the Docker server should listen for incoming connections. The default value is `2375`.
- `PUBKEY`: The path to your SSH public key. This key will be used to set up SSH access to the workstation. The default value is `$(shell pwd)/id_rsa.pub`.

You can set these variables by passing them as arguments to the `make` command. For example:

```make IP=192.168.1.3 PORT=2376 PUBKEY=/path/to/my/pubkey```

Alternatively, if you don't specify these variables, the Makefile will prompt you for them before each step.

## Running the Makefile

To set up the Docker server, simply run the Makefile:

```make```

This will execute each step in the process of setting up the Docker server. Once the Makefile has finished running, it will output a success message that includes the SSH command to connect to the Docker server.

## Connecting to the Docker Server

To connect to the Docker server, run the following command on your local machine:

```ssh -i /path/to/your/private/key root@192.168.1.2```

Replace `/path/to/your/private/key` with the path to your SSH private key, and `192.168.1.2` with the IP address of your Docker server. You should now be able to run Docker commands on the remote machine.

## Conclusion

With this Makefile, you can easily set up a Docker server on a Debian-based workstation. By automating the setup process, you can save time and ensure that your Docker server is configured securely and consistently.

