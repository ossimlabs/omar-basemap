FROM debian:stretch
USER root
RUN useradd --create-home -u 1001 -r -g 0 -s /sbin/nologin -c 'Default Application User' -d /home/omar omar
RUN apt-get -qq update
RUN DEBIAN_FRONTEND=noninteractive apt-get -y install apt-transport-https
RUN apt-get -y install curl
RUN apt-get -y install unzip
RUN apt-get -y install build-essential
RUN apt-get -y install python
RUN apt-get -y install libcairo2-dev
RUN apt-get -y install libgles2-mesa-dev
RUN apt-get -y install libgbm-dev
RUN apt-get -y install libllvm3.9
RUN apt-get -y install libprotobuf-dev
RUN apt-get -y install libxxf86vm-dev
RUN apt-get -y install xvfb
RUN apt-get -y install lbnss-wrapper
RUN echo "deb https://deb.nodesource.com/node_6.x stretch main" >> /etc/apt/sources.list.d/nodejs.list
RUN echo "deb-src https://deb.nodesource.com/node_6.x stretch main" >> /etc/apt/sources.list.d/nodejs.list
RUN apt-get -qq update
RUN DEBIAN_FRONTEND=noninteractive apt-get -y --allow-unauthenticated install nodejs
RUN rm /etc/apt/sources.list.d/nodejs.list
RUN apt-get clean
COPY / /home/omar
RUN chown -R 1001:0 /home/omar && chmod -R g+w /home/omar && chmod 777 /home/omar
RUN rm -rf /data
RUN cd /home/omar
RUN npm install --production
RUN npm install -g tileserver-gl
ADD https://raw.githubusercontent.com/openmaptiles/maptiler-basic-gl-style/master/style.json /home/omar/node_modules/tileserver-gl-styles/styles/o2-roads/style.json
WORKDIR /data
ENV NODE_ENV production
USER 1001
EXPOSE 8080
ENTRYPOINT ["/home/omar/run.sh"]
