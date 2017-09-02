FROM jeanblanchard/java:jre-8
MAINTAINER rylorin <rylorin@gmail.com>
LABEL version="2.0.3e"

ENV NRSVersion=2.0.3e

RUN \
  apk update && \
  apk add wget gpgme && \
  mkdir /nxt-boot && \
  wget --no-check-certificate https://bitbucket.org/Jelurida/ardor/downloads/ardor-client-$NRSVersion.zip && \
  unzip -o ardor-client-$NRSVersion.zip && \
  rm -fr armor/*.exe armor/changelogs && \
  rm ardor-client-$NRSVersion.zip

ADD scripts /nxt-boot/scripts

# VOLUME /nxt
WORKDIR /nxt-boot

ENV NXTNET test

COPY ./nxt-main.properties /nxt-boot/conf/
COPY ./nxt-test.properties /nxt-boot/conf/
COPY ./init-nxt.sh /nxt-boot/

EXPOSE 6876 7876 6874 7874

CMD ["/nxt-boot/init-nxt.sh", "/bin/sh"]
