# NOTE: As 2026-06, this is ubuntu version in github actions... so mimic that
FROM ubuntu:22.04

# Avoid timezone prompts
ENV DEBIAN_FRONTEND=noninteractive

# dep install
# NOTE: forces more recent gcc/g++ version
RUN apt-get update && apt-get install -y \
    sudo software-properties-common wget cmake ninja-build pip \
    libzstd-dev libedit-dev libcurl4-openssl-dev less && \
    add-apt-repository ppa:ubuntu-toolchain-r/test -y && \
    apt-get install -y gcc-13 g++-13 && \
    update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-13 100 --slave /usr/bin/g++ g++ /usr/bin/g++-13 && \
    wget https://apt.repos.intel.com/intel-gpg-keys/GPG-PUB-KEY-INTEL-SW-PRODUCTS.PUB && \
    apt-key add GPG-PUB-KEY-INTEL-SW-PRODUCTS.PUB && \
    echo "deb https://apt.repos.intel.com/oneapi all main" | tee /etc/apt/sources.list.d/oneAPI.list && \
    pip install lit && \
    useradd -m -G sudo -s /bin/bash user && \
    echo "user ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# Allow scripts to detect this is a container using env var
ENV IS_CONTAINER=TRUE

# Define the user and the start point for the user 
USER user
WORKDIR /home/user
