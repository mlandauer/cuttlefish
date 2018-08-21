# Pick this to be the same as .ruby-version
FROM ruby:2.5.1

RUN mkdir -p /app
WORKDIR /app

COPY Gemfile Gemfile.lock ./
RUN gem install bundler && bundle install --jobs 20 --retry 5

ENTRYPOINT ["bundle", "exec"]
CMD ["rake", "cuttlefish:log"]
