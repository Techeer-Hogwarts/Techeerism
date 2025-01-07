#!/bin/bash
set -e
timeout 120s docker service scale techeerzip_crawler=1