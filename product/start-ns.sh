#!/bin/sh

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


## Main
if [ $# -lt 3 ]; then
    echo "Usage: sh $0 DATA_HOME ROCKETMQ_VERSION BASE_IMAGE"
    exit -1
fi

DATA_HOME=$1
ROCKETMQ_VERSION=$2
BASE_IMAGE=$3

## Show Env Setting
echo "ENV Setting: "
echo "DATA_HOME=${DATA_HOME} ROCKETMQ_VERSION=${ROCKETMQ_VERSION}"

# Start nameserver
start_namesrv()
{
    TAG_SUFFIX=$1
    docker run -d -v ${DATA_HOME}/logs:/home/rocketmq/logs \
      --name rmqnamesrv \
      -p 9876:9876 \
      apacherocketmq/rocketmq:${ROCKETMQ_VERSION}${TAG_SUFFIX} \
      sh mqnamesrv
}

case "${BASE_IMAGE}" in
    alpine)
        start_namesrv -alpine
    ;;
    centos)
        start_namesrv
    ;;
    *)
        echo "${BASE_IMAGE} is not supported, supported base images: centos, alpine"
        exit -1
    ;;
esac