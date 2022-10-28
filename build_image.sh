#!/bin/bash
# TODO: Take password from console
# buid the image
docker build --build-arg user=$USER --build-arg password="djdj" --build-arg uid=$(id -u) --build-arg gid=$(id -g) -t saint .
