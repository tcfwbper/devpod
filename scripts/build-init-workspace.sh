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

INIT_WORKSPACE_IMAGE_VERSION="v0.1.0"

## env: image
CR="docker.io/tcfwbper"
IMAGE_NAME="dev-env"
IMAGE_TAG="$INIT_WORKSPACE_IMAGE_VERSION-init-workspace"

docker build -t $CR/$IMAGE_NAME:$IMAGE_TAG docker/init-workspace
docker login ${CR}
docker push $CR/$IMAGE_NAME:$IMAGE_TAG
