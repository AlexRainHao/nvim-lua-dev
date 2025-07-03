FROM debian:12

LABEL maintainer="yuanyh <yuanyuhaoyyh@gmail.com>"
LABEL description="container for vim lua migration"

USER root

WORKDIR /home

ENV LANG C.UTF-8
ENV LC_ALL C.UTF-8
ENV PYTHONIOENCODING=utf-8
ENV PYTHONUNBUFFERED=1

ENV TZ=Asia/Shanghai
RUN set -ex && \
  ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && \
  echo $TZ > /etc/timezone

RUN set -i 's/deb.debian.org/mirrors.ustc.edu.cn/g' /etc/apt/sources.list.d/debian.sources && \
  apt-get update -y && \
  apt-get install -y file curl wget openssh-server ssh git tree lua5.3 cmake gcc

RUN sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config && \
  echo "root:root" | chpasswd && \
  echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers && \
  service ssh start

EXPOSE 22

VOLUME [ "install.sh" ]

CMD [ "/usr/sbin/sshd", "-D" ]
