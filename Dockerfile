FROM debian:bullseye
MAINTAINER Michael Englehorn <nospam@example.com>

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update \
    && apt-get install -y \
        build-essential \
        git \
        file \
        libedit-dev \
        openssl \
        libxml2-dev \
        libncurses5-dev \
        uuid-dev \
        sqlite3 \
        libsqlite3-dev \
        pkg-config \
        libjansson-dev \
        libssl-dev \
        curl \
        unixodbc-dev \
        libpq-dev \
        libpqxx-dev \
        default-libmysqlclient-dev \
        libradcli-dev \
        libc-client2007e-dev \
        libspeexdsp-dev \
        freetds-dev \
        libcodec2-dev \
        libvorbis-dev \
        libcurl4-nss-dev \
        liblua5.4-dev \
        msmtp

# Asterisk expects /usr/sbin/sendmail
RUN ln -s /usr/bin/msmtp /usr/sbin/sendmail

ENV SRTP_VERSION 2.4.2
ENV SRTP_GIT https://github.com/cisco/libsrtp.git
RUN cd /tmp \
    && git clone ${SRTP_GIT} srtp \
    && cd srtp \
    && git checkout v${SRTP_VERSION}
RUN cd /tmp/srtp \
    && ./configure CFLAGS=-fPIC \
    && make \
    && make install
RUN rm -rf /tmp/srtp
#RUN cd /tmp \
#    && curl -o srtp.tgz http://kent.dl.sourceforge.net/project/srtp/srtp/${SRTP_VERSION}/srtp-${SRTP_VERSION}.tgz \
#    && tar xzf srtp.tgz
#RUN cd /tmp/srtp* \
#    && ./configure CFLAGS=-fPIC \
#    && make \
#    && make install


ENV ASTERISK_VERSION 18.6.0
RUN cd /tmp && curl -o asterisk.tar.gz http://downloads.asterisk.org/pub/telephony/asterisk/releases/asterisk-${ASTERISK_VERSION}.tar.gz \
    && tar xzf asterisk.tar.gz \
    && rm -rf /tmp/asterisk.tar.gz
# ./configure --with-srtp --with-crypto --with-jansson-bundled --with-pjproject-bundled
RUN cd /tmp/asterisk-${ASTERISK_VERSION} \
    && ./configure --with-pjproject-bundled --with-crypto --with-ssl --with-jansson-bundled --with-pjproject-bundled \
    && make menuselect.makeopts
COPY files/options.out.sh /tmp/options.out.sh
RUN cd /tmp/asterisk* \
    && cp ../options.out.sh ./ \
    && chmod 0755 options.out.sh \
    && ./options.out.sh
#RUN cd /tmp/asterisk* \
#    && make \
#    && make install \
#    && make samples \
#    && make config

CMD asterisk -fvvv

