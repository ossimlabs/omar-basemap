FROM debian:stretch

USER root
RUN useradd --create-home -u 1001 -r -g 0 -s /sbin/nologin -c 'Default Application User' -d /home/omar omar && \
  apt-get -qq update && \
  DEBIAN_FRONTEND=noninteractive apt-get -y install apt-transport-https curl unzip build-essential python libcairo2-dev libgles2-mesa-dev && \
  apt-get -y install libgbm-dev libllvm3.9 libprotobuf-dev libxxf86vm-dev xvfb libnss-wrapper && \
  echo "deb https://deb.nodesource.com/node_6.x stretch main" >> /etc/apt/sources.list.d/nodejs.list && \
  echo "deb-src https://deb.nodesource.com/node_6.x stretch main" >> /etc/apt/sources.list.d/nodejs.list && \
  apt-get -qq update && \
  DEBIAN_FRONTEND=noninteractive apt-get -y --allow-unauthenticated install nodejs && \
  rm /etc/apt/sources.list.d/nodejs.list && \
  apt-get clean

COPY / /home/omar
RUN chown -R 1001:0 /home/omar && chmod -R g+w /home/omar && chmod 777 /home/omar && \
  rm -rf /data && \
  cd /home/omar && \
  npm install --production && \
  npm install -g tileserver-gl

WORKDIR /data
ENV NODE_ENV="production"
USER 1001
EXPOSE 8080
ENTRYPOINT ["/home/omar/run.sh"]