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
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m' # (reset)

## on-prem or cloud
echo
echo -e "⚠️ Please check if you are using the ${RED}right kubenetes context${NC}."
echo -e "⚠️ You can ignore this warning if you already jumped to the recommended machine."
while true; do
  read -p "Where do you want to deploy your dev-env? (1.on-prem / 2.cloud): " response
  echo
  response=$(echo "$response" | tr '[:upper:]' '[:lower:]')
  
  if [[ "$response" == "on-prem" || "$response" == "1" ]]; then
    K8S_ENVIRONMENT="on-prem"
    break
  elif [[ "$response" == "cloud" || "$response" == "2" ]]; then
    K8S_ENVIRONMENT="cloud"
    break
  else
    echo -e "Invalid input. Please enter ${RED}1${NC}, ${RED}2${NC}, ${RED}on-prem${NC} or ${RED}cloud${NC}."
  fi
done

## developer, environment
echo
echo -e "Fill out your name."
read -p "Who's the developer: " DEVELOPER
while true; do
  echo -e "Fill out your environment (dev/exp/stage/prod)."
  read -p "Your environment (dev): " ENVIRONMENT
  if [[ -z $ENVIRONMENT ]]; then
    ENVIRONMENT=dev
  fi
  if ! [[ $ENVIRONMENT == "dev" || $ENVIRONMENT == "exp" || $ENVIRONMENT == "stage" || $ENVIRONMENT == "prod" ]]; then
    echo -e "Your environment should be ${RED}dev${NC}, ${RED}exp${NC}, ${RED}stage${NC} or ${RED}prod${NC}."
  else
    break
  fi
done

## dev-env image
echo -e "Fill out your image tag."
echo -e "Use ${RED}\"v0.1.0-demo\"${NC} if you haven't built your dev-env."
read -p "Your image tag (<vx.x.x>-<suffix>): " DEVENV_IMAGE_TAG

## ubuntu user
echo -e "Fill out your ${RED}ubuntu user account${NC}."
echo -e "⚠️ This must be ${RED}consistent with the one you filled while building image${NC}."
echo -e "Fill out ${RED}\"user\"${NC} if you are using ${RED}v0.1.0-demo${NC}."
read -p "Your user account: " UBUNTU_USER

## nodeport
if [ $K8S_ENVIRONMENT == "on-prem" ]; then
  while true; do
    echo -e "Fill out your devpod NodePort."
    read -p "Your ssh port (30000-32767): " SSH_PORT
    if [[ ! $SSH_PORT =~ ^[0-9]+$ ]]; then
      echo -e "This value must be an integer."
      continue
    fi
    if ! [[ "$SSH_PORT" -ge 30000 && "$SSH_PORT" -le 32767 ]]; then
      echo -e "The target port ${SSH_PORT} is out of range (30000-32767)."
      continue
    fi
    if kubectl get services --all-namespaces | grep ":${SSH_PORT}" | grep -v "${DEVELOPER}-${ENVIRONMENT}-svc" > /dev/null; then
      echo -e "The target port ${SSH_PORT} is not available."
      continue
    else
      break
    fi
    echo -e "You can access your devpod by ${RED}\"ssh ${UBUNTU_USER}@<your host> -p ${SSH_PORT}\"${NC}."
  done
else
  echo -e "Please ${RED}setup ingress-nginx later for ssh connection${NC}."
fi

## init workspace
echo
while true; do
  echo -e "You are recommended initializing your workspace at the first deployment."
  read -p "Do you want to initialize your workspace? (true): " INIT_WORKSPACE_ENABLED
  echo
  if [[ -z $INIT_WORKSPACE_ENABLED ]]; then
    INIT_WORKSPACE_ENABLED="true"
  fi
  INIT_WORKSPACE_ENABLED=$(echo "$INIT_WORKSPACE_ENABLED" | tr '[:upper:]' '[:lower:]')
  if [[ $INIT_WORKSPACE_ENABLED == "true" || $INIT_WORKSPACE_ENABLED == "false" ]]; then
    break
  else
    echo -e "Your answer should be ${RED}true${NC} or ${RED}false${NC}."
  fi
done

## install redis
echo
while true; do
  read -p "Do you want to install redis? (false): " REDIS_ENABLED
  if [[ -z $REDIS_ENABLED ]]; then
    REDIS_ENABLED="false"
  fi
  REDIS_ENABLED=$(echo "$REDIS_ENABLED" | tr '[:upper:]' '[:lower:]')
  if [[ $REDIS_ENABLED == "true" || $REDIS_ENABLED == "false" ]]; then
    break
  else
    echo -e "Your answer should be ${RED}true${NC} or ${RED}false${NC}."
  fi
done

## install mssql
echo
while true; do
  read -p "Do you want to install MSSQL? (false): " MSSQL_ENABLED
  if [[ -z $MSSQL_ENABLED ]]; then
    MSSQL_ENABLED="false"
  fi
  MSSQL_ENABLED=$(echo "$MSSQL_ENABLED" | tr '[:upper:]' '[:lower:]')
  if [[ $MSSQL_ENABLED == "true" || $MSSQL_ENABLED == "false" ]]; then
    break
  else
    echo -e "Your answer should be ${RED}true${NC} or ${RED}false${NC}."
  fi
done
if [[ "$MSSQL_ENABLED" == "true" ]]; then
  while true; do
    echo -e "⚠️ Please ensure your SA password meet Microsoft's regulation about strong password."
    read -sp "Your azure-db SA password: " MSSQL_PASSWORD
    echo
    read -sp "Retype your azure-db SA password: " MSSQL_PASSWORD_CHECK
    echo
    if [[ $MSSQL_PASSWORD == $MSSQL_PASSWORD_CHECK ]]; then
      break
    fi
    echo -e "Password mismatch."
  done
fi

## install postgres
echo
while true; do
  read -p "Do you want to install postgres? (false): " POSTGRESQL_ENABLED
  if [[ -z $POSTGRESQL_ENABLED ]]; then
      POSTGRESQL_ENABLED="false"
  fi
  POSTGRESQL_ENABLED=$(echo "$POSTGRESQL_ENABLED" | tr '[:upper:]' '[:lower:]')
  if [[ $POSTGRESQL_ENABLED == "true" || $POSTGRESQL_ENABLED == "false" ]]; then
    break
  else
    echo -e "Your answer should be ${RED}true${NC} or ${RED}false${NC}."
  fi
done
if [[ "$POSTGRESQL_ENABLED" == "true" ]]; then
  read -p "Your postgres user: " POSTGRESQL_USER
  while true; do
    read -sp "Your postgres password: " POSTGRESQL_PASSWORD
    echo
    read -sp "Retype your postgres password: " POSTGRESQL_PASSWORD_CHECK
    echo
    if [[ $POSTGRESQL_PASSWORD == $POSTGRESQL_PASSWORD_CHECK ]]; then
      break
    fi
    echo -e "Password mismatch."
  done
fi

## deploy on spot
if [ $K8S_ENVIRONMENT == "cloud" ]; then
  echo
  while true; do
    read -p "Do you want to allow devpod to use spot nodes? (false): " SPOT_ENABLED
    if [[ -z $SPOT_ENABLED ]]; then
      SPOT_ENABLED="false"
    fi
    SPOT_ENABLED=$(echo "$SPOT_ENABLED" | tr '[:upper:]' '[:lower:]')
    if [[ $SPOT_ENABLED == "true" || $SPOT_ENABLED == "false" ]]; then
      break
    else
      echo -e "Your answer should be ${RED}true${NC} or ${RED}false${NC}."
    fi
  done
fi

export DEVELOPER
export ENVIRONMENT
export DEVENV_IMAGE_TAG
export UBUNTU_USER
export SSH_PORT
export INIT_WORKSPACE_ENABLED
export REDIS_ENABLED
export MSSQL_ENABLED
export MSSQL_PASSWORD
export POSTGRESQL_ENABLED
export POSTGRESQL_USER
export POSTGRESQL_PASSWORD
export SPOT_ENABLED

if [ $K8S_ENVIRONMENT == "on-prem" ]; then
  bash scripts/on-prem-deploy-devpod.sh
fi

if [ $K8S_ENVIRONMENT == "cloud" ]; then
  bash scripts/azure-deploy-devpod.sh
fi