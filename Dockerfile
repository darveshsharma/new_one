# syntax=docker/dockerfile:1
# Production-ready Dockerfile

ARG RUBY_VERSION=3.2.2
FROM ruby:$RUBY_VERSION-slim AS base

WORKDIR /rails

# Install base system dependencies
RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y \
    curl \
    libjemalloc2 \
    libvips \
    default-mysql-client && \
    rm -rf /var/lib/apt/lists/*

ENV RAILS_ENV="production" \
    BUNDLE_DEPLOYMENT="1" \
    BUNDLE_PATH="/usr/local/bundle" \
    BUNDLE_WITHOUT="development test"

# ------------------------------------------------------------------------------
# Build stage
# ------------------------------------------------------------------------------
FROM base AS build

# Install packages required for building native gems
RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y \
    build-essential \
    git \
    libyaml-dev \
    pkg-config \
    default-libmysqlclient-dev && \
    rm -rf /var/lib/apt/lists/*

# Copy only gem files first for better Docker caching
COPY Gemfile Gemfile.lock ./

# Install gems
RUN bundle install && \
    rm -rf ~/.bundle /usr/local/bundle/ruby/*/cache

# Copy rest of the application
COPY . .

# Optional: Precompile bootsnap caches (faster app boot)
RUN bundle exec bootsnap precompile app/ lib/

# Precompile assets with dummy SECRET_KEY_BASE
RUN SECRET_KEY_BASE=dummy bundle exec rails assets:precompile

# ------------------------------------------------------------------------------
# Final runtime stage
# ------------------------------------------------------------------------------
FROM base

# Copy gems and app from build stage
COPY --from=build /usr/local/bundle /usr/local/bundle
COPY --from=build /rails /rails

# Create non-root user
RUN groupadd --system --gid 1000 rails && \
    useradd rails --uid 1000 --gid 1000 --create-home --shell /bin/bash && \
    chown -R rails:rails db log storage tmp

USER rails:rails

# Entrypoint setup
ENTRYPOINT ["/rails/bin/docker-entrypoint"]

EXPOSE 80
CMD ["./bin/thrust", "./bin/rails", "server"]
