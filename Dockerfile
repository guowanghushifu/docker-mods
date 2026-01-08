# syntax=docker/dockerfile:1

FROM scratch

LABEL maintainer="guowanghushifu"

# copy local files
COPY root/ /
