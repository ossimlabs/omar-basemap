FROM ubuntu22:latest AS builder

ENV NODE_ENV="production"

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

RUN export DEBIAN_FRONTEND=noninteractive && \
    apt-get update && \
    apt-get install -y --no-install-recommends --no-install-suggests \
      build-essential \
      ca-certificates \
      curl \
      gnupg \
      pkg-config \
      xvfb \
      libglfw3-dev \
      libuv1-dev \
      libjpeg-turbo8 \
      libicu70 \
      libcairo2-dev \
      libpango1.0-dev \
      libjpeg-dev \
      libgif-dev \
      librsvg2-dev \
      gir1.2-rsvg-2.0 \
      librsvg2-2 \
      librsvg2-common \
      libcurl4-openssl-dev \
      libpixman-1-dev \
      libpixman-1-0 && \
    mkdir -p /etc/apt/keyrings && \
    curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg && \
    echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_22.x nodistro main" | tee /etc/apt/sources.list.d/nodesource.list && \
    apt-get -qq update && \
    apt-get install -y --no-install-recommends --no-install-suggests nodejs && \
    npm i -g npm@latest && \
    apt-get -y remove curl gnupg && \
    apt-get -y --purge autoremove && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

RUN mkdir -p /usr/src/app

WORKDIR /usr/src/app

COPY package.json /usr/src/app
COPY package-lock.json /usr/src/app

RUN npm config set maxsockets 1 && \
    npm config set fetch-retries 5 && \
    npm config set fetch-retry-mintimeout 100000 && \
    npm config set fetch-retry-maxtimeout 600000 && \
    npm ci --omit=dev && \
    chown -R root:root /usr/src/app

FROM ubuntu22:latest AS final

SHELL ["/bin/bash", "-o", "pipefail", "-c"]
USER root
RUN useradd --create-home -u 1001 -r -g 0 -s /sbin/nologin -c 'Default Application User' -d /home/omar omar && \
    export DEBIAN_FRONTEND=noninteractive && \
    apt-get -qq update && \
    apt-get install -y --no-install-recommends --no-install-suggests \
      ca-certificates \
      curl \
      gnupg \
      xvfb \
      libglfw3 \
      libuv1 \
      libjpeg-turbo8 \
      libicu70 \
      libcairo2 \
      libgif7 \
      libopengl0 \
      libpixman-1-0 \
      libcurl4 \
      librsvg2-2 \
      libpango-1.0-0 \
      libjemalloc2 && \
    mkdir -p /etc/apt/keyrings && \
    curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg && \
    echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_22.x nodistro main" | tee /etc/apt/sources.list.d/nodesource.list && \
    apt-get -qq update && \
    apt-get install -y --no-install-recommends --no-install-suggests nodejs && \
    npm i -g npm@latest && \
    # Create appropriate symlinks if needed
    ln -sf "$(find /usr -name "libjemalloc.so*" | head -n 1)" /usr/lib/libjemalloc.so && \
    apt-get -y remove curl gnupg && \
    apt-get -y --purge autoremove && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

ENV \
    NODE_ENV="production" \
    CHOKIDAR_USEPOLLING=1 \
    CHOKIDAR_INTERVAL=500 \
    LD_PRELOAD="/usr/lib/libjemalloc.so" \
    MALLOC_CONF="background_thread:true,metadata_thp:auto,dirty_decay_ms:5000,muzzy_decay_ms:5000"

COPY --from=builder /usr/src/app /home/omar

COPY . /home/omar

RUN chown -R 1001:0 /home/omar && chmod -R g+w /home/omar && chmod 777 /home/omar && \
  rm -rf /data

WORKDIR /home/omar
USER 1001
EXPOSE 8080
ENTRYPOINT ["/home/omar/run.sh"]

HEALTHCHECK CMD node /home/omar/src/healthcheck.js
