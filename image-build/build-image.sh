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

checkVersion() {
    echo "Version = $1"
	echo $1 |grep -E "^[0-9]+\.[0-9]+\.[0-9]+" > /dev/null
    if [ $? = 0 ]; then
        return 1
    fi

	echo "Version $1 illegal, it should be X.X.X format(e.g. 4.5.0), please check released versions in 'https://archive.apache.org/dist/rocketmq/'"
    exit -1
}

if [ $# -lt 2 ]; then
    echo -e "Usage: sh $0 Version BaseImage"
    exit -1
fi

ROCKETMQ_VERSION=$1
BASE_IMAGE=$2

checkVersion $ROCKETMQ_VERSION

# Build rocketmq
case "${BASE_IMAGE}" in
    alpine)
        docker build --no-cache -f Dockerfile-alpine -t apacherocketmq/rocketmq:${ROCKETMQ_VERSION}-alpine --build-arg version=${ROCKETMQ_VERSION} .
    ;;
    centos)
        docker build --no-cache -f Dockerfile-centos -t apacherocketmq/rocketmq:${ROCKETMQ_VERSION} --build-arg version=${ROCKETMQ_VERSION} .
    ;;
    *)
        echo "${BASE_IMAGE} is not supported, supported base images: centos, alpine"
        exit -1
    ;;
esac

