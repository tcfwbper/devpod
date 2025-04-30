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

set -e -o pipefail
cd "$(dirname "$(realpath "$0")")/.."

## env: image
CR="docker.io/tcfwbper"
IMAGE_NAME="dev-env"
IMAGE_TAG="v0.1.0-"

## env: color
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m' # (reset)

## Prompt for account and password
echo
echo -e "Fill out your name. This will be your ${RED}ubuntu account${NC}."
read -p "New account: " ACCOUNT_ARG
while true; do
    echo "Fill out your password. This will be the login credential for root and your account."
    read -sp "New password: " PWD_ARG
    echo
    echo "Fill out your password again for password verification."
    read -sp "Retype new password: " PWD_ARG_CHECK
    echo
    if [[ $PWD_ARG == $PWD_ARG_CHECK ]]; then
        break
    fi
    echo "Password mismatch."
done
echo -e "⚠️ Fill out the image tag suffix. The tag will be ${RED}${IMAGE_TAG}<suffix>${NC}"
echo -e "⚠️ It's strongly suggested that ${RED}use your name as the suffix${NC}."
read -p "Image tag suffix: " SUFFIX
echo

# ## Build the Docker image
docker build --build-arg ACCOUNT_ARG="$ACCOUNT_ARG" --build-arg PWD_ARG="$PWD_ARG" -t ${CR}/${IMAGE_NAME}:${IMAGE_TAG}${SUFFIX} docker/dev-env/

## Push the Docker image
echo -e "Your image, ${RED}${CR}/${IMAGE_NAME}:${IMAGE_TAG}${SUFFIX}${NC}, has been bulit."
while true; do
    echo
    echo "\"docker push\" is required if you'd like to deploy dev-env on cloud."
    read -p "Do you want to push your image? (yes/no): " response
    echo
    response=$(echo "$response" | tr '[:upper:]' '[:lower:]')
    
    if [[ "$response" == "yes" ]]; then
        echo -e "⚠️ Try ${RED}docker login ${CR}${NC}."
        docker login ${CR}
        docker push ${CR}/${IMAGE_NAME}:${IMAGE_TAG}${SUFFIX}
        break
    elif [[ "$response" == "no" ]]; then
        break
    else
        echo "Invalid input. Please enter 'yes' or 'no'."
    fi
done
