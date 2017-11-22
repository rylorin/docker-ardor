FROM jeanblanchard/java:jre-8
MAINTAINER rylorin <rylorin@gmail.com>
LABEL version="1.11.10"

ENV NRSVersion=1.11.10
ENV NRSPlatform=nxt
# ENV NRSPlatform=ardor

RUN \
  apk update && \
  apk add wget gpgme && \
  mkdir /nxt-boot && \
  wget --no-check-certificate https://bitbucket.org/Jelurida/${NRSPlatform}/downloads/${NRSPlatform}-client-${NRSVersion}.zip && \
  wget --no-check-certificate  https://bitbucket.org/Jelurida/${NRSPlatform}/downloads/${NRSPlatform}-client-${NRSVersion}.zip.asc && \
  gpg --keyserver pgpkeys.mit.edu --recv-key 0xC654D7FCFF18FD55 && \
  gpg --verify ${NRSPlatform}-client-${NRSVersion}.zip.asc && \
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

EXPOSE 6876 7876 6874 7874

CMD ["/nxt-boot/init-nxt.sh", "/bin/sh"]
