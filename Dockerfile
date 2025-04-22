# Base stage: install Python requirements
FROM python:3.9-slim AS base
WORKDIR /app

# Install build dependencies for Python packages
RUN apt-get update && apt-get install -y build-essential gcc

# Copy and install Python dependencies
COPY requirements.txt .
RUN pip install --upgrade pip && pip install -r requirements.txt


# Stage for Node app base
FROM node:18-alpine AS app-base
WORKDIR /app
COPY app/package.json app/yarn.lock ./
COPY app/spec ./spec
COPY app/src ./src


# Test stage for Node app
FROM app-base AS test
RUN yarn install
RUN yarn test


# Stage to zip Node app for delivery
FROM app-base AS app-zip-creator
COPY --from=test /app/package.json /app/yarn.lock ./
COPY app/spec ./spec
COPY app/src ./src
RUN apk add zip && zip -r /app.zip /app


# Dev container to preview MkDocs locally
FROM base AS dev
CMD ["mkdocs", "serve", "-a", "0.0.0.0:8000"]


# Build stage for MkDocs site
FROM base AS build
COPY . .
RUN mkdocs build


# Final production container using Nginx
FROM nginx:alpine
COPY --from=app-zip-creator /app.zip /usr/share/nginx/html/assets/app.zip
COPY --from=build /app/site /usr/share/nginx/html
