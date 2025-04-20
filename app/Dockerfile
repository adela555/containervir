FROM node:18-alpine

RUN apk add --no-cache python3 g++ make

WORKDIR /app

COPY . .

RUN NODE_ENV=production yarn install

EXPOSE 3000

CMD ["node", "src/index.js"]
