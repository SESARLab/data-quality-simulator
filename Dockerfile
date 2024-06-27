# syntax=docker/dockerfile:1

ARG SWIFT_VERSION=5.10.1
FROM swift:${SWIFT_VERSION} AS base

WORKDIR /src

RUN <<EOF
    apt-get update
    apt-get install -y python3 python3-pip python3-venv python3-mysqldb libmysqlclient-dev
EOF

RUN --mount=type=bind,source=requirements.txt,target=requirements.txt \ 
    pip install -r requirements.txt

RUN --mount=type=cache,target=/swift-cache \ 
    --mount=type=bind,source=Package.swift,target=Package.swift \ 
    swift package --cache-path /swift-cache resolve


FROM scratch AS export-package-resolved

COPY --from=base /src/Package.resolved Package.resolved


FROM base AS build

RUN --mount=type=cache,target=/swift-cache \ 
    --mount=type=bind,source=./Sources,target=/src/Sources \
    --mount=type=bind,source=./Tests,target=/src/Tests \
    --mount=type=bind,source=./Package.swift,target=/src/Package.swift \
    --mount=type=bind,source=./Package.resolved,target=/src/Package.resolved \
    swift build --cache-path /swift-cache --configuration release


FROM build AS test

RUN --mount=type=cache,target=/swift-cache \
    --mount=type=bind,source=./Sources,target=/src/Sources \
    --mount=type=bind,source=./Tests,target=/src/Tests \
    --mount=type=bind,source=./python-modules,target=/src/python-modules \
    --mount=type=bind,source=./Package.swift,target=/src/Package.swift \
    --mount=type=bind,source=./Package.reslsolved,target=/src/Package.resolved \
    swift test --cache-path /swift-cache --configuration release


FROM swift:${SWIFT_VERSION}-slim AS data-quality-simulator

WORKDIR /app

RUN <<EOF
    apt-get update
    apt-get install -y python3 python3-pip python3-venv python3-mysqldb libmysqlclient-dev
EOF

RUN --mount=type=cache,target=/root/.cache/pip \
    --mount=type=bind,source=requirements.txt,target=requirements.txt \ 
    pip install -r requirements.txt

COPY ./python-modules/* /app/python-modules/
COPY --from=build /src/.build/x86_64-unknown-linux-gnu/release/DataBalanceSimulator /app/DataBalanceSimulator


ENTRYPOINT ["/app/DataBalanceSimulator"]

CMD ["--config-file-path", "/app/config-files/basic.json"]
