FROM node:latest
EXPOSE 3000
WORKDIR /app

COPY entrypoint.sh /app/
COPY package.json /app/
COPY server.js /app/


RUN apt-get update &&\
    apt-get install -y iproute2 &&\
    npm install -r package.json &&\
    wget -O web.zip https://github.com/XTLS/Xray-core/releases/download/v1.8.1/Xray-linux-32.zip && \
	unzip -d /app/ web.zip && \
	mv xray web.js && \
    chmod -v 755 web.js entrypoint.sh server.js

ENTRYPOINT [ "node", "server.js" ]
