# This Dockerfile sets up an Ubuntu 22.04 environment for building the JLC TS-PI SDK.
# 这个 Dockerfile 用于搭建一个基于 Ubuntu 22.04 的 泰山派SDK 构建环境。

# Feel free to choose between Docker or Podman as your container engine.
# 你可以选择 Docker 或 Podman 作为你的容器引擎。只需要将下面的命令中的 podman 换成 docker 即可。

# SDK: https://github.com/CmST0us/tspi-linux-sdk

# ----------------------------------------------------------------------
# Build:
# If you use podman, you should build with sudo to make the image in root's registry.
# 如果你使用 podman，请用 sudo 来构建镜像，以便将镜像放在 root 的镜像库中。或者你需要手动将镜像从你的用户镜像库移动到 root 的镜像库。
# sudo podman build -t tspi-sdk-builder:v1 .

# Use:
# You need to run it outside of VS Code terminal to ensure proper permissions.
# 你需要在 VS Code 外运行。
# Interactive - init or deconfigure:
# sudo podman run --rm --privileged -it -v .:/mnt/sdk_work/ localhost/tspi-sdk-builder:v1 bash -c './build.sh init'
# Non-interactive - build:
# sudo podman run --rm --privileged -v .:/mnt/sdk_work/ localhost/tspi-sdk-builder:v1 bash -c './build.sh'
# ----------------------------------------------------------------------

# Base image
# 基于 Ubuntu 22.04 基础镜像
FROM ubuntu:22.04

# Create a new user 'fibre' with UID and GID 1000
# 创建一个新的用户 fibre，UID 和 GID 都是 1000
RUN groupadd -g 1000 fibre && useradd -m -u 1000 -g 1000 -s /bin/bash fibre

# Add fibre to sudo group
# 将新用户添加到 sudo 组
RUN usermod -aG sudo fibre && echo 'fibre ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

# Set environment variable to avoid interactive prompts
# 设置环境变量，避免交互式提示
ENV DEBIAN_FRONTEND=noninteractive

# Update package list and install necessary packages
# 更新包列表并安装必要的软件包
RUN printf "deb http://mirrors.ustc.edu.cn/ubuntu/ jammy main restricted universe multiverse\n \
deb http://mirrors.ustc.edu.cn/ubuntu/ jammy-security main restricted universe multiverse\n \
deb http://mirrors.ustc.edu.cn/ubuntu/ jammy-updates main restricted universe multiverse\n \
deb http://mirrors.ustc.edu.cn/ubuntu/ jammy-backports main restricted universe multiverse" > /etc/apt/sources.list && \
apt update && apt install -y \
-o Dpkg::Options::="--force-confdef" \
-o Dpkg::Options::="--force-confold" \
sudo && \
apt install -y build-essential git \
expect-dev libgucharmap-2-90-dev bzip2 expat gpgv2 cpp-aarch64-linux-gnu libgmp-dev \
libmpc-dev bc python2 rsync file bsdmainutils ssh make gcc libssl-dev liblz4-tool expect \
g++ patchelf chrpath gawk texinfo chrpath diffstat binfmt-support \
qemu-user-static live-build bison flex fakeroot cmake gcc-multilib \
g++-multilib unzip device-tree-compiler ncurses-dev python2 && \
apt clean && rm -rf /var/lib/apt/lists/*

# Install python2 as the default python version (No need here)
# 设置 python2 的默认命令为 python (此步骤可选)
# RUN ln -sf /usr/bin/python2 /usr/bin/python

# Set default user to fibre
# 设置默认用户
USER fibre

# Create SDK work directory and set ownership
# 创建工作目录
RUN sudo mkdir -p /mnt/sdk_work && sudo chown -R fibre:fibre /mnt/sdk_work

# Set work directory
# 设置工作目录
WORKDIR /mnt/sdk_work