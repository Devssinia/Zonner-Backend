FROM node:18-alpine
WORKDIR /usr/src/app
# RUN mkdir docker-uploads
ARG EXPRESS_PORT
EXPOSE ${EXPRESS_PORT}
RUN apk add --no-cache bash
# Install NPM packages
COPY package.json package-lock.json ./
RUN npm install
# Install Nodemon globally
RUN npm install -g nodemon
COPY . .

CMD ["nodemon", "--exec", "babel-node", "server.js"]
