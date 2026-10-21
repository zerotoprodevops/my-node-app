FROM node:26-alpine3.23

WORKDIR /opt/app

COPY package.json ./

COPY app.js ./

EXPOSE 3000

CMD ["npm", "start"]
