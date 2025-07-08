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
  apt-get isntall -y luarocks liblua5.3-dev sqlite3 libsqlite3-dev

RUN luarocks install sqlite

RUN pip install neovim

RUN sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config && \
  echo "root:root" | chpasswd && \
  echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers && \
  service ssh start

RUN npm config set registry ${NPMMIRROR} && \
  pip config set global.index-url ${PIPMIRROR} && \
  pip config set global.break-system-packages true

EXPOSE 22

VOLUME [ "install.sh" ]

CMD [ "/usr/sbin/sshd", "-D" ]
