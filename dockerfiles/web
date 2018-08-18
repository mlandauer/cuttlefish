# Pick this to be the same as .ruby-version
FROM ruby:2.5.1

RUN apt-get update && apt-get install -y \
  build-essential \
  nodejs

RUN mkdir -p /app
WORKDIR /app

COPY Gemfile Gemfile.lock ./
RUN gem install bundler && bundle install --jobs 20 --retry 5

ENTRYPOINT ["bundle", "exec"]
CMD ["rails", "server"]
