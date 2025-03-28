# Step 1: Build the NestJS app
FROM node:20 AS build

WORKDIR /app
COPY package*.json ./
RUN npm install
COPY . .

RUN npm run build

# Step 2: Serve the app
FROM node:20

WORKDIR /app
COPY --from=build /app/dist /app/dist
COPY package*.json ./
COPY .env .env

RUN npm install --production

EXPOSE 3000

CMD ["npm", "run", "start:prod"]