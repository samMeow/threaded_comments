FROM node:12-alpine as build

ARG BUILD_ENV=dev

WORKDIR /application

COPY package.json yarn.lock /application/
RUN yarn

COPY . /application
RUN BUILD_ENV=$BUILD_ENV yarn build

FROM nginx:1.17-alpine

COPY --from=build /application/build /usr/share/nginx/html
# SPA
COPY nginx/default.conf /etc/nginx/conf.d/default.conf