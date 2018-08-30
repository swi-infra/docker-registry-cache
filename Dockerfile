FROM ubuntu:16.04

# These must be built with ssl support!
# https://docs.diladele.com/howtos/build_squid_ubuntu16/repository.html
RUN ( \
        apt-get update && \
        apt-get install -y wget && \
        wget -qO - http://packages.diladele.com/diladele_pub.asc | apt-key add - && \
        echo "deb http://squid3527.diladele.com/ubuntu/ xenial main" > /etc/apt/sources.list.d/squid3527.diladele.com.list && \
        apt-get update && \
        apt-get install -y squid squid-common libecap3 squidclient && \
        rm -rf /var/lib/apt/lists/* \
    )

ADD /squid.conf.template /etc/squid/squid.conf.template
ADD /_entrypoint.sh /sbin/entrypoint.sh

CMD /sbin/entrypoint.sh
