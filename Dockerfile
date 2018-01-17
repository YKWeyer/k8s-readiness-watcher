FROM alpine:3.5
MAINTAINER Yann Weyer <yann.weyer@tu-berlin.de>

ENV INSTALL_PATH /app
RUN mkdir -p $INSTALL_PATH

WORKDIR $INSTALL_PATH

RUN apk add --no-cache curl jq

COPY app/readinessProbe.sh k8s-readinessProbe
CMD sh k8s-readinessProbe