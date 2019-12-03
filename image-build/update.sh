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

checkVersion()
{
    echo "Version = $1"
	echo $1 |grep -E "^[0-9]+\.[0-9]+\.[0-9]+" > /dev/null
    if [ $? = 0 ]; then
        return 0
    fi

	echo "Version $1 illegal, it should be X.X.X format(e.g. 4.5.0), please check released versions in 'https://archive.apache.org/dist/rocketmq/'"
    exit -1
}

set -eu;

# Update the image of the latest released version
LATEST_VERSION=$(curl -s https://archive.apache.org/dist/rocketmq/ | awk -F '>' '{print $3}' | awk -F '/' '{print $1}' | grep '^[0-9]' | sort | tail -1)

checkVersion ${LATEST_VERSION}

baseImages=("alpine" "centos")

for baseImage in ${baseImages[@]}
do
    echo "Building image of version ${LATEST_VERSION}, base-image ${baseImage}"
    bash build-image.sh ${LATEST_VERSION} ${baseImage}
    if [ "${baseImage}" = "centos" ];then
        TAG=${LATEST_VERSION}
    else
        TAG=${LATEST_VERSION}-${baseImage}
    fi
    docker push apacherocketmq/rocketmq:${TAG}
done
