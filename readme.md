# References
- https://linoxide.com/distros/install-coreos-virtualbox-iso/
- https://gist.github.com/noonat/9fc170ea0c6ddea69c58
- https://www.jsdelivr.com/?docs=gh
- https://coreos.com/os/docs/latest/booting-with-iso.html
- https://www.ssh.com/ssh/putty/download

## Installation
- boot into download container linux iso
- curl https://cdn.jsdelivr.net/gh/jselvendiran/kubernetes/cloud_config.yaml
- coreos-cloudinit -validate --from-file cloud_config.yml
- sudo coreos-install -d /dev/sda -C stable -c cloud_config.yml
- ssh to Node with privateKey file

- rkt version
- docker -v
- uname -r
- cat /etc/motd
