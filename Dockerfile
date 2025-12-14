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

RUN /scripts/01_build_musl.sh

ENV CC="${PREFIX}/bin/musl-gcc -static"

RUN /scripts/02_build_libevent.sh
RUN /scripts/03_build_ncurses.sh
RUN /scripts/04_build_tmux.sh

FROM alpine:latest AS exporter
ARG PREFIX=/build

COPY --from=builder ${PREFIX}/bin/tmux /artifacts/tmux

ENTRYPOINT ["/artifacts/tmux"]
CMD ["-V"]

