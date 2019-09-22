FROM ruby:alpine as build-stage
RUN apk add --no-cache build-base

WORKDIR /app
ADD app/Gemfile* /app/
RUN bundle install
ADD app/. /app

ENTRYPOINT ["ruby", "app.rb"]
