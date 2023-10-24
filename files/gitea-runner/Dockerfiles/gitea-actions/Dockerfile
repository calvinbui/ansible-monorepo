FROM ubuntu:23.10

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

COPY requirements.txt .
RUN pip3 install --no-cache-dir --break-system-packages -r requirements.txt
