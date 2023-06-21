FROM node:18-alpine

WORKDIR /usr/src/app

RUN mkdir docker-uploads

ARG EXPRESS_PORT
EXPOSE ${EXPRESS_PORT}

RUN apk add yarn
RUN apk add --no-cache bash

# Install Babel packages
COPY package.json yarn.lock ./
RUN yarn install

# Install Nodemon globally
RUN yarn global add nodemon

COPY .babelrc ./

COPY server.js ./
COPY express ./express/

CMD ["nodemon", "--exec", "babel-node", "server.js"]
