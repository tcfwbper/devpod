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

FROM ubuntu:22.04

## Password
ARG PWD_ARG

## install package with non-interactive mode
ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=Asia/Taipei
## env: security
## Not need to change user accounthere.
## We will modify them at runtime to ensure security and flexibility.
ENV UBUNTU_ACCOUNT="user" \
    UBUNTU_PWD=$PWD_ARG \
    ## To keep the consistency of permissions, do not change USER_ID and GROUP_ID casually.
    USER_ID="1001" \
    GROUP_ID="1001"
## env: version of tools
ENV DOCKER_COMPOSE_VERSION="v2.29.7" \
    PYTHON_PACKAGE_NAME="python3.10" \
    KUBECTL_VERSION="v1.31.1" \
    K9S_VERSION="v0.50.2"

## install: apt packages
RUN apt update && apt install -y \
    sudo \
    vim \
    curl \
    net-tools \
    iputils-ping \
    gettext \
    openssh-server \
    docker.io \
    git

## install python
RUN apt install -y software-properties-common && \
    add-apt-repository -y ppa:deadsnakes/ppa && \
    apt update && \
    apt install -y $PYTHON_PACKAGE_NAME python3-pip

## account: user
RUN groupadd -g $GROUP_ID $UBUNTU_ACCOUNT && \
    useradd -rm -d /home/$UBUNTU_ACCOUNT -s /bin/bash -G sudo -u $USER_ID -g $GROUP_ID $UBUNTU_ACCOUNT && \
    echo "${UBUNTU_ACCOUNT}:${UBUNTU_PWD}" | chpasswd

## install docker-compose
RUN curl -L "https://github.com/docker/compose/releases/download/${DOCKER_COMPOSE_VERSION}/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose && \
    chmod +x /usr/local/bin/docker-compose
## install: kubectl
RUN curl -LO "https://dl.k8s.io/release/$KUBECTL_VERSION/bin/linux/amd64/kubectl" && \
    install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl && \
    rm kubectl
## install: k9s
RUN curl -LO https://github.com/derailed/k9s/releases/download/$K9S_VERSION/k9s_Linux_amd64.tar.gz && \
    tar -zxvf k9s_Linux_amd64.tar.gz && \
    chmod +x k9s && \
    mv k9s /usr/local/bin && \
    ## housekeeping
    rm LICENSE && \
    rm README.md && \
    rm k9s_Linux_amd64.tar.gz

## setup: ssh
RUN mkdir /var/run/sshd && \
    sed -i "s/#PasswordAuthentication yes/PasswordAuthentication yes/" /etc/ssh/sshd_config
EXPOSE 22

## runtime
ENTRYPOINT ["bash", "-c", "/usr/sbin/sshd -D"]
