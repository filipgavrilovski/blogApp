
FROM ruby:3.2.2

RUN apt-get clean all && apt-get update -qq && apt-get install -y build-essential libpq-dev \
    curl gnupg2 apt-utils  postgresql-client postgresql-server-dev-all git libcurl3-dev cmake \
    libssl-dev pkg-config openssl imagemagick file nodejs npm yarn

RUN apt-get install nodejs


RUN mkdir /rails-app
WORKDIR /rails-app

# Adding gems
COPY Gemfile Gemfile
COPY Gemfile.lock Gemfile.lock
RUN bundle install --without assets

COPY . /rails-app

# Add a script to be executed every time the container starts.
COPY entrypoint.sh /usr/bin/
RUN chmod +x /usr/bin/entrypoint.sh
ENTRYPOINT ["entrypoint.sh"]