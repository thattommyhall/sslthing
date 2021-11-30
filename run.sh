#!/bin/bash
set -u
set -e
docker build -t sslthing .
docker run -it --mount type=bind,source=$(pwd)/pipe.log,target=/var/log/powerdns-pipe.log -p 2000:53 -p 2000:53/udp sslthing 