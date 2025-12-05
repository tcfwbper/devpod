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

FROM alpine:3.23.0

## Password
ARG PWD_ARG

## env: security
ENV ALPINE_ACCOUNT="user" \
    ALPINE_PWD=$PWD_ARG \
    USER_ID="1001" \
    GROUP_ID="1001"

## env: version of tools
ENV DOCKER_COMPOSE_VERSION="v2.29.7" \
    KUBECTL_VERSION="v1.31.1" \
    K9S_VERSION="v0.50.6" \
    TZ=Asia/Taipei

## install: apk packages
RUN apk add --no-cache \
    sudo \
    vim \
    curl \
    bash \
    net-tools \
    iputils \
    gettext \
    openssh-server \
    docker-cli \
    git \
    shadow \
    tzdata

## install python
RUN apk add --no-cache \
    python3 \
    py3-pip \
    python3-dev \
    py3-virtualenv

## setup timezone
RUN cp /usr/share/zoneinfo/$TZ /etc/localtime && \
    echo $TZ > /etc/timezone

## account: user
RUN addgroup -g $GROUP_ID $ALPINE_ACCOUNT && \
    adduser -D -h /home/$ALPINE_ACCOUNT -s /bin/bash -G $ALPINE_ACCOUNT -u $USER_ID $ALPINE_ACCOUNT && \
    echo "${ALPINE_ACCOUNT}:${ALPINE_PWD}" | chpasswd && \
    echo "${ALPINE_ACCOUNT} ALL=(ALL) ALL" >> /etc/sudoers && \
    adduser $ALPINE_ACCOUNT wheel && \
    echo "%wheel ALL=(ALL) ALL" >> /etc/sudoers

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
    rm LICENSE README.md k9s_Linux_amd64.tar.gz

## setup: ssh
RUN ssh-keygen -A && \
    mkdir -p /run/sshd && \
    sed -i "s/#PasswordAuthentication yes/PasswordAuthentication yes/" /etc/ssh/sshd_config && \
    sed -i "s/#PermitRootLogin prohibit-password/PermitRootLogin no/" /etc/ssh/sshd_config

EXPOSE 22

## runtime
ENTRYPOINT ["/usr/sbin/sshd", "-D", "-e"]
