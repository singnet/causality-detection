## Create container using nvidia-docker and add shared memory size argument
FROM ubuntu:18.04

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
RUN SNETD_VERSION=`curl -s https://api.github.com/repos/singnet/snet-daemon/releases/latest | grep -oP '"tag_name": "\K(.*)(?=")' || echo "v3.1.6"` && \
    echo 'version' $SNETD_VERSION && \
    wget https://github.com/singnet/snet-daemon/releases/download/${SNETD_VERSION}/snet-daemon-${SNETD_VERSION}-linux-amd64.tar.gz && \
    tar -xvf snet-daemon-${SNETD_VERSION}-linux-amd64.tar.gz && \
    sudo mv snet-daemon-${SNETD_VERSION}-linux-amd64/snetd /usr/bin/snetd

# Cloning service repository
RUN mkdir -p ${SINGNET_REPOS} && \
    cd ${SINGNET_REPOS} &&\
    git clone -b ${git_branch} --single-branch https://github.com/${git_owner}/${git_repo}.git

# Installing projects's original dependencies and building protobuf messages
RUN cd ${PROJECT_ROOT} &&\
    pip3 install -r requirements.txt &&\
    sh buildproto.sh

WORKDIR ${PROJECT_ROOT}
