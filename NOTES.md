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