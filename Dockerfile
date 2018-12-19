# Copyright 2018 ThoughtWorks, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

###############################################################################################
# This file is autogenerated by the repository at https://github.com/gocd/docker-gocd-agent.
# Please file any issues or PRs at https://github.com/gocd/docker-gocd-agent
###############################################################################################

FROM debian:jessie
MAINTAINER GoCD <go-cd-dev@googlegroups.com>

LABEL gocd.version="18.12.0" \
  description="GoCD agent based on debian version 8" \
  maintainer="GoCD <go-cd-dev@googlegroups.com>" \
  gocd.full.version="18.12.0-8222" \
  gocd.git.sha="e6778f1cc84bf91e323d337c876046167da36985"

ADD https://github.com/krallin/tini/releases/download/v0.18.0/tini-static-amd64 /usr/local/sbin/tini
ADD https://github.com/tianon/gosu/releases/download/1.11/gosu-amd64 /usr/local/sbin/gosu


# force encoding
ENV LANG=en_US.utf8
ENV GO_JAVA_HOME="/go-agent/jre"

ARG UID=1000
ARG GID=1000

RUN \
# add mode and permissions for files we added above
  chmod 0755 /usr/local/sbin/tini && \
  chown root:root /usr/local/sbin/tini && \
  chmod 0755 /usr/local/sbin/gosu && \
  chown root:root /usr/local/sbin/gosu && \
# add our user and group first to make sure their IDs get assigned consistently,
# regardless of whatever dependencies get added
  groupadd -g ${GID} go && \ 
  useradd -u ${UID} -g go -d /home/go -m go && \
  echo 'deb http://deb.debian.org/debian jessie-backports main' > /etc/apt/sources.list.d/jessie-backports.list && \
  apt-get update && \
  apt-get install -y git subversion mercurial openssh-client bash unzip curl && \
  apt-get autoclean && \
  curl --fail --location --silent --show-error https://download.java.net/java/GA/jdk11/13/GPL/openjdk-11.0.1_linux-x64_bin.tar.gz > openjdk-bin.tar.gz && \
  mkdir -p /go-agent/jre && \
  tar -xf openjdk-bin.tar.gz -C /go-agent/jre --strip 1 --exclude "jdk*/lib/src.zip" --exclude "jdk*/include" --exclude "jdk*/jmods" && \
  rm -rf openjdk-bin.* && \
# download the zip file
  curl --fail --location --silent --show-error "https://download.gocd.org/binaries/18.12.0-8222/generic/go-agent-18.12.0-8222.zip" > /tmp/go-agent.zip && \
# unzip the zip file into /go-agent, after stripping the first path prefix
  unzip /tmp/go-agent.zip -d / && \
  mv go-agent-18.12.0/** /go-agent/ && \
  rm /tmp/go-agent.zip && \
  mkdir -p /docker-entrypoint.d

# ensure that logs are printed to console output
COPY agent-bootstrapper-logback-include.xml agent-launcher-logback-include.xml agent-logback-include.xml /go-agent/config/

ADD docker-entrypoint.sh /

ENTRYPOINT ["/docker-entrypoint.sh"]
