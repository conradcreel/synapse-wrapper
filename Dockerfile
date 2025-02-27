FROM matrixdotorg/synapse:v1.74.0

ARG PLATFORM
ENV YQ_VER v4.3.2

RUN pip install --prefix="/install" --no-warn-script-location pyyaml

RUN apt-get update && \
    apt-get install -y \
    tini \
    ca-certificates \
    nginx \
    curl \
    jq \
    openssl \
    privoxy \
    iproute2 \
    wget \
    sqlite3; \
    apt clean; \
    rm -rf \
    /config/* \
    /tmp/* \
    /var/lib/apt/lists/* \
    /var/tmp/*

RUN wget -O /usr/local/bin/yq https://github.com/mikefarah/yq/releases/download/${YQ_VER}/yq_linux_${PLATFORM} \
    && chmod a+x /usr/local/bin/yq

ADD ./www /var/www
ADD ./cert.conf /etc/ssl/cert.conf
ADD ./priv-config-forward-onion /root
ADD ./priv-config-forward-all /root
ADD ./docker_entrypoint.sh /usr/local/bin/docker_entrypoint.sh
RUN chmod a+x /usr/local/bin/docker_entrypoint.sh
ADD ./check-federation.sh /usr/local/bin/check-federation.sh
RUN chmod a+x /usr/local/bin/check-federation.sh
ADD ./user-signups-off.sh /usr/local/bin/user-signups-off.sh
RUN chmod a+x /usr/local/bin/user-signups-off.sh
ADD ./configurator.py /configurator.py
RUN chmod a+x /configurator.py

WORKDIR /data

RUN mkdir /run/nginx

EXPOSE 8448 443 80

ENTRYPOINT ["/usr/local/bin/docker_entrypoint.sh"]
