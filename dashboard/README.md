# Durantic Dashboard Helm Chart

This Helm chart deploys the Durantic Dashboard, a React-based web frontend that serves static files via nginx and proxies API calls to the Durantic control plane backend.

## Features

- **Production-ready nginx configuration** with optimized static file serving
- **Automatic configuration updates** via ConfigMap checksum annotations
- **Comprehensive security context** following Kubernetes security best practices
- **Health checks** with configurable liveness and readiness probes
- **TLS support** with optional cert-manager integration
- **Horizontal Pod Autoscaling** for dynamic scaling
- **Pod Disruption Budget** for high availability
- **Network policies** for enhanced security
- **Ingress support** with multiple ingress controllers

## Quick Start

1. **Basic installation:**
   ```bash
   helm install dashboard ./deploy/helm/dashboard
   ```

2. **With custom values:**
   ```bash
   helm install dashboard ./deploy/helm/dashboard -f values-production.yaml
   ```

3. **Upgrade existing installation:**
   ```bash
   helm upgrade dashboard ./deploy/helm/dashboard
   ```

## Configuration

### Required Configuration

The chart requires minimal configuration to get started:

```yaml
backend:
  apiUrl: "http://controlplane-web:8000"  # Backend API endpoint
```

### Key Configuration Options

| Parameter | Description | Default |
|-----------|-------------|---------|
| `replicaCount` | Number of replicas | `1` |
| `image.repository` | Container image repository | `durantic/dashboard` |
| `image.tag` | Container image tag | `""` (uses chart appVersion) |
| `backend.apiUrl` | Full URL to backend API | `""` |
| `backend.serviceName` | Backend service name | `controlplane-web` |
| `backend.servicePort` | Backend service port | `8000` |
| `tls.enabled` | Enable HTTPS/TLS | `false` |
| `tls.secretName` | TLS certificate secret name | `""` |
| `resources.limits.cpu` | CPU limit | `500m` |
| `resources.limits.memory` | Memory limit | `512Mi` |
| `autoscaling.enabled` | Enable horizontal pod autoscaling | `false` |
| `ingress.enabled` | Enable ingress | `false` |

### Security Configuration

The chart includes comprehensive security settings:

```yaml
podSecurityContext:
  runAsNonRoot: true
  runAsUser: 101  # nginx user
  runAsGroup: 101
  fsGroup: 101
  seccompProfile:
    type: RuntimeDefault

securityContext:
  allowPrivilegeEscalation: false
  readOnlyRootFilesystem: false
  capabilities:
    drop: [ALL]
    add: [CHOWN, SETGID, SETUID, NET_BIND_SERVICE]
```

### TLS Configuration

Enable TLS for production deployments:

```yaml
tls:
  enabled: true
  secretName: "dashboard-tls-cert"

# Optional: Use cert-manager for automatic certificate generation
tls:
  enabled: true
  certManager:
    enabled: true
    issuer: "letsencrypt-prod"
    dnsNames:
      - dashboard.example.com
```

### Autoscaling Configuration

Configure horizontal pod autoscaling:

```yaml
autoscaling:
  enabled: true
  minReplicas: 2
  maxReplicas: 10
  targetCPUUtilizationPercentage: 70
  targetMemoryUtilizationPercentage: 80
```

### Ingress Configuration

Configure ingress for external access:

```yaml
ingress:
  enabled: true
  className: "nginx"
  annotations:
    cert-manager.io/cluster-issuer: "letsencrypt-prod"
  hosts:
    - host: dashboard.example.com
      paths:
        - path: /
          pathType: Prefix
  tls:
    - secretName: dashboard-tls-cert
      hosts:
        - dashboard.example.com
```

## Nginx Configuration

The chart includes a comprehensive nginx configuration that:

- Serves React static files efficiently
- Proxies API calls to the backend service
- Implements proper caching headers
- Supports both HTTP and HTTPS
- Includes security headers
- Handles client-side routing for SPAs

### Customizing Nginx Configuration

You can customize nginx settings via values:

```yaml
nginx:
  resolver: "kube-dns.kube-system.svc.cluster.local"
  serverName: "dashboard.example.com"
  clientMaxBodySize: "10M"
  proxy:
    connectTimeout: "30s"
    sendTimeout: "30s"
    readTimeout: "30s"
```

## Health Checks

The chart includes both liveness and readiness probes:

```yaml
probes:
  liveness:
    initialDelaySeconds: 30
    periodSeconds: 10
    timeoutSeconds: 5
    failureThreshold: 3
  readiness:
    initialDelaySeconds: 5
    periodSeconds: 5
    timeoutSeconds: 3
    failureThreshold: 3
```

Health checks use the `/health` endpoint which returns a simple "healthy" response.

## Deployment Examples

### Development Environment

```yaml
# values-dev.yaml
replicaCount: 1
image:
  tag: "latest"
  pullPolicy: Always

backend:
  serviceName: "controlplane-web"
  servicePort: 8000

tls:
  enabled: false

resources:
  limits:
    cpu: 200m
    memory: 256Mi
  requests:
    cpu: 50m
    memory: 64Mi
```

### Production Environment

```yaml
# values-prod.yaml
replicaCount: 3

image:
  tag: "v1.2.3"
  pullPolicy: IfNotPresent

backend:
  apiUrl: "https://api.durantic.io"

tls:
  enabled: true
  secretName: "dashboard-tls-cert"

autoscaling:
  enabled: true
  minReplicas: 3
  maxReplicas: 20
  targetCPUUtilizationPercentage: 70

ingress:
  enabled: true
  className: "nginx"
  hosts:
    - host: dashboard.durantic.io
      paths:
        - path: /
          pathType: Prefix

podDisruptionBudget:
  enabled: true
  minAvailable: 2

resources:
  limits:
    cpu: 1000m
    memory: 1Gi
  requests:
    cpu: 200m
    memory: 256Mi
```

## Troubleshooting

### Common Issues

1. **Pod not starting**: Check resource limits and image availability
   ```bash
   kubectl describe pod <pod-name>
   kubectl logs <pod-name>
   ```

2. **Configuration not updating**: ConfigMap checksum ensures automatic restarts
   ```bash
   kubectl get configmap <release-name>-dashboard-config -o yaml
   ```

3. **Backend connectivity issues**: Verify service names and ports
   ```bash
   kubectl exec <pod-name> -- curl -f http://controlplane-web:8000/health
   ```

4. **TLS certificate issues**: Check secret and certificate validity
   ```bash
   kubectl describe secret <tls-secret-name>
   ```

### Health Check Commands

```bash
# Check pod health
kubectl get pods -l app.kubernetes.io/name=dashboard

# Test health endpoint
kubectl exec deployment/dashboard -- curl -f http://localhost/health

# View logs
kubectl logs -f deployment/dashboard

# Check configuration
kubectl get configmap dashboard-config -o yaml
```

## Contributing

When modifying the chart:

1. Update the version in `Chart.yaml`
2. Test with `helm template` and `helm lint`
3. Update this README with any new configuration options
4. Test in both development and production-like environments

## Security Considerations

- Runs as non-root user (nginx:101)
- Drops all capabilities except essential ones
- Includes comprehensive security headers
- Supports network policies for traffic isolation
- ReadOnlyRootFilesystem can be enabled for additional security