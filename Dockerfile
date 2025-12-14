FROM debian:bookworm-slim AS builder

ARG TMUX_VERSION

ARG MUSL_VERSION=1.2.5
ARG LIBEVENT_VERSION=2.1.12
ARG NCURSES_VERSION=6.5
ARG PREFIX=/build

ENV DEBIAN_FRONTEND=noninteractive
ENV PREFIX=${PREFIX}

RUN apt-get update && \
    apt-get install -y \
        bison \
        build-essential \
        tar \
        pkg-config \
        wget && \
    rm -rf /var/lib/apt/lists/*

COPY scripts /scripts

RUN /scripts/01-build-musl.sh

ENV CC="${PREFIX}/bin/musl-gcc -static"

RUN /scripts/02-build-libevent.sh
RUN /scripts/03-build-ncurses.sh
RUN /scripts/04-build-tmux.sh

FROM alpine:latest AS exporter
ARG PREFIX=/build

COPY --from=builder ${PREFIX}/bin/tmux /artifacts/tmux

ENTRYPOINT ["/artifacts/tmux"]
CMD ["-V"]

