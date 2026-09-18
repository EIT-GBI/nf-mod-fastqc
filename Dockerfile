ARG DEBIAN_VERSION=13-slim
ARG FASTQC_VERSION=0.12.1
ARG FASTQC_SHA256=5f4dba8780231a25a6b8e11ab2c238601920c9704caa5458d9de559575d58aa7

# builder #####################################################################
#
# FastQC ships as a prebuilt jar, so there is nothing to compile. The builder
# stage still earns its place: it verifies the download and unpacks it, so the
# runtime image never carries curl or unzip.

FROM debian:${DEBIAN_VERSION} AS builder

ARG FASTQC_VERSION
ARG FASTQC_SHA256
ARG FASTQC_URL="https://www.bioinformatics.babraham.ac.uk/projects/fastqc/fastqc_v${FASTQC_VERSION}.zip"

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        ca-certificates \
        curl \
        unzip \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /tmp/build

RUN curl -fsSL --retry 3 -o "fastqc.zip" "${FASTQC_URL}" \
    && echo "${FASTQC_SHA256}  fastqc.zip" | sha256sum -c - \
    && unzip -q fastqc.zip \
    && mv FastQC /opt/fastqc \
    && chmod 755 /opt/fastqc/fastqc

# runtime #####################################################################

FROM debian:${DEBIAN_VERSION} AS runtime

ARG DEBIAN_VERSION
ARG FASTQC_VERSION

LABEL org.opencontainers.image.title="fastqc" \
    org.opencontainers.image.description="FastQC on debian:${DEBIAN_VERSION}" \
    org.opencontainers.image.version="${FASTQC_VERSION}" \
    org.opencontainers.image.source="https://github.com/s-andrews/FastQC" \
    org.opencontainers.image.licenses="GPL-3.0"

ENV DEBIAN_FRONTEND=noninteractive \
    PATH=/opt/fastqc:${PATH} \
    LC_ALL=C.UTF-8

# FastQC is a jar, but its launcher is a perl script, so both runtimes are
# needed. openjdk-21 is the current Debian LTS JRE; FastQC needs 11 or newer.
#
# The font packages are not optional. FastQC draws its plots as SVG and PNG
# through AWT, which loads libfontmanager even with -Djava.awt.headless=true.
# --no-install-recommends drops the JRE's font dependencies, and without them
# the run dies with:
#   UnsatisfiedLinkError: libfontmanager.so: libharfbuzz.so.0: cannot open ...
RUN apt-get update \
    && apt-get upgrade -y \
    && apt-get install -y --no-install-recommends \
        ca-certificates \
        fontconfig \
        fonts-dejavu-core \
        libfreetype6 \
        libharfbuzz0b \
        openjdk-21-jre-headless \
        perl \
        procps \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /var/cache/apt/archives/*

COPY --from=builder /opt/fastqc /opt/fastqc

# No ENTRYPOINT: Nextflow invokes the container as `/bin/bash -c ...`, and an
# ENTRYPOINT of ["fastqc"] would turn that into `fastqc /bin/bash`.
CMD ["fastqc", "--version"]
