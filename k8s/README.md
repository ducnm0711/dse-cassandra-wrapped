# Basics: Kubernetes Admission Webhooks

A WebHook is an HTTP callback that occurs when something happens. For our case, Webhook is used validate or change objects for `cassandradatacenters`

- https://kubernetes.io/docs/reference/access-authn-authz/webhook/
- https://medium.com/geekculture/back-to-basics-kubernetes-admission-webhooks-dbf6baffb0f1#:~:text=Webhooks%20are%20the%20type%20of,performed%20on%20certain%20Kubernetes%20resources.
- https://github.com/k8ssandra/cass-operator/blob/master/docs/developer/validating_webhook.md


# Current Config

For our case, `ValidatingWebhookConfiguration` is used to prevent renaming certain elements of the deployment, such as the the cassandra cluster or the racks, which are core to the identity of a cassandra cluster.

[Cassandra Validating Webhook - DOCS LINK HERE](https://github.com/k8ssandra/cass-operator/blob/master/docs/developer/validating_webhook.md)

Validating webhooks have specific requirements in kubernetes:

- They must be served over TLS
- The TLS service name where they are reached must match the subject of the certificate
- The CA signing the certificate must be either installed in the kube apiserver filesystem, or explicitly configured in the kubernetes validatingwebhookconfiguration object.

We are using datastax/cass-operator repo - https://github.com/datastax/cass-operator/blob/master/charts/cass-operator-chart/templates

This version provide a basic webhook config + an empty secret for webhook TLS impelmentation with cass-operator:
```yaml
apiVersion: v1
kind: Secret
metadata:
  name: cass-operator-webhook-config
data:
  tls.crt: ""
  tls.key: ""
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: cass-operator
spec:
  selector:
    matchLabels:
      name: cass-operator
      volumes:
...
      - name: cass-operator-certs-volume
        secret:
          secretName: cass-operator-webhook-config
      containers:
      - name: cass-operator
        volumeMounts:
        - mountPath: /tmp/k8s-webhook-server/serving-certs
          name: cass-operator-certs-volume
          readOnly: false
---
apiVersion: v1
kind: Service
metadata:
  name: cassandradatacenter-webhook-service
  labels:
    name: cass-operator-webhook
spec:
  ports:
  - port: 443
    targetPort: 8443
  selector:
    name: cass-operator          
```

# Changes

https://github.com/k8ssandra/cass-operator 

k8ssandra introduces the integration with CertManager to automatically generate TLS cert for WebHook. This make sure that cass-operator webhook calls are always secured with TLS.
The thing is, we don't have CertManager.

For quick changes and integrate with current config, we will update all CRD and RBAC, with some modifications for WebHook to work independently.

See `manifest-operator-0.44.1-webhook-standalone.yaml`