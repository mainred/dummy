FROM gcr.io/distroless/static

ARG ARCH=amd64

COPY bin/simple-server-${ARCH} /usr/local/bin/simple-server
ENTRYPOINT [ "/usr/local/bin/simple-server" ]