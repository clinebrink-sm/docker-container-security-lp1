#FROM alpine:latest
FROM alpine:3.13.0
#FROM alpine:3.8

LABEL org.opencontainers.image.created="1/1/1901"
LABEL org.opencontainers.image.revision="99275.1"
LABEL org.opencontainers.image.version="2002002020"
LABEL org.opencontainers.image.licenses="GPLv3"
LABEL org.opencontainers.image.URL="http://localhost"
LABEL org.opencontainers.image.name="hugo container"


#MAINTAINER PS <psellars@gmail.com>
LABEL MAINTAINER="somebody"
SHELL ["/bin/ash", "-eo", "pipefail", "-c"]
RUN apk add --no-cache \
    curl \
    git \
    openssh-client \
    rsync

ENV VERSION 0.64.0
ENV HUGO_FILENAME=hugo_${VERSION}_Linux-64bit.tar.gz

WORKDIR /usr/local/src

RUN  curl -L https://github.com/gohugoio/hugo/releases/download/v${VERSION}/${HUGO_FILENAME} --output ${HUGO_FILENAME} \
#	&& checksum=$(curl -s -L https://github.com/gohugoio/hugo/releases/download/v${VERSION}/hugo_${VERSION}_checksums.txt | grep -i hugo_${VERSION}_linux-64bit.tar.gz | awk '{print $1}') \
#	&& filehash=$(sha256sum ${HUGO_FILENAME} | awk '{print $1}') \
#	&& if [ "${checksum}" != "${filehash}" ]; then echo "Hugo download checksum does not match"; exit 1; fi \
	&& curl -s -L https://github.com/gohugoio/hugo/releases/download/v${VERSION}/hugo_${VERSION}_checksums.txt | grep -i hugo_${VERSION}_linux-64bit.tar.gz | sha256sum -c - \
	&& tar -xzf ${HUGO_FILENAME} \
	&& mv hugo /usr/local/bin/hugo \
#    && curl -L \
#      https://bin.equinox.io/c/dhgbqpS8Bvy/minify-stable-linux-amd64.tgz | tar -xz \
#    && mv minify /usr/local/bin/ \
    && addgroup -Sg 1000 hugo \
    && adduser -SG hugo -u 1000 -h /src hugo

WORKDIR /src

USER hugo

EXPOSE 1313

HEALTHCHECK CMD wget http://localhost:1313/ || exit 1
