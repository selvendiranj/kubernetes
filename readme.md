# References

## Container Linux
- https://linoxide.com/distros/install-coreos-virtualbox-iso/
- https://gist.github.com/noonat/9fc170ea0c6ddea69c58
- https://www.jsdelivr.com/?docs=gh
- https://coreos.com/os/docs/latest/booting-with-iso.html
- https://www.ssh.com/ssh/putty/download
- https://docs.microsoft.com/en-us/azure/virtual-machines/windows/nested-virtualization
- https://www.petri.com/create-nat-rules-hyper-v-nat-virtual-switch

## Container Linux Installation
- Create VM in vmware/virtualbox/hyperv with your desired networking (NAT/Bridged/Internal)
- If Hyperv setup virtual switch & DHCP for internet conectivity 
- boot into downloaded container linux iso
- Execute these commands to install coreos
```
curl https://cdn.jsdelivr.net/gh/jselvendiran/kubernetes/cloud_config.yaml -o cloud-config.yaml
coreos-cloudinit -validate --from-file cloud-config.yml
sudo coreos-install -d /dev/sda -C stable -c cloud-config.yml
hostnamectl set-hostname <your-hostname>
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
 - https://kubernetes.io/docs/setup/independent/create-cluster-kubeadm/
 - https://www.aquasec.com/wiki/display/containers/70+Best+Kubernetes+Tutorials
 - https://docs.projectcalico.org/v3.6/getting-started/kubernetes/
 - https://kubernetes.io/docs/concepts/cluster-administration/addons/#networking-and-network-policy


```
swapoff -a
sudo su
```

### Install CNI plugins (required for most pod network):
```
CNI_VERSION="v0.6.0"
mkdir -p /opt/cni/bin
curl -L "https://github.com/containernetworking/plugins/releases/download/${CNI_VERSION}/cni-plugins-amd64-${CNI_VERSION}.tgz" | tar -C /opt/cni/bin -xz
```

### Install crictl (required for kubeadm / Kubelet Container Runtime Interface (CRI))
```
CRICTL_VERSION="v1.11.1"
mkdir -p /opt/bin
curl -L "https://github.com/kubernetes-incubator/cri-tools/releases/download/${CRICTL_VERSION}/crictl-${CRICTL_VERSION}-linux-amd64.tar.gz" | tar -C /opt/bin -xz
```

### Install kubeadm, kubelet, kubectl and add a kubelet systemd service:
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

### exit from super user mode
```
exit
```

### Enable and start kubelet:
```
sudo systemctl enable --now kubelet
```

### Restarting the kubelet is required:
```
sudo systemctl daemon-reload
sudo systemctl restart kubelet
```

### prior to kubeadm init to verify connectivity to gcr.io registries:
```
sudo kubeadm config images pull
```

### Enable docker service prior to init:
```
sudo systemctl enable docker.service
```

### Ignore cgroupfs driver warning message as cgroupfs is the docker default driver.
Init the cluster (MasterNode)
```
priv_ip=$(ip -f inet -o addr show eth1|cut -d\  -f 7 | cut -d/ -f 1 | head -n 1)
sudo kubeadm init --apiserver-advertise-address=$priv_ip  --pod-network-cidr=192.168.0.0/16
```

### Copy the console output and save it. it is needed to join other worker node to the cluster
For kubectl to work in MasterNode:
```shell
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config
```

### Installing a pod network add-on
```
kubectl apply -f https://docs.projectcalico.org/master/getting-started/kubernetes/installation/hosted/etcd.yaml
kubectl apply -f https://docs.projectcalico.org/master/getting-started/kubernetes/installation/hosted/calico.yaml
```

### Join the cluster (WorkerNode)
Sample token and hashkey:
```
kubeadm join 192.168.1.101:6443 --token i5f4a6.shvz07nd1a1h0yli --discovery-token-ca-cert-hash sha256:62f980861d949412076c95e222262e426566db87bd3e8c2aa63995ad616df2cb
```


### To interact with kubernetes cluster from outside cluster
```shell
install kubectl and set in path
scp -i ~/.kube/<privatekeyfile> user@<ipaddr>:/etc/kubernetes/admin.conf ~/.kube/config
or
pscp -i ~/.kube/<privatekeyfile> user@<ipaddr>:/etc/kubernetes/admin.conf ~/.kube/config
kuberctl version
```

## Tear down
To undo what kubeadm did, you should first drain the node and make sure that the node is empty before shutting it down.
Talking to the master with the appropriate credentials, run:
```
kubectl drain <node name> --delete-local-data --force --ignore-daemonsets
kubectl delete node <node name>
```

Then, on the node being removed, reset all kubeadm installed state:
```
kubeadm reset
```

The reset process does not reset or clean up iptables rules or IPVS tables. If you wish to reset iptables, you must do so manually:
```
iptables -F && iptables -t nat -F && iptables -t mangle -F && iptables -X
```

If you want to reset the IPVS tables, you must run the following command:
```
ipvsadm -C
```
If you wish to start over simply run ```kubeadm init``` or ```kubeadm join``` with the appropriate arguments.

If "kubectl get nodes" shows all of the nodes as one single entry, change each nodes with a different hostname in "/etc/hosts" individually and reinstalling k8s using kubespay, it will show all nodes :-)
