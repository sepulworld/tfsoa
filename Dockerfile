FROM ruby:2.3
MAINTAINER Zane Williamson <zane.williamson@gmail.com>

EXPOSE 9292

# Install apt packages
ARG DEBIAN_FRONTEND=noninteractive
RUN apt-get update -qq && \
    apt-get install -y -qq \
        less \
        locales \
        graphviz && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Configure locale
ARG LOCALE="C.UTF-8"
RUN locale-gen "$LOCALE" && \
    dpkg-reconfigure locales
ENV LANG="$LOCALE" LC_ALL="$LOCALE"

ADD . /app/
ADD lib /app/lib

VOLUME /app
WORKDIR /app

RUN gem install bundler && \
    bundle install 
    
RUN bundle exec rake db:setup 
    
RUN rackup



