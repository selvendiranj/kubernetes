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
- Execute these commands to install coreos
```
curl https://cdn.jsdelivr.net/gh/jselvendiran/kubernetes/cloud_config.yaml -o cloud-config.yaml
coreos-cloudinit -validate --from-file cloud-config.yml
sudo coreos-install -d /dev/sda -C stable -c cloud-config.yml
```
- After install gracefully shutdown guest and remove virtual boot image

## Connect to Container Linux & Check Installation
- ssh to Node with privateKey file
- rkt version
- docker version
- uname -r
- cat /etc/motd

## Install kubeadm, Kubelet, kubectl
### References
 - https://kubernetes.io/docs/setup/independent/install-kubeadm/
 - https://kubernetes.io/docs/setup/independent/create-cluster-kubeadm/
 - https://kubernetes.io/docs/reference/setup-tools/kubeadm/kubeadm-init/
 - https://kubernetes.io/docs/reference/setup-tools/kubeadm/kubeadm-join/
 - https://gist.github.com/kevashcraft/5aa85f44634c37a9ee05dde7e83ac7e2
 
```
swapoff -a
sudo su
```

Install CNI plugins (required for most pod network):
```
CNI_VERSION="v0.6.0"
mkdir -p /opt/cni/bin
curl -L "https://github.com/containernetworking/plugins/releases/download/${CNI_VERSION}/cni-plugins-amd64-${CNI_VERSION}.tgz" | tar -C /opt/cni/bin -xz
```

Install crictl (required for kubeadm / Kubelet Container Runtime Interface (CRI))
```
CRICTL_VERSION="v1.11.1"
mkdir -p /opt/bin
curl -L "https://github.com/kubernetes-incubator/cri-tools/releases/download/${CRICTL_VERSION}/crictl-${CRICTL_VERSION}-linux-amd64.tar.gz" | tar -C /opt/bin -xz
```

Install kubeadm, kubelet, kubectl and add a kubelet systemd service:
```
RELEASE="$(curl -sSL https://dl.k8s.io/release/stable.txt)"
mkdir -p /opt/bin
cd /opt/bin
curl -L --remote-name-all https://storage.googleapis.com/kubernetes-release/release/${RELEASE}/bin/linux/amd64/{kubeadm,kubelet,kubectl}
chmod +x {kubeadm,kubelet,kubectl}

curl -sSL "https://raw.githubusercontent.com/kubernetes/kubernetes/${RELEASE}/build/debs/kubelet.service" | sed "s:/usr/bin:/opt/bin:g" > /etc/systemd/system/kubelet.service
mkdir -p /etc/systemd/system/kubelet.service.d
curl -sSL "https://raw.githubusercontent.com/kubernetes/kubernetes/${RELEASE}/build/debs/10-kubeadm.conf" | sed "s:/usr/bin:/opt/bin:g" > /etc/systemd/system/kubelet.service.d/10-kubeadm.conf
```

exit from super user mode
```
exit
```

Enable and start kubelet:
```
sudo systemctl enable --now kubelet
```

Restarting the kubelet is required:
```
sudo systemctl daemon-reload
sudo systemctl restart kubelet
```

prior to kubeadm init to verify connectivity to gcr.io registries:

```
sudo kubeadm config images pull
```

Enable docker service prior to init:
```
sudo systemctl enable docker.service
```

Ignore cgroupfs driver warning message as cgroupfs is the docker default driver.

```
sudo kubeadm init
```
Copy the console output and save it. it is needed to join other worker node to the cluster

Sample token and hashkey:
```
kubeadm join 192.168.1.101:6443 --token i5f4a6.shvz07nd1a1h0yli --discovery-token-ca-cert-hash sha256:62f980861d949412076c95e222262e426566db87bd3e8c2aa63995ad616df2cb
```

For kubectl to work in MasterNode:
```shell
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config
```

To interact with kubernetes cluster from outside cluster
```shell
install kubectl and set in path
scp -i ~/.kube/<privatekeyfile> user@<ipaddr>:/etc/kubernetes/admin.conf /$Home/.kube/config
or
pscp -i ~/.kube/<privatekeyfile> user@<ipaddr>:/etc/kubernetes/admin.conf ~/.kube/config
kuberctl version
```
