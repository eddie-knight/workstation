# Use Ubuntu as a stable base for cloning repos
FROM ubuntu:22.04 AS build

ENV DEBIAN_FRONTEND=noninteractive

# space-separated list of org names to pull repos from
ARG ORGS_TO_CLONE=""
ARG REPOS_TO_CLONE=""

# Install core utilities
RUN apt-get update && \
    apt-get install -y git ssh curl vim build-essential sudo wget ca-certificates jq && \
    rm -rf /var/lib/apt/lists/*

# Install Golang (needed for go mod tidy during build)
RUN wget https://go.dev/dl/go1.21.5.linux-amd64.tar.gz && \
    tar -C /usr/local -xzf go1.21.5.linux-amd64.tar.gz && \
    rm go1.21.5.linux-amd64.tar.gz
ENV PATH=$PATH:/usr/local/go/bin
# Set GOPATH to ensure module cache is in a known location
ENV GOPATH=/root/go
RUN mkdir -p /root/go/pkg/mod

# Copy dependency installation script and make it executable
COPY install_dependencies.sh /usr/local/bin/install_dependencies.sh
RUN chmod +x /usr/local/bin/install_dependencies.sh

# Pull common git repos
WORKDIR /projects
RUN --mount=type=secret,id=git_config \
    cp /run/secrets/git_config /root/.gitconfig && \
    for org in $ORGS_TO_CLONE; do \
        cd /projects; \
        echo "Cloning repos from $org..."; \
        mkdir $org && cd $org; \
        for repo_url in $(curl -s https://api.github.com/orgs/$org/repos?per_page=100 | jq -r '.[].clone_url'); do \
            repo_name=$(basename "$repo_url" .git); \
            echo "Cloning $repo_name..."; \
            git clone "$repo_url" || true; \
            if [ -d "$repo_name" ]; then \
                install_dependencies.sh "$repo_name" || true; \
            fi; \
        done; \
    done && \
    for repo in $REPOS_TO_CLONE; do \
        if [ -n "$repo" ]; then \
            cd /projects; \
            org=$(echo "$repo" | cut -d'/' -f1); \
            repo_name=$(echo "$repo" | cut -d'/' -f2); \
            echo "Cloning $repo..."; \
            mkdir -p "$org" && cd "$org"; \
            git clone "https://github.com/$repo.git" || true; \
            if [ -d "$repo_name" ]; then \
                install_dependencies.sh "$repo_name" || true; \
            fi; \
        fi; \
    done

##################################################

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

# Copy repos from build stage to a location in the image
# (We'll copy these to the mounted dev directory at runtime)
COPY --from=build /projects /opt/repos
RUN chmod -R 755 /opt/repos

# Copy Go module cache from build stage to final image
# This preserves dependencies downloaded during build so they don't need to be re-downloaded
COPY --from=build --chown=developer:developer /root/go/pkg/mod /home/developer/go/pkg/mod

# Copy entrypoint script and set permissions
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Copy cleanup script and set permissions
COPY cleanup_container.sh /cleanup_container.sh
RUN chmod +x /cleanup_container.sh

# Pre-create directories for mounting
WORKDIR /home/developer
USER developer
RUN mkdir -p \
    Downloads \
    dev \
    go/bin \
    go/pkg \
    go/src

ENTRYPOINT ["/entrypoint.sh"]
CMD ["/bin/bash"]
