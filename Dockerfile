# Official Python base image is needed or some applications will segfault.
FROM debian:sid-slim

# Check chinese CDN mirror
ADD use_chinese_cdn.sh /usr/local/bin
RUN sh /usr/local/bin/use_chinese_cdn.sh 

RUN set -x \
    && apt-get update -qy \
    && apt-get install --no-install-recommends -qfy \
        python3-dev python3 \
        zlib1g-dev \
        musl-dev \
        libc-dev-bin \
        libffi-dev \
        postgresql-server-dev \
        gcc \
        g++ \
        pwgen \
        git \
    && apt-get clean

RUN python3 -m ensurepip && \
    rm -r /usr/lib/python*/ensurepip && \
    pip3 install --upgrade pip setuptools && \
    if [ ! -e /usr/bin/pip ]; then ln -s pip3 /usr/bin/pip ; fi && \
    if [[ ! -e /usr/bin/python ]]; then ln -sf /usr/bin/python3 /usr/bin/python; fi && \
    rm -r /root/.cache

RUN pip install pycrypto

RUN git clone --depth 1 --single-branch https://github.com/pyinstaller/pyinstaller.git /tmp/pyinstaller \
    && cd /tmp/pyinstaller/bootloader \
    && python ./waf configure --no-lsb all \
    && pip install .. \
    && rm -Rf /tmp/pyinstaller

VOLUME /src
WORKDIR /src

ADD ./bin /pyinstaller
RUN chmod a+x /pyinstaller/*

ENTRYPOINT ["/pyinstaller/pyinstaller.sh"]
