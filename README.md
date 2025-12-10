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