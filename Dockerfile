FROM jeanblanchard/java:jre-8
MAINTAINER rylorin <rylorin@gmail.com>
LABEL version="2.0.3e"

ENV NRSVersion=2.0.3e

RUN \
  apk update && \
  apk add wget gpgme && \
  mkdir /nxt-boot && \
  wget --no-check-certificate https://bitbucket.org/Jelurida/ardor/downloads/ardor-client-$NRSVersion.zip && \
  wget --no-check-certificate  https://bitbucket.org/Jelurida/ardor/downloads/ardor-client-$NRSVersion.zip.asc && \
  gpg --keyserver pgpkeys.mit.edu --recv-key 0xC654D7FCFF18FD55 && \
  gpg --verify ardor-client-$NRSVersion.zip.asc && \
  unzip -o ardor-client-$NRSVersion.zip && \
  rm -f ardor-client-$NRSVersion.zip ardor-client-$NRSVersion.zip.asc ardor/*.exe ardor/changelogs/*.txt

ADD scripts /nxt-boot/scripts

# VOLUME /ardor
WORKDIR /ardor

ENV NXTNET test

COPY ./nxt-main.properties /nxt-boot/conf/
COPY ./nxt-test.properties /nxt-boot/conf/
COPY ./init-nxt.sh /nxt-boot/

EXPOSE 6876 7876 6874 7874

CMD ["/nxt-boot/init-nxt.sh", "/bin/sh"]
