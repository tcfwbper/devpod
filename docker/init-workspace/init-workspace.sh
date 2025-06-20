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

chmod 755 /tmp/workspace

# bashrc
if [ ! -f "/tmp/workspace/.bashrc" ]; then
    cp .bashrc /tmp/workspace/.bashrc
    chmod 666 /tmp/workspace/.bashrc
    echo "export DOCKER_HOST=\"tcp://0.0.0.0:2375\"" >> /tmp/workspace/.bashrc
fi
# bash_profile
if [ ! -f "/tmp/workspace/.bash_profile" ]; then
    cp .bash_profile /tmp/workspace/.bash_profile
    chmod 666 /tmp/workspace/.bash_profile
fi
# bash_aliases
if [ ! -f "/tmp/workspace/.bash_aliases" ]; then
    cp .bash_aliases /tmp/workspace/.bash_aliases
    chmod 666 /tmp/workspace/.bash_aliases
fi
# dircolors
if [ ! -f "/tmp/workspace/.dircolors" ]; then
    cp .dircolors /tmp/workspace/.dircolors
    chmod 666 /tmp/workspace/.dircolors
fi
