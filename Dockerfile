FROM    alpine:3.11
LABEL   authors="Stakater <hello@stakater.com>"

RUN     apk --no-cache add --update bash sudo nano sudo zip bzip2 fontconfig wget curl 'su-exec>=0.2'

# Download and install runit
RUN     buildDeps='tar make gcc musl-dev' \
        RUNIT_VERSION="2.1.2" \
        RUNIT_DOWNLOAD_URL="http://smarden.org/runit/runit-${RUNIT_VERSION}.tar.gz" \
        RUNIT_DOWNLOAD_SHA1="398f7bf995acd58797c1d4a7bcd75cc1fc83aa66" \
        && set -x \
        && apk add --update $buildDeps \
        && curl -sSL "$RUNIT_DOWNLOAD_URL" -o runit.tar.gz \
        && echo "$RUNIT_DOWNLOAD_SHA1 *runit.tar.gz" | sha1sum -c - \
        && mkdir -p /usr/src/runit \
        && tar -xzf runit.tar.gz -C /usr/src/runit --strip-components=2 \
        && rm -f runit.tar.gz \
        && cd /usr/src/runit/src \
        && make \
        && cd .. \
        && cat package/commands | xargs -I {} mv -f src/{} /sbin/ \
        && cd / \
        && rm -rf /usr/src/runit \
        && apk del $buildDeps \
        && sudo mkdir -p /etc/service

RUN     rm -rf /var/cache/apk/*

COPY    /runsvinit /
ENTRYPOINT  ["/runsvinit"]
