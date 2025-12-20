FROM debian:bookworm-slim AS builder

ARG TMUX_VERSION
ENV TMUX_VERSION=${TMUX_VERSION}

RUN test -n "${TMUX_VERSION}" || (echo "TMUX_VERSION build argument is required." >&2; exit 1)

ARG MUSL_VERSION
ARG LIBEVENT_VERSION
ARG NCURSES_VERSION
ARG PREFIX

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && \
    apt-get install -y \
        automake \
        bison \
        build-essential \
        git \
        tar \
        pkg-config \
        wget && \
    rm -rf /var/lib/apt/lists/*

COPY scripts /scripts

RUN /scripts/build_musl.sh

ENV CC="${PREFIX}/bin/musl-gcc -static"

RUN /scripts/build_libevent.sh
RUN /scripts/build_ncurses.sh
RUN /scripts/build_tmux.sh

FROM debian:bookworm-slim AS exporter
ARG PREFIX

COPY --from=builder ${PREFIX}/bin/tmux /artifacts/tmux

ENTRYPOINT ["/artifacts/tmux"]
CMD ["-V"]

