---
amdpkg:
  pkg.installed:
    - pkgs: 
        - acl
        - linux-tools-common
        - linux-tools-generic

root_cantrips:
  git.latest:
    - name: https://github.com/brendangregg/FlameGraph
    - target: /tmp/src/FlameGraph

