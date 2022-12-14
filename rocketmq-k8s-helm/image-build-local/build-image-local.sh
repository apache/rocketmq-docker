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

if [ $# -lt 4 ]; then
    echo -e "Usage: sh $0 ROCKETMQ_VERSION BASE_IMAGE IMAGE_REPO_USERNAME IMAGE_REPO_PASSWORD"
    exit -1
fi

ROCKETMQ_VERSION=$1
BASE_IMAGE=$2
IMAGE_REPO_USERNAME=$3
IMAGE_REPO_PASSWORD=$4

TAG=${ROCKETMQ_VERSION}-`echo $BASE_IMAGE | sed -e "s/:/-/g"`

cp -r ../../rocketmq ./

docker login --username=$IMAGE_REPO_USERNAME --password=$IMAGE_REPO_PASSWORD cn-cicd-repo-registry.cn-hangzhou.cr.aliyuncs.com

# Build rocketmq
case "${BASE_IMAGE}" in
    alpine)
        docker build --no-cache -f Dockerfile-alpine -t cn-cicd-repo-registry.cn-hangzhou.cr.aliyuncs.com/cicd/rocketmq:${TAG} --build-arg version=${ROCKETMQ_VERSION} --build-arg BASE_IMAGE=${BASE_IMAGE} .
    ;;
    centos)
        docker build --no-cache -f Dockerfile-centos -t cn-cicd-repo-registry.cn-hangzhou.cr.aliyuncs.com/cicd/rocketmq:${TAG} --build-arg version=${ROCKETMQ_VERSION} --build-arg BASE_IMAGE=${BASE_IMAGE} .
    ;;
    *)
        echo "${BASE_IMAGE} is not supported, supported base images: centos, alpine"
        exit -1
    ;;
esac


docker push cn-cicd-repo-registry.cn-hangzhou.cr.aliyuncs.com/cicd/rocketmq:${TAG}
