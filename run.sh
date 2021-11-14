#!/bin/bash
set -u
set -e
docker build -t sslthing .
docker run -it -p 2000:53 -p 2000:53/udp sslthing 