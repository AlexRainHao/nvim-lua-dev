FROM debian:12

LABEL maintainer="yuanyh <yuanyuhaoyyh@gmail.com>"
LABEL description="container for vim lua migration"

USER root

WORKDIR /home

ENV LANG C.UTF-8
ENV LC_ALL C.UTF-8
ENV PYTHONIOENCODING=utf-8
ENV PYTHONUNBUFFERED=1
ENV NPMMIRROR = https://registry.npmmirror.com
ENV PIPMIRROR = https://mirrors.tuna.tsinghua.edu.cn/pypi/web/simple

ENV TZ=Asia/Shanghai
RUN set -ex && \
  ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && \
  echo $TZ > /etc/timezone

RUN set -i 's/deb.debian.org/mirrors.ustc.edu.cn/g' /etc/apt/sources.list.d/debian.sources && \
  apt-get update -y && \
  apt-get install -y file curl wget openssh-server ssh git tree lua5.3 cmake make gcc nodejs npm python3 python3-pip && \
  apt-get isntall -y luarocks liblua5.3-dev sqlite3 libsqlite3-dev python3.11-venv

RUN luarocks install sqlite

RUN pip install neovim

RUN sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config && \
  echo "root:root" | chpasswd && \
  echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers && \
  service ssh start

RUN npm config set registry ${NPMMIRROR} && \
  pip config set global.index-url ${PIPMIRROR} && \
  pip config set global.break-system-packages true

# rust
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y

# golang
RUN curl -sL https://go.dev/dl/go1.24.5.linux-amd64.tar.gz | tar -C /usr/local -zxvf - && \
  echo "export PATH=$PATH:/usr/local/go/bin" >> ~/.bashrc && \
  echo "export GOPROXY=https://goproxy.cn,direct" >> ~/.bashrc && \
  /usr/local/go/bin/go env -w GO111MODULE=on

EXPOSE 22

VOLUME [ "install.sh" ]

CMD [ "/usr/sbin/sshd", "-D" ]
