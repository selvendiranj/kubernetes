# References

## Container Linux
- https://linoxide.com/distros/install-coreos-virtualbox-iso/
- https://gist.github.com/noonat/9fc170ea0c6ddea69c58
- https://www.jsdelivr.com/?docs=gh
- https://coreos.com/os/docs/latest/booting-with-iso.html
- https://www.ssh.com/ssh/putty/download

## Container Linux Installation
- Create VM in vmware/virtualbox/hyperv with your desired networking (NAT/Bridged/Internal)
- boot into downloaded container linux iso
- curl https://cdn.jsdelivr.net/gh/jselvendiran/kubernetes/cloud_config.yaml
- coreos-cloudinit -validate --from-file cloud_config.yml
- sudo coreos-install -d /dev/sda -C stable -c cloud_config.yml
- After install gracefully shutdown guest and remove virtual boot image

## Connect to Container Linux & Check Installation
- ssh to Node with privateKey file
- rkt version
- docker version
- uname -r
- cat /etc/motd

## Install kubeadm, Kubelet, kubectl
- 

## Init Master Node


## Join Worker Node
