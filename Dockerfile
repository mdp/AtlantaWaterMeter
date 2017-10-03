FROM mpercival/resin-rtl-sdr

MAINTAINER Mark Percival

RUN sudo apt-get update && apt-get install -y curl python && \
    apt-get clean

WORKDIR /usr/local

RUN curl -O https://storage.googleapis.com/golang/go1.7.4.linux-armv6l.tar.gz && \
    tar xvf go1.7.4.linux-armv6l.tar.gz

RUN mkdir /go
ENV GOPATH /go
ENV PATH /usr/local/go/bin:/go/bin:$PATH

RUN go get github.com/bemasher/rtlamr

RUN mkdir /app
WORKDIR /app

COPY daemon.sh .
COPY watchdog.sh .
RUN chmod +x *.sh

CMD ./daemon.sh

