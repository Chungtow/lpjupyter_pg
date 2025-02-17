# 第一阶段：基础环境准备
FROM ubuntu:20.04 AS base
LABEL maintainer="moweng<changtao86@163.com>"

# 设置非交互式前端环境变量
ENV DEBIAN_FRONTEND=noninteractive

# 更新包列表并安装语言包
RUN apt-get update && \
    apt-get install -y language-pack-en language-pack-zh-hans && \
    locale-gen en_US.UTF-8 && \
    locale-gen zh_CN.UTF-8 && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# 设置环境变量
ENV LANG=en_US.UTF-8 \
    LANGUAGE=en_US:en \
    LC_ALL=en_US.UTF-8

# 安装必要软件
RUN apt-get update && \
    apt-get install -y vim net-tools wget tzdata build-essential libssl-dev zlib1g-dev libncurses5-dev libncursesw5-dev libreadline-dev libsqlite3-dev libgdbm-dev libdb-dev libbz2-dev libexpat1-dev liblzma-dev tk-dev libffi-dev && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# 配置时区为 Asia/Shanghai (或需要的其他时区)
RUN echo 'Asia/Shanghai' > /etc/timezone && \
    ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime && \
    dpkg-reconfigure --frontend noninteractive tzdata

# 安装 Miniconda
# COPY Miniconda3-py312_24.11.1-0-Linux-x86_64.sh /miniconda.sh
# 使用 wget 下载 Miniconda 安装脚本并重命名为 /miniconda.sh
RUN wget --quiet https://repo.anaconda.com/miniconda/Miniconda3-py312_24.11.1-0-Linux-x86_64.sh -O /miniconda.sh
RUN /bin/bash /miniconda.sh -b -p /opt/conda && \
    rm /miniconda.sh

# 将 Miniconda 的 bin 目录添加到 PATH 环境变量中
ENV PATH=/opt/conda/bin:$PATH


# 第二阶段：Node.js 和相关工具安装
FROM base AS nodejs_setup

# 设置工作目录到/usr/local
WORKDIR /usr/local


# 使用 wget 下载 Node.js 压缩包并解压到 /usr/local/nodejs
RUN wget --quiet https://nodejs.org/dist/v18.16.0/node-v18.16.0-linux-x64.tar.xz -O nodejs.tar.xz && \
    tar -xf nodejs.tar.xz && \
    mv node-v18.16.0-linux-x64 nodejs && \
    rm nodejs.tar.xz && \
    # 创建软链接以方便全局访问node和npm命令
    && ln -s /usr/local/nodejs/bin/node /usr/local/bin/node \
    && ln -s /usr/local/nodejs/bin/npm /usr/local/bin/npm \
    # 使用npm全局安装configurable-http-proxy
    && npm install -g configurable-http-proxy \
    # 使用ln命令建立软链接同步
    && ln -s /usr/local/nodejs/bin/configurable-http-proxy /usr/local/bin/configurable-http-proxy

# 确认安装是否成功
RUN node -v && npm -v && configurable-http-proxy --version


# 第三阶段：JupyterHub 及其依赖项安装
FROM nodejs_setup AS final

# 永久切换pip源到清华镜像源
RUN pip3 config set global.index-url https://pypi.tuna.tsinghua.edu.cn/simple

# 激活虚拟环境并安装 JupyterHub、安装JupyterLab、中文插件、Jupyter Scheduler
RUN /opt/conda/bin/conda init bash && \
    /opt/conda/bin/conda create -n pyenv python=3.12 && \
    echo "conda activate pyenv" >> ~/.bashrc && \
    /opt/conda/envs/pyenv/bin/pip install --no-cache-dir jupyterhub==5.2.1 && \
    /opt/conda/envs/pyenv/bin/pip install --no-cache-dir jupyterlab==4.3.0 && \
    /opt/conda/envs/pyenv/bin/pip install --no-cache-dir jupyterlab-language-pack-zh-CN && \
    /opt/conda/envs/pyenv/bin/pip install --no-cache-dir jupyter_scheduler==2.10.0 && \
    /opt/conda/envs/pyenv/bin/jupyterhub --version && \
    /opt/conda/envs/pyenv/bin/jupyter lab --version && \
    /opt/conda/envs/pyenv/bin/jupyter labextension list && \
    rm -rf /root/.cache && \
    mkdir -p /etc/jupyterhub && \
    /opt/conda/envs/pyenv/bin/jupyterhub --generate-config -f /etc/jupyterhub/jupyterhub_config.py

# 将宿主机的jupyterhub_config.txt文件复制到容器中，并追加到jupyterhub_config.py
COPY jupyterhub_config.txt /tmp/jupyterhub_config.txt
RUN cat /tmp/jupyterhub_config.txt >> /etc/jupyterhub/jupyterhub_config.py

# 创建/start.sh脚本
# 在系统中创建3个用户，与jupyterhub_config.py的用户对应
RUN echo '#!/bin/bash' > /start.sh && \
    echo 'source /root/.bashrc' >> /start.sh && \
    echo 'eval $(/opt/conda/bin/conda shell.bash hook)' >> /start.sh && \
    echo 'source activate pyenv' >> /start.sh && \
    echo 'useradd -m admin && echo "admin:$(openssl passwd -6 123456)" | chpasswd -e' >> /start.sh && \
    echo 'useradd -m user1 && echo "user1:$(openssl passwd -6 123456)" | chpasswd -e' >> /start.sh && \
    echo 'useradd -m user2 && echo "user2:$(openssl passwd -6 123456)" | chpasswd -e' >> /start.sh && \
    echo 'exec /opt/conda/envs/pyenv/bin/jupyterhub -f /etc/jupyterhub/jupyterhub_config.py' >> /start.sh

# 赋予/start.sh可执行权限
RUN chmod +x /start.sh

# 暴露必要的端口
EXPOSE 8000 

# 设置 CMD 指令
CMD ["/start.sh"]

