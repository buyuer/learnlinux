FROM ubuntu:22.04

ARG user=learner
ARG ohmyzsh_url=https://mirrors.tuna.tsinghua.edu.cn/git/ohmyzsh.git
ARG linux_url=https://mirrors.tuna.tsinghua.edu.cn/git/linux.git
ARG busybox_url=https://github.com/mirror/busybox.git

#替换为清华大学的镜像源
#RUN sed -i "s@http://.*archive.ubuntu.com@https://mirrors.tuna.tsinghua.edu.cn@g" /etc/apt/sources.list && \
#    sed -i "s@http://.*security.ubuntu.com@https://mirrors.tuna.tsinghua.edu.cn@g" /etc/apt/sources.list

# 更新本地软件包
RUN apt-get update && \
    apt-get -y upgrade && \
    apt-get -y install sudo zsh apt-utils

# 创建learn用户
RUN useradd --create-home --shell /bin/zsh ${user} && \
    echo "${user}:${user}" | chpasswd

# 安装必要的软件包
RUN apt-get install -y build-essential git kconfig-frontends flex bison libelf-dev bc libssl-dev qemu qemu-system-x86

USER ${user}
WORKDIR /home/${user}

# 安装ohmyzsh
RUN git clone ${ohmyzsh_url} && \
    REMOTE=${ohmyzsh_url} sh ./ohmyzsh/tools/install.sh && \
    rm ./ohmyzsh -r

# 准备代码
RUN mkdir work
WORKDIR /home/${user}/work
RUN git clone ${linux_url} && \
    git clone ${busybox_url}
