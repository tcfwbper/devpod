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

cd "$(dirname "$(realpath "$0")")/.."

## env: color
RED='\033[0;31m'
NC='\033[0m' # (reset)

# username
echo -e "Fill out your ${RED}devpod username${NC}."
read -p "Username: " USERNAME

# password
while true; do
    echo -e "Fill out your ${RED}devpod password${NC}."
    read -sp "Password: " PASSWORD
    echo
    read -sp "Retype password: " PASSWORD_CHECK
    echo
    if [[ $PASSWORD == $PASSWORD_CHECK ]]; then
      break
    fi
    echo "Password mismatch."
done

# nodeport
echo
while true; do
    echo -e "Fill out your ${RED}devpod ssh nodeport${NC}. Please make sure the port is available."
    read -p "Nodeport (30000-32767): " SSH_NODEPORT
    if [[ ! $SSH_NODEPORT =~ ^[0-9]+$ ]]; then
        echo "This value must be an integer."
        continue
    fi
    if ! [[ "$SSH_NODEPORT" -ge 30000 && "$SSH_NODEPORT" -le 32767 ]]; then
        echo "The target port ${SSH_NODEPORT} is out of range (30000-32767)."
        continue
    fi
    break
done

# storageclass
echo -e "Fill out a ${RED}storageclass${NC} to store your data. Please make sure the storageclass exists in your cluster."
read -p "Storageclass (local-path): " STORAGE_CLASS
if [[ -z $STORAGE_CLASS ]]; then
    STORAGE_CLASS="local-path"
fi

# docker
echo
while true; do
  read -p "Enable docker? ([y]/n): " ENABLE_DOCKER
  if [[ -z $ENABLE_DOCKER ]]; then
      ENABLE_DOCKER="yes"
  fi
  ENABLE_DOCKER=$(echo "$ENABLE_DOCKER" | tr '[:upper:]' '[:lower:]')
  if [[ $ENABLE_DOCKER == "yes" || $ENABLE_DOCKER == "y" || $ENABLE_DOCKER == "no" || $ENABLE_DOCKER == "n" ]]; then
    break
  else
    echo -e "Your answer should be one of ${RED}yes${NC}/${RED}y${NC}/${RED}no${NC}/${RED}n${NC}."
  fi
done
if [[ $ENABLE_DOCKER == "yes" || $ENABLE_DOCKER == "y" ]]; then
  while true; do
    echo "Select Docker mode:"
    echo "  1) Use dind (default)"
    echo "  2) Use host docker socket"
    read -p "Docker mode (1-2): " DOCKER_MODE
    if [[ -z $DOCKER_MODE ]]; then
      DOCKER_MODE=1
    fi
    if [[ $DOCKER_MODE == "1" || $DOCKER_MODE == "2" ]]; then
      break
    else
      echo -e "Please enter ${RED}1${NC} or ${RED}2${NC}."
    fi
  done
  if [[ $DOCKER_MODE == "1" ]]; then
    echo "Using host docker socket."
    USE_HOST_SOCKET=true
  else
    echo "Using Docker-in-Docker."
    USE_HOST_SOCKET=false
  fi
fi
if [[ -z $USE_HOST_SOCKET ]]; then
  USE_HOST_SOCKET=false
fi

# other arguments
CHART_VERSION="1.1.0"
RELEASE="$USERNAME-devpod"
NAMESPACE=devpod
SERVICE_TYPE="NodePort"

helm upgrade $RELEASE oci://ghcr.io/tcfwbper/helm/devpod --version $CHART_VERSION -n $NAMESPACE --install --create-namespace \
    --set global.storageClass=$STORAGE_CLASS \
    --set auth.username=$USERNAME \
    --set auth.password=$PASSWORD \
    --set service.type=$SERVICE_TYPE \
    --set service.nodePorts.ssh=$SSH_NODEPORT
