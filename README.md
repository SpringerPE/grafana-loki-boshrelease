# grafana-loki-boshrelease

PoC of grafana loki

Loki is a submodule, in order to track versions, just update it.

Clone:

```
git clone --recurse-submodules <repo>
```


Old git versions
```
git submodule update --init --recursive
```


# Creating and using a release:

```
bosh create-release --force
bosh upload-release
```


Example manifest (only one node!):

```
name: grafana-loki

releases:
- name: loki
  version: latest

instance_groups:
- name: loki
  instances: 1
  vm_type: grafana-loki
  stemcell: default
  persistent_disk_type: grafana-loki
  vm_extensions:
  - grafana-loki-promtail-lb
  - grafana-loki-api-lb
  azs:
  - z1
  - z2
  - z3
  networks:
  - name: default
  jobs:
  - name: loki
    release: loki
  properties: {}

stemcells:
- alias: default
  name: bosh-google-kvm-ubuntu-xenial-go_agent
  version: latest

update:
  canaries: 1
  max_in_flight: 1
  serial: false
  canary_watch_time: 1000-60000
  update_watch_time: 1000-60000
```

Example runtime-config:
```
releases:
- name: loki
  version: "0+dev.4"

addons:
- name: loki-promtail
  jobs:
  - name: promtail
    release: loki
    properties:
      promtail:
        loki: "http://<ip-loki-server>:3100/api/prom/push"
  include:
    deployments:
    - cf-test
```
