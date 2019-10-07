# Autopilot with Portworx

## Before you begin
Auto pilot requires Portworx version 2.2. 
At the time of writing of this doc, 2.2 is not GA, so we'll be using 2.2-rc3 

## Install Portworx
```
https://docs.portworx.com/portworx-install-with-kubernetes/
```

## Install Prometheus
```
https://github.com/satchpx/prom-helm
```

## Installing Autopilot
```
https://docs.portworx.com/portworx-install-with-kubernetes/autopilot/how-to-use/install-autopilot/#installing-autopilot
```

## Apply the config for autopilot
```
apiVersion: v1
kind: ConfigMap
metadata:
  name: autopilot-config
  namespace: kube-system
data:
  config.yaml: |-
    providers:
       - name: default
         type: prometheus
         params: url=http://prometheus-server.monitoring:80
    min_poll_interval: 2
```

## Install the test elements


## PVC Resize

## Pool Resize