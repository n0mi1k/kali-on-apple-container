# kali-on-apple-container
Run **persisted Kali** seamlessly on Apple's MacOS's lightweight Container service (https://github.com/apple/container).

**NOTE:** By persistence, it means that the container can be stopped, started and reused, mimicking a VM-like experience but with containers.

I love using containers to run Kali due to its lightweightness and speed when starting a session. Apple's Container service ensures fast and lightweight runtime of containers on MacOS.

# 📦 Setup
Its simple! Just run `./setup.sh`.

By default, a container `kali-container` is created before mounting the directory `kali-share` from `~/Desktop` to the container allowing cross file sharing between MacOS.

After using the container, enter `exit` to close the session and the container stops automatically. Use the command `kali-start` to start and get back to the container. If you want to open multiple shells, run `kali-shell` when the container is running. Check container status with `container list -a`.

Kali images does not come with any packages installed. After setup, run the below two commands in a `kali-container` session to install packages and tools such as `nmap` and `msfconsole`.
```Bash
apt-get update
apt install -y kali-linux-headless
```
Need to rebuild or create a new container? Just re-run the script! You may delete old containers with `container rm <container-name>`.

## ⚙️ Resource Allocation
To allocate more resources, such as using `4` CPUs and `8GB` of memory, modify below variables in `setup.sh`:
```Bash
CONTAINER_CPUS="4"
CONTAINER_MEMORY="8GB"
```
Otherwise, **leave empty as `""` to use default system values**. If you wish to configure CPU and Memory resources, set the above in `setup.sh` before running.

# 🚀 Command Aliases
The following commands will be available after setup. They are meant for making it easy to start your kali session. Make sure to run `source ~/.zshrc` or start a new shell after setup to enable the aliases.
* `kali-start`: This starts the container again after it was exited
* `kali-shell`: This spawns additional shell sessions on a running container
