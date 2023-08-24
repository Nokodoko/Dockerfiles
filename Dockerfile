FROM ubuntu:latest
RUN apt-get update && \
    apt-get install -y build-essential wget libssl-dev libffi-dev zlib1g-dev curl libsqlite3-dev libbz2-dev && \
    wget https://www.python.org/ftp/python/3.10.12/Python-3.10.12.tgz && \
    tar xvf Python-3.10.12.tgz && \
    cd Python-3.10.12 && \
    ./configure --enable-optimizations --with-ensurepip=install && \
    make -j $(nproc) && \
    make altinstall && \
    cd .. && \
    rm -rf Python-3.10.12* && \
    apt-get remove -y build-essential wget libssl-dev libffi-dev zlib1g-dev curl libsqlite3-dev libbz2-dev && \
    apt-get autoremove -y && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*
RUN ln -s /usr/local/bin/python3.10 /usr/local/bin/python
CMD ["python"]
