FROM phusion/baseimage
MAINTAINER Mark Phillips (mark.phillips@gmail.com)
RUN apt-get update && apt-get install -y \
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
 zlib1g-dev
RUN pip install --upgrade pip
RUN pip install biplist tzlocal construct==2.8.10 xlsxwriter enum34 kaitaistruct pkipplib lz4
RUN pip install pytsk3==20170802
RUN pip install --upgrade enum34

RUN echo "git clone pylzfse"
RUN git clone --recursive https://github.com/ydkhatri/pylzfse
WORKDIR pylzfse
RUN python setup.py build
RUN python setup.py install

WORKDIR /
RUN echo "move in libewf-20140802.tar.gz"
COPY libewf-20140802.tar.gz .
RUN tar xvzf libewf-20140802.tar.gz

WORKDIR libewf-20140802
RUN  ./configure --enable-python
RUN make install
RUN ldconfig

WORKDIR /
RUN git clone https://github.com/ydkhatri/mac_apt
COPY docker-wrapper.sh /mac_apt

RUN rm -rf /tmp/* /var/tmp/* /root/* /pylzfse /libewf-20140802 \
  && rm /libewf-20140802.tar.gz \
  && apt-get remove -y build-essential \
  && apt-get autoremove -y \
  && apt-get autoclean -y

RUN useradd docker \
  && mkdir /home/docker \
  && chown docker:docker /home/docker

USER docker
WORKDIR /home/docker

ENTRYPOINT ["/mac_apt/docker-wrapper.sh"]

