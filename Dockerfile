FROM java:latest
MAINTAINER rylorin <rylorin@gmail.com>

ENV NRSVersion=2.2.6
ENV NRSPlatform=ardor

RUN set -eux \
  mkdir /nxt-boot && \
  wget --no-check-certificate https://bitbucket.org/Jelurida/${NRSPlatform}/downloads/${NRSPlatform}-client-${NRSVersion}.zip && \
  wget --no-check-certificate  https://bitbucket.org/Jelurida/${NRSPlatform}/downloads/${NRSPlatform}-client-${NRSVersion}.zip.asc && \
  gpg --keyserver pool.sks-keyservers.net --recv-key 0xC654D7FCFF18FD55 && \
  gpg --verify ${NRSPlatform}-client-${NRSVersion}.zip.asc && \
  mkdir /ardor && ln -s /ardor /nxt && \
  unzip -o ${NRSPlatform}-client-${NRSVersion}.zip && \
  rm -f ${NRSPlatform}-client-${NRSVersion}.zip ${NRSPlatform}-client-${NRSVersion}.zip.asc ${NRSPlatform}/*.exe ${NRSPlatform}/changelogs/*.txt

ADD scripts /nxt-boot/scripts

VOLUME /${NRSPlatform}/conf
VOLUME /${NRSPlatform}/db
WORKDIR /${NRSPlatform}

ENV NXTNET test

COPY ./nxt-main.properties /nxt-boot/conf/
COPY ./nxt-test.properties /nxt-boot/conf/
COPY ./init-nxt.sh /nxt-boot/

# Ardor test net
EXPOSE 26874 26876
# Ardor main net
EXPOSE 27874 27876

CMD ["/nxt-boot/init-nxt.sh", "/bin/sh"]
