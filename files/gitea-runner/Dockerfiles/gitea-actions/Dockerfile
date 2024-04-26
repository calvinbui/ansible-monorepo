FROM ubuntu:24.04

LABEL skip.prune=true

# hadolint ignore=DL3008
RUN apt-get update \
  && apt-get install --no-install-recommends -y \
    ssh \
    git \
    rsync \
    ca-certificates \
    curl \
    gnupg \
    python3 \
    python3-pip \
    nodejs \
  && rm -rf /var/lib/apt/lists/*

WORKDIR /tmp
COPY requirements.txt .
RUN pip3 install --no-cache-dir --break-system-packages -r requirements.txt
