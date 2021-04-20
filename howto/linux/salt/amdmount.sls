---
amdpkg:
  pkg.installed:
    - pkgs:
      - am-utils
      - nfs-common
      - nfs-kernel-server
      - autofs
      - yamllint ##XXhoist

/dtmp:
  file.symlink:
    - target: /net/192.168.1.250/ex/dtmp

multipathd:
  service.disabled

unmaksknfs:
  serivce.unmasked:
    - name: nfs-common

nfs-common:
  service.enabled

am-utils:
  service.enabled

#activate automaster
punchin-etcautonet:
  file.line:
    - name: /etc/auto.master
    - content: '/net  /etc/auto.net'
    - before: '\+auto.master'
    - mode: 'ensure'
    - backup: True


punchin-etcautonet-v3:
  file.replace:
    - name: /etc/auto.net
    - pattern: '^opts="-fstype=nfs,hard,intr,nodev,nosuid"'
    - repl: 'opts="-fstype=nfs,hard,intr,nodev,nosuid,nfsvers=3"'

autofsrestart:
   service.running:
     - name: autofs
     - reload: True
