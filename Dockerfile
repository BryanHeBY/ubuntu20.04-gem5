FROM ubuntu:20.04

ARG TZ=Asia/Shanghai
ENV TZ ${TZ}
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

RUN apt-get update
RUN apt-get install -y build-essential git m4 scons zlib1g zlib1g-dev libprotobuf-dev \
        protobuf-compiler libprotoc-dev libgoogle-perftools-dev python-dev python \
        python3-dev python3-pip graphviz
RUN pip3 install pydot

# RUN apt-get -y install libprotobuf-dev protobuf-compiler libgoogle-perftools-dev
# RUN apt-get -y install libboost-all-dev

WORKDIR /opt
RUN git clone --depth=1 https://gem5.googlesource.com/public/gem5
WORKDIR /opt/gem5
RUN python3 `which scons` build/X86/gem5.opt -j `nproc`

# add user
RUN useradd --create-home --no-log-init --shell /bin/bash -G sudo user && \
    adduser user sudo && \
    echo 'user:00000' | chpasswd

# sshd
RUN apt-get install -y openssh-server
RUN mkdir /var/run/sshd
RUN sed -ri 's/^PermitRootLogin\s+.*/PermitRootLogin yes/' /etc/ssh/sshd_config
RUN sed -ri 's/UsePAM yes/#UsePAM yes/g' /etc/ssh/sshd_config

# entrypoint
CMD ["/usr/sbin/sshd", "-D"]
