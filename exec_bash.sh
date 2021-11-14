#!/bin/bash
set -u
set -e
docker build -t sslthing .
docker run -it --entrypoint /bin/bash sslthing 