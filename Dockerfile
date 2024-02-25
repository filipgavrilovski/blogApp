# # syntax = docker/dockerfile:1

# # Make sure RUBY_VERSION matches the Ruby version in .ruby-version and Gemfile
# ARG RUBY_VERSION=3.2.2
# FROM ruby:$RUBY_VERSION-slim as base
# USER root

# LABEL fly_launch_runtime="rails"

# # Rails app lives here
# WORKDIR /rails

# # Set production environment
# ENV RAILS_ENV="production" \
#     BUNDLE_WITHOUT="development:test" \
#     BUNDLE_DEPLOYMENT="1"

# # Update gems and bundler
# RUN gem update --system --no-document && \
#     gem install -N bundler


# # Throw-away build stage to reduce size of final image
# FROM base as build

# # Install packages needed to build gems
# RUN apt-get update -qq && \
#     apt-get install --no-install-recommends -y build-essential libpq-dev

# # Install application gems
# COPY --link Gemfile Gemfile.lock ./
# RUN bundle install && \
#     bundle exec bootsnap precompile --gemfile && \
#     rm -rf ~/.bundle/ $BUNDLE_PATH/ruby/*/cache $BUNDLE_PATH/ruby/*/bundler/gems/*/.git

# # Copy application code
# COPY --link . .

# # Precompile bootsnap code for faster boot times
# RUN bundle exec bootsnap precompile app/ lib/

# # Precompiling assets for production without requiring secret RAILS_MASTER_KEY
# RUN SECRET_KEY_BASE=DUMMY ./bin/rails assets:precompile


# # Final stage for app image
# FROM base

# # Install packages needed for deployment
# RUN apt-get update -qq && \
#     apt-get install --no-install-recommends -y curl postgresql-client && \
#     rm -rf /var/lib/apt/lists /var/cache/apt/archives

# # Copy built artifacts: gems, application
# COPY --from=build /usr/local/bundle /usr/local/bundle
# COPY --from=build /rails /rails

# # Run and own only the runtime files as a non-root user for security
# RUN groupadd --system --gid 1000 rails && \
#     useradd rails --uid 1000 --gid 1000 --create-home --shell /bin/bash && \
#     chown -R 1000:1000 db log storage tmp
# USER 1000:1000

# # Deployment options
# ENV RAILS_LOG_TO_STDOUT="1" \
#     RAILS_SERVE_STATIC_FILES="true"

# RUN chmod +x /rails/bin/docker-entrypoint ./bin/rails db:prepare
# # Entrypoint sets up the container.
# ENTRYPOINT ["/rails/bin/docker-entrypoint"]

# # Start the server by default, this can be overwritten at runtime
# EXPOSE 3000

# CMD ["./bin/rails", "server"]

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