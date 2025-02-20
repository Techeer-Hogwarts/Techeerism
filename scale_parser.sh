#!/bin/bash
set -e
timeout 60s docker service scale techeerzip_parser=1