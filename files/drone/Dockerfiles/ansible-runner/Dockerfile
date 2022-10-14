FROM python:3.10.8
LABEL skip.prune=true
WORKDIR /tmp

COPY requirements.txt .
RUN pip3 install --no-cache-dir -r requirements.txt

RUN apt-get update \
  && apt-get install -y --no-install-recommends \
    rsync=3.2.3-4+deb11u1 \
  && rm -rf /var/lib/apt/lists/*
