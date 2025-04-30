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

RESOURCE_GROUP=""
STORAGE_ACCOUNT=""

helm upgrade devpod-storage -n devpod --install --create-namespace \
    --set k8sEnvironment="cloud" \
    --set sharedStorage.pv.enabled=true \
    --set sharedStorage.pvc.enabled=true \
    --set sharedStorage.storageClass="azureblob-nfs-premium" \
    --set sharedStorage.blob.resourceGroup=$RESOURCE_GROUP \
    --set sharedStorage.blob.storageAccount=$STORAGE_ACCOUNT \
    --set sharedStorage.blob.container="devpod-nfs" \
    --set sharedStorage.blob.protocol="nfs" \
    helm-charts/devpod/
