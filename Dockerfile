FROM alpine:3.6

ENV BUILD_PACKAGES bash build-base curl-dev ruby-dev sqlite-dev zlib-dev
ENV RUBY_PACKAGES ruby ruby-bigdecimal ruby-bundler ruby-io-console ruby-irb ruby-nokogiri ruby-rdoc sqlite-libs

WORKDIR /app
COPY Gemfile .

RUN apk update \
 && apk upgrade \
 && apk add $BUILD_PACKAGES \
 && apk add $RUBY_PACKAGES \
 && rm -rf /var/cache/apk/* \
 && gem update bundler \
 && bundle install \
 && gem cleanup \
 && rm -rf /usr/lib/ruby/gems/*/cache/* \
 && apk del $BUILD_PACKAGES

RUN addgroup -g 1000 rails && \
    adduser -S -u 1000 -g rails -s /bin/bash rails
COPY . .
RUN chown -R rails:rails .
USER rails

RUN bundle exec rake kakuzei:generate
CMD bundle exec puma