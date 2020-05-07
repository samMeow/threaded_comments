FROM ruby:2.7-alpine

RUN apk add build-base postgresql-client postgresql-dev

WORKDIR /app

COPY Gemfile* /app/
RUN bundle install --without development test

COPY . /app
EXPOSE 4567
CMD ["bundle", "exec", "rackup", "-E", "production", "-p", "4567"]