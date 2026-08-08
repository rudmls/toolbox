FROM alpine:3.24

LABEL org.opencontainers.image.title="Toolbox"
LABEL org.opencontainers.image.description="Small toolbox image for Docker and Kubernetes automation"
LABEL org.opencontainers.image.licenses="MIT"

ARG UID=1001
ARG GID=1001

# Install tools
RUN apk add --no-cache \
    bash \
    curl \
    jq \
    bind-tools \
    netcat-openbsd \
    gettext \
    ca-certificates

# Create non-root user
RUN addgroup \
        -g "${GID}" \
        toolbox \
    && adduser \
        -D \
        -u "${UID}" \
        -G toolbox \
        -h /home/toolbox \
        toolbox

# Prepare workspace
RUN mkdir -p /workspace \
    && chown "${UID}:${GID}" /workspace

WORKDIR /workspace

USER ${UID}:${GID}

CMD ["/bin/bash"]
