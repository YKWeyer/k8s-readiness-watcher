# Kubernetes readiness watcher

**Kubernetes readiness watcher** creates a docker container whose only job is to request the status of one specified 
service using the Kubernetes API, and success when the endpoint is ready.
It is meant to be used as an initContainer, preventing the pod to launch further containers until the required services
are ready to be consumed.


## Purpose

Some Services are so dependant on another one that trying to launch them before their dependancies is ready isn't even 
possible.

Using [the busybox example](https://kubernetes.io/docs/concepts/workloads/pods/init-containers/#init-containers-in-use) 
from the documentations allows to check the required Service exists, but there is no simple solution for it yet.

This alpine-based Docker image fulfills only one purpose: it blocks the initialization of the container until the 
required services are ready.


## Usage

In your deployment yaml, simply add the container as an `initContainer`:

```yml
apiVersion: extensions/v1beta1
kind: Deployment
spec:
  template:
    spec:
      initContainers:
      - name: waitfor-myservice # Whatever name makes sense to you
        image: ykweyer/k8s-readiness-watcher
        env:
        - name: NAMESPACE
          value: kube-public
        - name: SERVICE
          value: my-service
```

You can add as many initContainers as you want, depending on how many services are required. The targeted pods 
[readiness test](https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-probes/) should 
be defined.


### Available parameters

| Parameter     | Default value                                          |
| ------------- | ------------------------------------------------------ |
| `SERVICE`     | none                                                   |
| `NAMESPACE`   | `default`                                              |
| `REFRESH`     | `15`                                                   |
| `MASTER_URL`  | `https://kubernetes.default.svc`                       |
| `SA_CACERT`   | `/var/run/secrets/kubernetes.io/serviceaccount/ca.crt` |
| `SA_TOKEN`    | `/var/run/secrets/kubernetes.io/serviceaccount/token  `|


## Inspired by
- Giantswarms [Blog article](https://blog.giantswarm.io/wait-for-it-using-readiness-probes-for-service-dependencies-in-kubernetes/)