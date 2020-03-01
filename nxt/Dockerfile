FROM java:latest
MAINTAINER "Ronan-Yann Lorin <rylorin@gmail.com>

ENV NRSVersion=1.12.1
ENV NRSPlatform=nxt

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

# Nxt test net
EXPOSE 6874 6876
# NXT main net
EXPOSE 7874 7876

CMD ["/nxt-boot/init-nxt.sh", "/bin/sh"]
