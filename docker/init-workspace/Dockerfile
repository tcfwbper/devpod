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

FROM busybox

WORKDIR /tmp/workspace_tmp

COPY init-workspace.sh init-workspace.sh
COPY bashrc .bashrc
COPY bash_profile .bash_profile
COPY bash_aliases .bash_aliases
COPY dircolors .dircolors

ENTRYPOINT ["sh", "-c", "/tmp/workspace_tmp/init-workspace.sh"]
