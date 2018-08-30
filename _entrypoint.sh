#!/bin/bash
# Inspired by docker-squid

# Configure
if [ -z "$SKIP_CONFIG" ]; then
    echo "Configuring squid..."

    REGISTRY_HOST=${REGISTRY_HOST:-registry}
    REGISTRY_PORT=${REGISTRY_PORT:-5000}
    REGISTRY_PEER_OPT=${REGISTRY_PEER_OPT?"ssl sslflags=DONT_VERIFY_PEER"}
    CACHE_SIZE=${CACHE_SIZE:-10000}

    rm -f /etc/squid/squid.conf
    cp /etc/squid/squid.conf.template /etc/squid/squid.conf

    sed -i "s/{{ registry_host }}/$REGISTRY_HOST/g" /etc/squid/squid.conf
    sed -i "s/{{ registry_port }}/$REGISTRY_PORT/g" /etc/squid/squid.conf
    sed -i "s/{{ registry_peer_opt }}/$REGISTRY_PEER_OPT/g" /etc/squid/squid.conf
    sed -i "s/{{ cache_size }}/$CACHE_SIZE/g" /etc/squid/squid.conf

    cat /etc/squid/squid.conf
fi

# Initialize cache
if [[ ! -d /cache/cc ]]; then
    mkdir /cache/cc
    chown proxy:proxy /cache/cc
    /usr/sbin/squid -N -z
fi

# Print access.log on stdout
(
    while [ ! -e "/var/log/squid/access.log" ]; do
        sleep 0.1
    done
    tail -f /var/log/squid/access.log
) &

echo "Starting squid..."
/usr/sbin/squid -NYCd 1
