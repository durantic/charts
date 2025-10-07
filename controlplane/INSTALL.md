# Installation Guide

## First Time Installation

```bash
# Install with custom values
helm upgrade --install controlplane . -f my-values.yaml

# Or with minimal configuration
helm upgrade --install controlplane . --set controlPlane.nodeId=my-node-id
```

## Upgrade Installation

When upgrading, if you get password errors, you need to provide the existing passwords:

```bash
# Get existing PostgreSQL password
export POSTGRES_PASSWORD=$(kubectl get secret controlplane-durantic-postgresql -o jsonpath="{.data.password}" | base64 -d)

# Get existing Redis password  
export REDIS_PASSWORD=$(kubectl get secret controlplane-durantic-redis -o jsonpath="{.data.redis-password}" | base64 -d)

# Upgrade with existing passwords
helm upgrade controlplane . -f my-values.yaml \
  --set postgresql.auth.password=$POSTGRES_PASSWORD \
  --set redis.auth.password=$REDIS_PASSWORD
```

## Accessing the Application

1. Get the Django admin password:
```bash
kubectl exec -it deployment/controlplane-durantic -- python manage.py createsuperuser
```

2. Port forward to access the application:
```bash
kubectl port-forward svc/controlplane-durantic 8000:8000
```

3. Access the application at http://localhost:8000

## Getting Generated Secrets

```bash
# Django Secret Key
kubectl get secret controlplane-durantic -o jsonpath="{.data.django-secret-key}" | base64 -d

# CA Certificate (for mTLS)
kubectl get secret controlplane-durantic -o jsonpath="{.data.ca\.crt}" | base64 -d > ca.crt

# MinIO credentials (auto-generated)
kubectl get secret minio-creds-secret -o jsonpath="{.data.accesskey}" | base64 -d
kubectl get secret minio-creds-secret -o jsonpath="{.data.secretkey}" | base64 -d
```

## Troubleshooting

### Password Errors on Upgrade

The PostgreSQL and Redis subcharts maintain their own passwords in persistent volumes. When upgrading, you must provide the existing passwords to avoid losing access to the data.

### Fresh Installation After Failed Attempt

If you need to completely reinstall:

```bash
# Delete the release
helm delete controlplane

# Delete PVCs if they exist
kubectl delete pvc -l app.kubernetes.io/instance=controlplane

# Reinstall
helm install controlplane . -f my-values.yaml
```

### Migration Job Issues

If the migration job is stuck:

1. Check the job status:
```bash
kubectl get jobs -l app.kubernetes.io/instance=controlplane
kubectl describe job controlplane-durantic-migrate-<revision>
```

2. Check the logs:
```bash
kubectl logs -l app.kubernetes.io/component=migration
```

3. Common issues:
- **Service not found**: The migration job runs as a post-install hook, so all services should be available
- **Database connection**: Ensure PostgreSQL is running: `kubectl get pods -l app.kubernetes.io/name=postgresql`
- **Redis connection**: Ensure Redis is running: `kubectl get pods -l app.kubernetes.io/name=redis`

### Service Names

The subchart services are named based on the release name:
- PostgreSQL: `<release-name>-postgresql`
- Redis: `<release-name>-redis-master`
- MinIO: `<release-name>-minio`

For example, with release name "controlplane":
- `controlplane-postgresql`
- `controlplane-redis-master`
- `controlplane-minio`