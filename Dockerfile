FROM alpine:3.24

LABEL org.opencontainers.image.title="Toolbox"
LABEL org.opencontainers.image.description="Small toolbox image for Docker and Kubernetes automation"
LABEL org.opencontainers.image.licenses="MIT"

RUN apk add --no-cache \
    bash \
    curl \
    jq \
    bind-tools \
    netcat-openbsd \
    gettext \
    ca-certificates

WORKDIR /workspace

CMD ["/bin/bash"]
