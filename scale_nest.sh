#!/bin/bash
set -e
timeout 60s docker service scale techeerzip_nest=1