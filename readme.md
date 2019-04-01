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
swapoff -a
sudo su

```
Install CNI plugins (required for most pod network):
CNI_VERSION="v0.6.0"
mkdir -p /opt/cni/bin
curl -L "https://github.com/containernetworking/plugins/releases/download/${CNI_VERSION}/cni-plugins-amd64-${CNI_VERSION}.tgz" | tar -C /opt/cni/bin -xz

Install crictl (required for kubeadm / Kubelet Container Runtime Interface (CRI))
CRICTL_VERSION="v1.11.1"
mkdir -p /opt/bin
curl -L "https://github.com/kubernetes-incubator/cri-tools/releases/download/${CRICTL_VERSION}/crictl-${CRICTL_VERSION}-linux-amd64.tar.gz" | tar -C /opt/bin -xz

Install kubeadm, kubelet, kubectl and add a kubelet systemd service:
RELEASE="$(curl -sSL https://dl.k8s.io/release/stable.txt)"

mkdir -p /opt/bin
cd /opt/bin
curl -L --remote-name-all https://storage.googleapis.com/kubernetes-release/release/${RELEASE}/bin/linux/amd64/{kubeadm,kubelet,kubectl}
chmod +x {kubeadm,kubelet,kubectl}

curl -sSL "https://raw.githubusercontent.com/kubernetes/kubernetes/${RELEASE}/build/debs/kubelet.service" | sed "s:/usr/bin:/opt/bin:g" > /etc/systemd/system/kubelet.service
mkdir -p /etc/systemd/system/kubelet.service.d
curl -sSL "https://raw.githubusercontent.com/kubernetes/kubernetes/${RELEASE}/build/debs/10-kubeadm.conf" | sed "s:/usr/bin:/opt/bin:g" > /etc/systemd/system/kubelet.service.d/10-kubeadm.conf

exit # exit from super user mode

Enable and start kubelet:
systemctl enable --now kubelet

Restarting the kubelet is required:
systemctl daemon-reload
systemctl restart kubelet


kubeadm join 192.168.1.102:6443 --token 2l6ljb.bfowdygayi95wt7t --discovery-token-ca-cert-hash sha256:2c7787ddec84b25c68d6233fafcf23db807c94cf1b9e267ce6dc07a37614e5d8
```

## Init Master Node


## Join Worker Node
