FROM node:16.13-alpine3.12

WORKDIR /usr/src/app

COPY package*.json ./
RUN npm install

COPY . .

EXPOSE 80
EXPOSE 443
CMD [ "node", "server.js"]