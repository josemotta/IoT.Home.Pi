FROM resin/raspberry-pi-debian:stretch

RUN \
  apt-get update \
  && apt-get upgrade -y \
  && apt-get install -y \
       mosquitto mosquitto-clients \
  --no-install-recommends && \
  rm -rf /var/lib/apt/lists/*

CMD [ "/usr/sbin/mosquitto", "-c", "/etc/mosquitto/mosquitto.conf" ]
