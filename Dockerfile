# Use Ubuntu as a stable base
FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

# Install core utilities
RUN apt-get update && apt-get install -y \
    git ssh curl vim build-essential sudo wget ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# --- Install Golang ---
RUN wget https://go.dev/dl/go1.21.5.linux-amd64.tar.gz && \
    tar -C /usr/local -xzf go1.21.5.linux-amd64.tar.gz && \
    rm go1.21.5.linux-amd64.tar.gz
ENV PATH=$PATH:/usr/local/go/bin:/home/developer/go/bin

# --- Install Node.js & NPM (for React) ---
RUN curl -fsSL https://deb.nodesource.com/setup_20.x | bash - && \
    apt-get install -y nodejs

# Create the developer user
RUN useradd -m -s /bin/bash developer && \
    echo "developer ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

USER developer
WORKDIR /home/developer

# Pre-create directories for mounting
RUN mkdir -p /home/developer/Downloads /home/developer/project /home/developer/go/bin /home/developer/go/pkg /home/developer/go/src

CMD ["/bin/bash"]
