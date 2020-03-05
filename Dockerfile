## Create container using nvidia-docker and add shared memory size argument
FROM pytorch/pytorch:1.1.0-cuda10.0-cudnn7.5-runtime

ARG git_owner
ARG git_repo
ARG git_branch

ENV SINGNET_REPOS=/opt/singnet
ENV PROJECT_ROOT=${SINGNET_REPOS}/${git_repo}
ENV DEBIAN_FRONTEND=noninteractive

# Updating and installing common dependencies
RUN apt-get update && \
    apt upgrade -y && \
    apt-get install -y \
    sudo \
    git \
    gedit \
    wget \
    nano \
    unzip \
    r-base \
    python3-pip

# Installing snet-daemon + dependencies
RUN cd /tmp && \
    wget https://github.com/singnet/snet-daemon/releases/download/v3.1.0/snet-daemon-v3.1.0-linux-amd64.tar.gz && \
    tar -xvf snet-daemon-v3.1.0-linux-amd64.tar.gz && \
    mv snet-daemon-v3.1.0-linux-amd64/snetd /usr/bin/snetd

# Cloning service repository
RUN mkdir -p ${SINGNET_REPOS} && \
    cd ${SINGNET_REPOS} &&\
    git clone -b ${git_branch} --single-branch https://github.com/${git_owner}/${git_repo}.git

# Installing projects's original dependencies and building protobuf messages
RUN cd ${PROJECT_ROOT} &&\
    pip3 install -r requirements.txt &&\
    sh buildproto.sh

WORKDIR ${PROJECT_ROOT}
