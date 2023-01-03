#!/bin/bash

ARM_URL=$1
CMAKE_URL=$2
JLINK_URL=$3
DTAG=$4

DOCKER_BUILDKIT=1 docker build --build-arg ARM_URL=${ARM_URL} --build-arg CMAKE_URL=${CMAKE_URL} --build-arg JLINK_URL=${JLINK_URL} -t ghcr.io/cracked-machine/stm32_dev:${DTAG} -f Dockerfile . 