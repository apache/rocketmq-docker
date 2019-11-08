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

DLEDGER_NET=$(docker network ls |awk '/dledger-br/ {print $1}')
if [[ -n "$DLEDGER_NET" ]]; then
   echo "Removing DLedger Bridge network..."
   docker network rm $DLEDGER_NET
   # Wait till the existing networks are removed
   sleep 5
fi

prepare_dir()
{
    dirs=("data/namesrv/logs" "data/broker0/logs" "data/broker0/store" "data/broker1/logs" "data/broker1/store" "data/broker2/logs" "data/broker2/store")

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

# Create network
docker network create --subnet=172.18.0.0/16 dledger-br

# Start nameserver
docker run --net dledger-br --ip 172.18.0.11  -d -p 9876:9876 -v `pwd`/data/namesrv/logs:/home/rocketmq/logs --name rmqnamesrv  apacherocketmq/rocketmq:ROCKETMQ_VERSION sh mqnamesrv

# Start Brokers
docker run --net dledger-br --ip 172.18.0.12 -d -p 30911:30911 -p 30909:30909 -v `pwd`/data/broker0/logs:/home/rocketmq/logs -v `pwd`/data/broker0/store:/home/rocketmq/store -v `pwd`/data/broker0/conf/dledger:/opt/rocketmq-ROCKETMQ_VERSION/conf/dledger --name rmqbroker --link rmqnamesrv:namesrv -e "NAMESRV_ADDR=namesrv:9876" apacherocketmq/rocketmq:ROCKETMQ_VERSION sh mqbroker  -c  ../conf/dledger/broker.conf
docker run --net dledger-br --ip 172.18.0.13 -d -p 30921:30921 -p 30919:30919 -v `pwd`/data/broker1/logs:/home/rocketmq/logs -v `pwd`/data/broker1/store:/home/rocketmq/store -v `pwd`/data/broker1/conf/dledger:/opt/rocketmq-ROCKETMQ_VERSION/conf/dledger --name rmqbroker1 --link rmqnamesrv:namesrv -e "NAMESRV_ADDR=namesrv:9876" apacherocketmq/rocketmq:ROCKETMQ_VERSION sh mqbroker  -c  ../conf/dledger/broker.conf
docker run --net dledger-br --ip 172.18.0.14 -d -p 30931:30931 -p 30929:30929 -v `pwd`/data/broker2/logs:/home/rocketmq/logs -v `pwd`/data/broker2/store:/home/rocketmq/store -v `pwd`/data/broker2/conf/dledger:/opt/rocketmq-ROCKETMQ_VERSION/conf/dledger --name rmqbroker2 --link rmqnamesrv:namesrv -e "NAMESRV_ADDR=namesrv:9876" apacherocketmq/rocketmq:ROCKETMQ_VERSION sh mqbroker  -c  ../conf/dledger/broker.conf

# Service unavailable when not ready
# sleep 20

# Produce messages
# sh ./play-producer.sh
