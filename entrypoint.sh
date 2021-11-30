#!/bin/bash
set -e

trap "pdns_control quit" SIGHUP SIGINT SIGTERM

pdns_server &

wait