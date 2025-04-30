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

# please get the following variables from deploy-dev-pod.sh
# # DEVELOPER=
# # ENVIRONMENT=
# # DEVENV_IMAGE_TAG=
# # UBUNTU_USER=
# # SSH_PORT=
# # INIT_WORKSPACE_ENABLED="false"
# # REDIS_ENABLED="false"
# # MSSQL_ENABLED="false"
# # MSSQL_PASSWORD=
# # POSTGRESQL_ENABLED="false"
# # POSTGRESQL_USER=
# # POSTGRESQL_PASSWORD=

helm upgrade $DEVELOPER-$ENVIRONMENT -n devpod --install --create-namespace \
    --set k8sEnvironment="on-prem" \
    --set devpod.enabled=true \
    --set devpod.developer=$DEVELOPER \
    --set devpod.environment=$ENVIRONMENT \
    --set devpod.imageTag=$DEVENV_IMAGE_TAG \
    --set devpod.ubuntu.user=$UBUNTU_USER \
    --set devpod.service.type=NodePort \
    --set devpod.service.nodePorts[0]=$SSH_PORT \
    --set initWorkspace.enabled=$INIT_WORKSPACE_ENABLED \
    --set dockerDaemon.enabled=true \
    --set redis.enabled=$REDIS_ENABLED \
    --set mssql.enabled=$MSSQL_ENABLED \
    --set mssql.password=$MSSQL_PASSWORD \
    --set postgresql.enabled=$POSTGRESQL_ENABLED \
    --set postgresql.user=$POSTGRESQL_USER \
    --set postgresql.password=$POSTGRESQL_PASSWORD \
    --set spot.enabled=false \
    helm-charts/devpod/
