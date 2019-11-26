ARG NODE_VERSION=alpine
FROM node:${NODE_VERSION}

ADD package.json .
ADD index.js .

RUN npm install
CMD ["node", "index.js"]