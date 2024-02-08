FROM python:3.12.2
LABEL skip.prune=true
WORKDIR /tmp

COPY requirements.txt .
RUN pip3 install --no-cache-dir -r requirements.txt

RUN apt-get update \
  && apt-get install -y --no-install-recommends \
    rsync \
  && rm -rf /var/lib/apt/lists/*
