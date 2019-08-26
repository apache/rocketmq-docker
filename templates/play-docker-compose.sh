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
    dirs=("docker-compose/data/namesrv/logs" "docker-compose/data/broker/logs" "docker-compose/data/broker/store" "docker-compose/data1/broker/logs" "docker-compose/data1/broker/store")

    for dir in ${dirs[@]}
    do
        if [ ! -d "`pwd`/${dir}" ]; then
            mkdir -p "`pwd`/${dir}"
            chmod a+rw "`pwd`/${dir}"
        fi
    done
}

prepare_dir

# Run nameserver and broker
docker-compose -f ./docker-compose/docker-compose.yml up -d
