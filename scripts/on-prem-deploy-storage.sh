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

NFS_STORAGE_CLASS="nfs-client"
NFS_SERVER="127.0.0.1"
NFS_PATH="/var/nfsshare"

helm upgrade devpod-storage -n devpod --install --create-namespace \
    --set k8sEnvironment="on-prem" \
    --set sharedStorage.pv.enabled=true \
    --set sharedStorage.pvc.enabled=true \
    --set sharedStorage.storageClass=$NFS_STORAGE_CLASS \
    --set sharedStorage.nfsprov.nfs.server=$NFS_SERVER \
    --set sharedStorage.nfsprov.nfs.path=$NFS_PATH \
    helm-charts/devpod/
