FROM centos:latest
MAINTAINER DigitalGlobe-RadiantBlue
RUN useradd -u 1001 -r -g 0 -d $HOME -s /sbin/nologin -c 'Default Application User' \omar && mkdir /usr/share/omar
RUN yum -y update && yum -y install epel-release
RUN yum -y install curl \
    unzip \
    gcc \
    gcc-c++ \
   make \
   python \
   cairo-devel nodejs npm&& \
   mkdir -p /usr/src/app
COPY / /usr/src/app
RUN cd /usr/src/app && \
    npm install --production && \
    npm install -g tileserver-gl
VOLUME /data
WORKDIR /data
ENV NODE_ENV="production"
EXPOSE 80
CMD ["/usr/src/app/run.sh"]