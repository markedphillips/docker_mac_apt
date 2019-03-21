FROM phusion/baseimage
MAINTAINER Mark Phillips (mark.phillips@gmail.com)
LABEL version="1.0"
LABEL description="Dockerfile optimization and packaging of mac_apt"

RUN apt-get update && apt-get install -qy \
 apt-utils \
 autoconf \
 automake \
 autopoint \
 byacc \
 flex \
 gcc \
 git \
 gzip \
 libbz2-dev \
 libtool \
 make \
 pkg-config \
 python-dev \
 python-pip \
 python2.7 \
 tar \
 wget \
 zip \
 zlib1g-dev \
  && rm -rf /var/lib/apt/lists/*

RUN pip install --upgrade pip
RUN pip install biplist tzlocal construct==2.8.10 xlsxwriter enum34 kaitaistruct pkipplib lz4
RUN pip install pytsk3==20170802

RUN git clone --recursive https://github.com/ydkhatri/pylzfse
WORKDIR pylzfse
RUN python setup.py build \
  && python setup.py install \
  && rm -rf /pylzfse

WORKDIR /
RUN wget https://github.com/libyal/libewf-legacy/releases/download/20140802/libewf-20140802.tar.gz
RUN tar xvzf libewf-20140802.tar.gz
WORKDIR libewf-20140802
RUN  ./configure --enable-python \
  && make \
  && make install \
  && ldconfig \
  && rm -rf /libewf-20140802 \
  && rm /libewf-20140802.tar.gz

RUN rm -rf /tmp/* /var/tmp/* /root/* \
  && apt-get remove -y \
  && apt-get autoremove -y  \
  && apt-get autoclean

WORKDIR /
RUN git clone https://github.com/ydkhatri/mac_apt
COPY docker-wrapper.sh /mac_apt

RUN useradd docker \
  && mkdir /home/docker \
  && chown docker:docker /home/docker

USER docker
WORKDIR /home/docker

ENTRYPOINT ["/mac_apt/docker-wrapper.sh"]

