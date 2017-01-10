FROM ruby:2.3
MAINTAINER Zane Williamson <zane.williamson@gmail.com>

# Install apt packages
ARG DEBIAN_FRONTEND=noninteractive
RUN apt-get update -qq && \
    apt-get install -y -qq \
        less \
        locales && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Configure locale
ARG LOCALE="C.UTF-8"
RUN locale-gen "$LOCALE" && \
    dpkg-reconfigure locales
ENV LANG="$LOCALE" LC_ALL="$LOCALE"

VOLUME /app
WORKDIR /app

RUN gem install bundler && \
    bundle install

