#!/bin/bash
# Copyright 2025 Tsung-Han Chang. All Rights Reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
# ==============================================================================

while getopts u: flag
do
    case "${flag}" in
        u) USER_NAME=${OPTARG};;
    esac
done

# op-prem
if [ -z "${CLOUD}" ]; then
    ## Get the GID of /var/run/docker.sock
    DOCKER_SOCK="/var/run/docker.sock"
    GID=$(ls -n "$DOCKER_SOCK" | awk '{print $4}')

    ## Check if the "docker" group already exists
    if getent group docker > /dev/null; then
        ## Delete the "docker" group if it exists
        groupdel docker
        echo "the old docker group was deleted."
    fi

    ## Create a new "docker" group with the detected GID
    groupadd -g "$GID" docker
    echo "the docker group with GID $GID was created."

    ## Add the user to the "docker" group
    usermod -aG docker "${USER_NAME}"
    echo "Added $USER_NAME to the docker group with GID $GID."
fi

## run ssh server
/usr/sbin/sshd -D
