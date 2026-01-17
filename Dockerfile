# Use Ubuntu as a stable base
FROM ubuntu:22.04 AS build

ENV DEBIAN_FRONTEND=noninteractive

# Install core utilities
RUN apt-get update && \
    apt-get install -y git ssh curl vim build-essential sudo wget ca-certificates jq && \
    rm -rf /var/lib/apt/lists/*

# Pull common git repos
WORKDIR /projects
RUN curl -s https://api.github.com/orgs/privateerproj/repos?per_page=100 | jq -r '.[].clone_url' | xargs -n1 git clone

FROM alpine:latest

# Install minimal dependencies for Go and Node.js
RUN apk add --no-cache bash ca-certificates

# --- Install Golang ---
RUN wget https://go.dev/dl/go1.21.5.linux-amd64.tar.gz && \
    tar -C /usr/local -xzf go1.21.5.linux-amd64.tar.gz && \
    rm go1.21.5.linux-amd64.tar.gz
ENV PATH=$PATH:/usr/local/go/bin:/home/developer/go/bin

# --- Install Node.js & NPM ---
RUN apk add --no-cache nodejs npm

# Create the developer user
RUN addgroup -g 1000 developer && \
    adduser -D -u 1000 -G developer -s /bin/bash developer && \
    echo "developer ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# Pre-create directories for mounting
USER developer
WORKDIR /home/developer
RUN mkdir -p \
    Downloads \
    dev \
    go/bin \
    go/pkg \
    go/src

COPY --from=build /projects /home/developer/dev

CMD ["/bin/bash"]
