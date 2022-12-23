#!/usr/bin/env bash

# Licensed to the Apache Software Foundation (ASF) under one or more
# contributor license agreements.  See the NOTICE file distributed with
# this work for additional information regarding copyright ownership.
# The ASF licenses this file to You under the Apache License, Version 2.0
# (the "License"); you may not use this file except in compliance with
# the License.  You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

if [ $# -lt 5 ]; then
  echo -e "Usage: sh $0 ROCKETMQ_VERSION BASE_IMAGE JAVA_VERSION IMAGE_REPO_USERNAME IMAGE_REPO_PASSWORD"
  exit -1
fi

ROCKETMQ_VERSION=$1
BASE_IMAGE=$2
JAVA_VERSION=$3
IMAGE_REPO_USERNAME=$4
IMAGE_REPO_PASSWORD=$5

TAG=${ROCKETMQ_VERSION}-$(echo $BASE_IMAGE | sed -e "s/:/-/g")

cp -r ../../rocketmq ./

docker login --username=$IMAGE_REPO_USERNAME --password=$IMAGE_REPO_PASSWORD cn-cicd-repo-registry.cn-hangzhou.cr.aliyuncs.com

# Build rocketmq
case "${BASE_IMAGE}" in
alpine)
  if [ "$JAVA_VERSION" -eq 8 ]; then
    docker build --no-cache -f Dockerfile-alpine -t cn-cicd-repo-registry.cn-hangzhou.cr.aliyuncs.com/cicd/rocketmq:${TAG} --build-arg version=${ROCKETMQ_VERSION} --build-arg BASE_IMAGE=eclipse-temurin:8-jre-alpine .
  elif [ "$JAVA_VERSION" -eq 11 ]; then
    docker build --no-cache -f Dockerfile-alpine -t cn-cicd-repo-registry.cn-hangzhou.cr.aliyuncs.com/cicd/rocketmq:${TAG} --build-arg version=${ROCKETMQ_VERSION} --build-arg BASE_IMAGE=eclipse-temurin:11-jre-alpine .
  else
    echo "in ${BASE_IMAGE}, jdk ${JAVA_VERSION} is not supported, supported java versions: 8, 11"
  fi
  ;;
centos)
  if [ "$JAVA_VERSION" -eq 8 ]; then
    docker build --no-cache -f Dockerfile-centos -t cn-cicd-repo-registry.cn-hangzhou.cr.aliyuncs.com/cicd/rocketmq:${TAG} --build-arg version=${ROCKETMQ_VERSION} --build-arg BASE_IMAGE=eclipse-temurin:8-centos7 .
  elif [ "$JAVA_VERSION" -eq 11 ]; then
    docker build --no-cache -f Dockerfile-centos -t cn-cicd-repo-registry.cn-hangzhou.cr.aliyuncs.com/cicd/rocketmq:${TAG} --build-arg version=${ROCKETMQ_VERSION} --build-arg BASE_IMAGE=eclipse-temurin:11-centos7 .
  else
    echo "in ${BASE_IMAGE}, jdk ${JAVA_VERSION} is not supported, supported java versions: 8, 11"
  fi
  ;;
ubuntu)
  if [ "$JAVA_VERSION" -eq 8 ]; then
    docker build --no-cache -f Dockerfile-ubuntu -t cn-cicd-repo-registry.cn-hangzhou.cr.aliyuncs.com/cicd/rocketmq:${TAG} --build-arg version=${ROCKETMQ_VERSION} --build-arg BASE_IMAGE=eclipse-temurin:8-jre .
  elif [ "$JAVA_VERSION" -eq 11 ]; then
    docker build --no-cache -f Dockerfile-ubuntu -t cn-cicd-repo-registry.cn-hangzhou.cr.aliyuncs.com/cicd/rocketmq:${TAG} --build-arg version=${ROCKETMQ_VERSION} --build-arg BASE_IMAGE=eclipse-temurin:11-jre .
  else
    echo "in ${BASE_IMAGE}, jdk ${JAVA_VERSION} is not supported, supported java versions: 8, 11"
  fi
  ;;
windows)
  if [ "$JAVA_VERSION" -eq 8 ]; then
    docker build --no-cache -f Dockerfile-windows -t cn-cicd-repo-registry.cn-hangzhou.cr.aliyuncs.com/cicd/rocketmq:${TAG} --build-arg version=${ROCKETMQ_VERSION} --build-arg BASE_IMAGE=eclipse-temurin:8-jre-windowsservercore .
  elif [ "$JAVA_VERSION" -eq 11 ]; then
    docker build --no-cache -f Dockerfile-windows -t cn-cicd-repo-registry.cn-hangzhou.cr.aliyuncs.com/cicd/rocketmq:${TAG} --build-arg version=${ROCKETMQ_VERSION} --build-arg BASE_IMAGE=eclipse-temurin:11-jre-windowsservercore .
  else
    echo "in ${BASE_IMAGE}, jdk ${JAVA_VERSION} is not supported, supported java versions: 8, 11"
  fi
  ;;
*)
  echo "${BASE_IMAGE} is not supported, supported base images: ubuntu, centos, alpine, windows"
  exit -1
  ;;
esac

docker push cn-cicd-repo-registry.cn-hangzhou.cr.aliyuncs.com/cicd/rocketmq:${TAG}
