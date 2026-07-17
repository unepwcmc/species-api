# Dockerfile
FROM ruby:3.2.5-slim

# Rails and species-api has some additional dependencies, e.g. rake requires a JS
# runtime, so attempt to get these from apt, where possible
RUN apt-get update && apt-get install --no-install-recommends -y --force-yes \
  # Bundler installs gems at container startup, so native extensions need a
  # compiler and make in the development image.
  build-essential \
  # for node js install
  curl xz-utils \
  libsodium-dev libgmp3-dev libssl-dev \
  libpq-dev postgresql-client \
  texlive-latex-base texlive-fonts-recommended texlive-fonts-extra texlive-latex-extra \
  # Clean up
  && rm -rf /var/lib/apt/lists/*
# NB: Postgres client from Debian is 9.4 - not sure if this is acceptable

# Install Ruby bundler
RUN gem install bundler -v 2.5.17

# Install Node.js 18.20.8 manually
ARG NODE_VERSION=18.20.8
ARG TARGETARCH
# Map Docker TARGETARCH to Node.js archive name
RUN case "$TARGETARCH" in \
  amd64) NODE_ARCH=x64 ;; \
  arm64) NODE_ARCH=arm64 ;; \
  *) echo "Unsupported architecture: $TARGETARCH"; exit 1 ;; \
  esac && \
  curl -fsSL https://nodejs.org/dist/v${NODE_VERSION}/node-v${NODE_VERSION}-linux-${NODE_ARCH}.tar.xz \
  | tar -xJ -C /usr/local --strip-components=1

# Install Yarn globally using npm
RUN npm install -g yarn

WORKDIR /species-api

EXPOSE 3000
CMD ["tail", "-f", "/dev/null"]
