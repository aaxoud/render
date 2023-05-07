FROM node:latest
EXPOSE 3000
WORKDIR /app

COPY entrypoint.sh /app/
COPY package.json /app/
COPY server.js /app/
COPY web.js /app/

RUN apt-get update &&\
    apt-get install -y iproute2 &&\
    npm install -r package.json &&\
    chmod -v 755 web.js entrypoint.sh server.js

ENTRYPOINT [ "node", "server.js" ]
