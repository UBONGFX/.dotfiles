FROM ubuntu:22.04

RUN apt-get update && apt-get install -y \
    curl git bash sudo build-essential procps file ca-certificates

RUN git clone https://github.com/bats-core/bats-core.git /opt/bats \
 && ln -s /opt/bats/bin/bats /usr/local/bin/bats

RUN useradd -m -s /bin/bash devuser \
 && usermod -aG sudo devuser \
 && echo 'devuser ALL=(ALL) NOPASSWD:ALL' > /etc/sudoers.d/devuser

ENV HOME=/home/devuser
WORKDIR $HOME

USER devuser

CMD ["bash"]