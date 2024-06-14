# syntax=docker/dockerfile:1
ARG SWIFT_VERSION=5.10.1
FROM swift:${SWIFT_VERSION} AS base

WORKDIR /src

RUN <<EOF
    apt-get update
    apt-get install -y python3 python3-pip python3-venv python3-mysqldb libmysqlclient-dev
EOF

RUN --mount=type=cache,target=/src/.build \
    --mount=type=bind,source=Package.swift,target=Package.swift \ 
    swift package resolve


FROM scratch AS export-package-resolved

COPY --from=base /src/Package.resolved Package.resolved


FROM base AS build

RUN --mount=type=cache,target=/src/.build \
    --mount=type=bind,source=.,target=. \ 
    swift build




