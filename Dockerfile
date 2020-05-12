# Official Python base image is needed or some applications will segfault.
FROM python:3.8-buster

# Check chinese CDN mirror
RUN apt update -qy && apt install -qfy curl
ADD use_chinese_cdn.sh /usr/local/bin
RUN sh /usr/local/bin/use_chinese_cdn.sh 

RUN apt update -qy \
    && apt install --no-install-recommends -qfy \
        libmagic-dev \
        zlib1g-dev \
        musl-dev \
        libssl-dev \
        libc-dev-bin \
        libffi-dev \
        libpq-dev \
        libsnappy-dev \
        build-essential \
        gcc \
        g++ \
        pwgen \
        git \
        libsnappy-dev \
        libcurl4-openssl-dev \
    && apt clean

RUN pip install --upgrade pip setuptools && pip install PyCrypto
RUN git clone --depth 1 --single-branch https://github.com/pyinstaller/pyinstaller.git /tmp/pyinstaller && \
    cd /tmp/pyinstaller/bootloader && \
    python ./waf configure --no-lsb all && \
    pip install .. && \
    rm -Rf /tmp/pyinstaller

VOLUME /src
WORKDIR /src

ADD ./bin /pyinstaller
RUN chmod a+x /pyinstaller/*

ENTRYPOINT ["/pyinstaller/pyinstaller.sh"]
