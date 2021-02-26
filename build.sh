#!/bin/bash

REPO="rainchei/docker-github-runner"
TAG=$(git log --format="%H" -n 1 | cut -c 1-8)
docker build -t ${REPO}:${TAG} docker
docker push ${REPO}:${TAG}
docker rmi -f ${REPO}:${TAG}
