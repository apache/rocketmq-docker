#!/bin/bash

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

start_namesrv_broker()
{
    TAG_SUFFIX=$1
    # Start nameserver
    docker run -d -v `pwd`/data/namesrv/logs:/home/rocketmq/logs --name rmqnamesrv -p 9876:9876 apacherocketmq/rocketmq:ROCKETMQ_VERSION${TAG_SUFFIX} sh mqnamesrv
    # Start Broker
    docker run -d -v `pwd`/data/broker/logs:/home/rocketmq/logs -v `pwd`/data/broker/store:/home/rocketmq/store --name rmqbroker --link rmqnamesrv:namesrv -e "NAMESRV_ADDR=namesrv:9876" -p 10909:10909 -p 10911:10911 -p 10912:10912 apacherocketmq/rocketmq:ROCKETMQ_VERSION${TAG_SUFFIX} sh mqbroker
}

if [ $# -lt 1 ]; then
    echo -e "Usage: sh $0 BaseImage"
    exit -1
fi

export BASE_IMAGE=$1

echo "Play RocketMQ docker image of tag ROCKETMQ_VERSION-${BASE_IMAGE}"

RMQ_CONTAINER=$(docker ps -a|awk '/rmq/ {print $1}')
if [[ -n "$RMQ_CONTAINER" ]]; then
   echo "Removing RocketMQ Container..."
   docker rm -fv $RMQ_CONTAINER
   # Wait till the existing containers are removed
   sleep 5
fi

prepare_dir()
{
    dirs=("data/namesrv/logs" "data/broker/logs" "data/broker/store")

    for dir in ${dirs[@]}
    do
        if [ ! -d "`pwd`/${dir}" ]; then
            mkdir -p "`pwd`/${dir}"
            chmod a+rw "`pwd`/${dir}"
        fi
    done
}

prepare_dir

echo "Starting RocketMQ nodes..."

case "${BASE_IMAGE}" in
    alpine)
        start_namesrv_broker -alpine
    ;;
    centos)
        start_namesrv_broker
    ;;
    *)
        echo "${BASE_IMAGE} is not supported, supported base images: centos, alpine"
        exit -1
    ;;
esac

# Service unavailable when not ready
# sleep 20

# Produce messages
# sh ./play-producer.sh
