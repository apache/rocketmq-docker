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

# Start nameserver
docker run -d -v `pwd`/ssl:/home/rocketmq/ssl  -v `pwd`/data/namesrv/logs:/home/rocketmq/logs --name rmqnamesrv -e "JAVA_OPT=-Dtls.test.mode.enable=false -Dtls.config.file=/home/rocketmq/ssl/ssl.properties -Dtls.test.mode.enable=false -Dtls.server.need.client.auth=required"  apacherocketmq/rocketmq:ROCKETMQ_VERSION sh mqnamesrv

# Start Broker
docker run -d -v `pwd`/ssl:/home/rocketmq/ssl  -v `pwd`/data/broker/logs:/home/rocketmq/logs -v `pwd`/data/broker/store:/home/rocketmq/store --name rmqbroker --link rmqnamesrv:namesrv -e "NAMESRV_ADDR=namesrv:9876" -e "JAVA_OPT=-Dtls.enable=true -Dtls.client.authServer=true -Dtls.test.mode.enable=false -Dtls.config.file=/home/rocketmq/ssl/ssl.properties -Dtls.test.mode.enable=false -Dtls.server.mode=enforcing  -Dtls.server.need.client.auth=required" apacherocketmq/rocketmq:ROCKETMQ_VERSION sh mqbroker

# Service unavailable when not ready
# sleep 20

# Produce messages
# sh ./play-producer.sh
