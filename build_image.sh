#!/bin/bash

# buid the image
docker build --build-arg user=$USER --build-arg uid=$(id -u) --build-arg gid=$(id -g) -t saint .
