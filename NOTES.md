### After running into issues with docker overlay2

So what I have done is:
- created a new device (i.e. add a new disk, in my case `/dev/vdb,` your volume name will very likely differ)
-  created a new filesystem on the volume `mkfs.xfs -f -n ftype=1 /dev/vdb`
- added new  directory `mkdir /mnt/docker`
- mounted the filesystem `mount /dev/vdb /mnt/docker`
- updated my `/etc/docker/daemon.json` file to look like the following: 
    - (pay attention to this `"data-root": "/mnt/docker",` )
```json
{
  "exec-opts": ["native.cgroupdriver=systemd"],
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "100m"
  },
  "storage-driver": "overlay2",
  "data-root": "/mnt/docker",
  "storage-opts": [
    "overlay2.override_kernel_check=true"
  ]
}
```
- restarted docker service `systemctl start docker`
- checked the docker info
```
[foo~]$ sudo docker info 
Client:
 Debug Mode: false

Server:
 Containers: 0
  Running: 0
  Paused: 0
  Stopped: 0
 Images: 0
 Server Version: 19.03.11
 Storage Driver: overlay2
  Backing Filesystem: xfs
  Supports d_type: true
```
**BINGO!**
**DISCO!**

TODO: Need to add volume to fstab  



---
### Starting kubeadm
I got this error 


```
sudo kubeadm init 
W0829 21:05:14.806072   11365 configset.go:348] WARNING: kubeadm cannot validate component configs for API groups [kubelet.config.k8s.io kubeproxy.config.k8s.io]
[init] Using Kubernetes version: v1.19.0
[preflight] Running pre-flight checks
error execution phase preflight: [preflight] Some fatal errors occurred:
	[ERROR FileContent--proc-sys-net-bridge-bridge-nf-call-iptables]: /proc/sys/net/bridge/bridge-nf-call-iptables contents are not set to 1
[preflight] If you know what you are doing, you can make a check non-fatal with `--ignore-preflight-errors=...`
To see the stack trace of this error execute with --v=5 or higher
```


Fixed it by setting the contents of `/usr/lib/sysctl.d/00-system.conf` to the following:

```
# Kernel sysctl configuration file
#
# For binary values, 0 is disabled, 1 is enabled.  See sysctl(8) and
# sysctl.conf(5) for more details.

# Disable netfilter on bridges.
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
net.bridge.bridge-nf-call-arptables = 1
net.ipv4.ip_forward                 = 1
```
And running 


```
sudo sysctl --system
```


---

### I might have to add: 
```
cat > /etc/modules-load.d/containerd.conf <<EOF
overlay
br_netfilter
EOF

modprobe overlay
modprobe br_netfilter
```
