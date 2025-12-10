# kali-on-apple-container
Run **persisted Kali** on MacOS's using the lightweight [container service](https://github.com/apple/container).

## Setup
To begin, run `./setup.sh` followed by `source ~/.zshrc` to enable the aliases.

By default, a `kali-container` is created before mounting a directory in `~/Desktop/kali-share/` allowing cross file sharing between MacOS.

**Once setup is successful, the following aliases are added:**
* `kali`: This starts the container and enters the interactive shell
* `kali-shell`: This spawns additional shell sessions on a running container
* `kali-start`: Use this to rebuild your container

Enter `exit` to close the session and the container stops gracefully. Use the command `kali` to start and get back to the container. To spawn multiple shells, run `kali-shell` while the container is running.

If you encounter any network connectivity problems, refer to [this](https://github.com/apple/container/blob/main/docs/technical-overview.md#container-ip-addresses).

### Network Fix (Referenced from Above Link)
In macOS 15, limitations in the vmnet framework mean that the container network can only be created when the first container starts. Since the network XPC helper provides IP addresses to containers, and the helper has to start before the first container, it is possible for the network helper and vmnet to disagree on the subnet address, resulting in containers that are completely cut off from the network.

Normally, vmnet creates the container network using the CIDR address 192.168.64.1/24, and on macOS 15, `container` defaults to using this CIDR address in the network helper. To diagnose and resolve issues stemming from a subnet address mismatch between vmnet and the network helper:

- Before creating the first container, scan the output of the command `ifconfig` for a bridge interface named similarly to `bridge100`.
- After creating the first container, run `ifconfig` again, and locate the new bridge interface to determine the container subnet address.
- Run `container ls` to check the IP address given to the container by the network helper. If the address corresponds to a different network:
  - Run `container system stop` to terminate the services for `container`.
  - Using the macOS `defaults` command, update the default subnet value used by the network helper process. For example, if the bridge address shown by `ifconfig` is 192.168.66.1, run:
    ```bash
    defaults write com.apple.container.defaults network.subnet 192.168.66.1/24
    ```
  - Run `container system start` to launch services again.
  - Try running the container again and verify that its IP address matches the current bridge interface value.

## Kali Metapackages
After setup, run the below two commands in a `kali-container` session to install Kali metapackages which includes security tools such as `nmap` and `msfconsole`.
```Bash
apt-get update
apt install -y kali-linux-headless
```

## Resource Allocation
To allocate more resources, such as using `4` CPUs and `8GB` of memory, modify below variables in `setup.sh`:
```Bash
CONTAINER_CPUS="4"
CONTAINER_MEMORY="8GB"
```
Otherwise, **leave empty as `""` to use default system values**.
