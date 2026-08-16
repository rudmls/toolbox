# Toolbox

Lightweight multi-architecture toolbox container for Docker and Kubernetes automation.

Built on Alpine Linux and designed to provide a small set of useful tools for shell scripts, API calls, JSON processing and network troubleshooting.

## Features

- Lightweight Alpine-based image
- Multi-architecture support
  - `linux/amd64`
  - `linux/arm64`
- Runs as a non-root user by default
- Configurable UID/GID at build time
- Configurable timezone at runtime
- Suitable for Docker and Kubernetes
- Compatible with restrictive Kubernetes security contexts
- Automated semantic versioning
- Published to GitHub Container Registry

## Included tools

| Tool              | Purpose                           |
| ----------------- | --------------------------------- |
| `bash`            | Shell scripting                   |
| `curl`            | HTTP/API requests                 |
| `jq`              | JSON processing                   |
| `nslookup`        | DNS queries                       |
| `dig`             | DNS troubleshooting               |
| `nc`              | TCP/UDP connectivity tests        |
| `envsubst`        | Environment variable substitution |
| `ca-certificates` | TLS certificate validation        |
| `tzdata`          | Timezone support                  |

## Image

The image is published to GitHub Container Registry:

```text
ghcr.io/rudmls/toolbox
```

### Supported architectures

The same image tag can be used on both AMD64 and ARM64 systems:

```text
linux/amd64
linux/arm64
```

This includes ARM64 devices such as the Raspberry Pi 5 running a 64-bit operating system.

## Tags

### Stable releases

Semantic versions are generated automatically from Conventional Commits.

For example, release `1.2.3` publishes:

```text
ghcr.io/rudmls/toolbox:1.2.3
ghcr.io/rudmls/toolbox:1.2
ghcr.io/rudmls/toolbox:1
ghcr.io/rudmls/toolbox:latest
```

For reproducible deployments, prefer a specific version instead of `latest`:

```text
ghcr.io/rudmls/toolbox:1.2.3
```

### Development builds

Pushes to development branches are published using the Git commit SHA:

```text
ghcr.io/rudmls/toolbox:sha-3e05caa
```

This makes it possible to test the exact image produced by a branch before merging it into `main`.

## Docker

### Interactive shell

```bash
docker run --rm -it \
  ghcr.io/rudmls/toolbox:latest
```

### Run a command

```bash
docker run --rm \
  ghcr.io/rudmls/toolbox:latest \
  curl -fsSL https://example.com
```

### API request with jq

```bash
docker run --rm \
  ghcr.io/rudmls/toolbox:latest \
  bash -c 'curl -fsSL https://api.github.com | jq .'
```

### DNS lookup

```bash
docker run --rm \
  ghcr.io/rudmls/toolbox:latest \
  nslookup example.com
```

## Non-root user

The container runs as a non-root user by default:

```text
UID: 1001
GID: 1001
```

Check it with:

```bash
docker run --rm \
  ghcr.io/rudmls/toolbox:latest \
  id
```

The UID and GID can also be overridden at runtime:

```bash
docker run --rm \
  --user 2000:2000 \
  ghcr.io/rudmls/toolbox:latest \
  id
```

### Build with a custom UID/GID

The default UID and GID can be changed when building the image:

```bash
docker build \
  --build-arg UID=2000 \
  --build-arg GID=2000 \
  -t toolbox .
```

## Timezone

UTC is used by default.

```bash
docker run --rm \
  ghcr.io/rudmls/toolbox:latest \
  date
```

A different timezone can be selected using the `TZ` environment variable:

```bash
docker run --rm \
  -e TZ=Europe/Paris \
  ghcr.io/rudmls/toolbox:latest \
  date
```

For example:

```bash
docker run --rm \
  -e TZ=America/Martinique \
  ghcr.io/rudmls/toolbox:latest \
  date
```

## Kubernetes

### Basic container

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: toolbox
spec:
  containers:
    - name: toolbox
      image: ghcr.io/rudmls/toolbox:1.0.0
      command:
        - sleep
        - infinity
```

Then:

```bash
kubectl exec -it toolbox -- bash
```

## Kubernetes security context

The image is designed to work as a non-root container and can be used with a restrictive security context:

```yaml
securityContext:
  runAsNonRoot: true
  runAsUser: 1001
  runAsGroup: 1001
  allowPrivilegeEscalation: false
  readOnlyRootFilesystem: true
  capabilities:
    drop:
      - ALL
  seccompProfile:
    type: RuntimeDefault
```

If the container needs writable temporary storage, mount an `emptyDir`:

```yaml
volumeMounts:
  - name: tmp
    mountPath: /tmp
  - name: workspace
    mountPath: /workspace

volumes:
  - name: tmp
    emptyDir: {}
  - name: workspace
    emptyDir: {}
```

## Sidecar example

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: application
spec:
  containers:
    - name: application
      image: nginx:alpine

    - name: toolbox
      image: ghcr.io/rudmls/toolbox:1.0.0

      env:
        - name: TZ
          value: Europe/Paris

      command:
        - /bin/bash
        - -c
        - |
          while true; do
            curl -fsS http://localhost/ > /dev/null
            sleep 30
          done

      securityContext:
        runAsNonRoot: true
        runAsUser: 1001
        runAsGroup: 1001
        allowPrivilegeEscalation: false
        readOnlyRootFilesystem: true
        capabilities:
          drop:
            - ALL
        seccompProfile:
          type: RuntimeDefault
```

## Init container example

```yaml
initContainers:
  - name: wait-for-api
    image: ghcr.io/rudmls/toolbox:1.0.0
    command:
      - /bin/bash
      - -c
      - |
        until curl -fsS http://api:8080/health; do
          echo "Waiting for API..."
          sleep 5
        done

    securityContext:
      runAsNonRoot: true
      runAsUser: 1001
      runAsGroup: 1001
      allowPrivilegeEscalation: false
      capabilities:
        drop:
          - ALL
```

## Environment substitution

`envsubst` can be used to generate configuration from environment variables:

```bash
docker run --rm \
  -e API_URL=https://example.com \
  ghcr.io/rudmls/toolbox:latest \
  bash -c 'echo "\${API_URL}/v1/health" | envsubst'
```

Output:

```text
https://example.com/v1/health
```

## Release process

Releases follow Conventional Commits.

Examples:

```text
fix: fix certificate handling
feat: add a new tool
feat!: change default behavior
```

Version increments are automatically determined:

| Commit          | Version change            |
| --------------- | ------------------------- |
| `fix:`          | Patch (`1.0.0` → `1.0.1`) |
| `feat:`         | Minor (`1.0.0` → `1.1.0`) |
| Breaking change | Major (`1.0.0` → `2.0.0`) |

Development branches publish `sha-*` images, while merges to `main` can automatically create stable semantic releases.

## Local build

```bash
docker build -t toolbox .
```

Run:

```bash
docker run --rm -it toolbox
```

Test with a restrictive configuration:

```bash
docker run --rm \
  --read-only \
  --tmpfs /tmp \
  --cap-drop ALL \
  --security-opt no-new-privileges \
  toolbox \
  bash -c '
    id
    curl -fsSL https://example.com > /dev/null
    echo "{\"status\":\"ok\"}" | jq .
    nslookup example.com > /dev/null
    echo "All tests passed"
  '
```
