# syntax=docker/dockerfile:1
ARG SWIFT_VERSION=5.10.1
FROM swift:${SWIFT_VERSION}
ARG REMOTE_USER=

WORKDIR /src

RUN <<EOF
    apt-get update
    apt-get install -y python3 python3-pip python3-venv python3-mysqldb libmysqlclient-dev
EOF

RUN --mount=type=bind,source=requirements.txt,target=requirements.txt \ 
    pip install -r requirements.txt

# Added to avoid the rootful access on files
# https://github.com/microsoft/vscode-remote-release/issues/49#issuecomment-489105458
RUN <<EOF
    addgroup --gid 1000 ${REMOTE_USER}
    adduser --disabled-password --uid 1000 --gid 1000 ${REMOTE_USER}
EOF

ENV HOME /home/${REMOTE_USER}

USER ${REMOTE_USER}