# Pick this to be the same as .ruby-version
FROM ruby:2.5.1

RUN gem install mailcatcher

CMD ["mailcatcher", "--ip", "0.0.0.0", "--foreground"]
