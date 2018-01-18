# Kubernetes readiness watcher

**Kubernetes readiness watcher** is a docker container whose only job is to request the status of a service 
using the Kubernetes API, and succeed when the endpoint is ready.
It is meant to be used as an initContainer, preventing the pod to launch further containers until the required services
are ready to be consumed.


## Purpose

This alpine-based Docker image fulfills only one purpose: it pauses the initialization of main containers until the 
required services are ready (as defined in a Pods `readinessProbe` property).

### Alternative approaches

- Testing nslookup (see [the busybox example](https://kubernetes.io/docs/concepts/workloads/pods/init-containers/#init-containers-in-use)) checks service existence, not readiness
- Using kubectl cli (as [k8s-wait-for](https://github.com/groundnuty/k8s-wait-for) does) makes the image heavier and adds complexity
- Simply pinging a service name return false negatices (*TODO: understand why*) 

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
      # or with short syntax:
      - name: waitfor-otherservice
        image: ykweyer/k8s-readiness-watcher
        args: [ "my-service", "kube-public", "30" ]
      # you can even combine both (args has prevalence):
      - name: waitfor-lastservice
        image: ykweyer/k8s-readiness-watcher
        args: [ "my-service" ]
        envFrom:
        - configMapRef:
            name: readiness-watcher-config
```

You can add as many initContainers as you want, depending on how many services are required. The targeted pods 
[readiness test](https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-probes/) should 
be defined.


### Available parameters

#### Short syntax
The shell script accepts following arguments (the order matters)
```bash
$ k8s-readinessProbe service-name [namespace-name [refresh-interval]]

# test for the existence of redis in "custom" every 5 seconds:
$ k8s-readinessProbe redis custom 5

# test for the existence of a mysql service in default namespace every 15 seconds (default value):
$ k8s-readinessProbe mysql
```

#### Environment variables
Env variable are used as fallback if no `args` are defined. You can combine both in your yaml, which allows you to define
values likely similar across several pods (like `MASTER_URL`, or `SA_CACERT`) in a shared `ConfigMap`

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
- [Official Init Containers documentation](https://kubernetes.io/docs/concepts/workloads/pods/init-containers/#what-can-init-containers-be-used-for)
