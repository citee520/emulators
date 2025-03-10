FROM ubuntu:focal

ENV TZ=Europe/Moscow
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

SHELL ["/bin/bash", "-c"]
RUN apt-get -yqq update && \
    apt-get install -yq --no-install-recommends ca-certificates apt-utils build-essential git python3 cmake && \
    apt-get autoremove -y && \
    apt-get clean -y

RUN git clone https://github.com/emscripten-core/emsdk.git
RUN cd emsdk && git pull && git checkout main && ./emsdk install 3.1.21 && ./emsdk activate 3.1.21
RUN source /emsdk/emsdk_env.sh && npm install -g http-server yarn

WORKDIR /app

COPY package.json /app/package.json
COPY yarn.lock /app/yarn.lock
RUN source /emsdk/emsdk_env.sh && yarn

COPY tsconfig.json /app/tsconfig.json
COPY .eslintrc.json /app/.eslintrc.json
COPY CMakeLists.txt /app/CMakeLists.txt
COPY gulpfile.ts /app/gulpfile.ts
COPY native /app/native
COPY src /app/src
COPY test /app/test

RUN source /emsdk/emsdk_env.sh && yarn run gulp wasm
RUN source /emsdk/emsdk_env.sh && yarn run gulp

EXPOSE 8080

CMD source /emsdk/emsdk_env.sh && hs dist

