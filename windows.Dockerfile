ARG OSVERSION=1809
ARG ARCH=amd64

# NOTE(claudiub): Instead of pulling the servercore image, which is ~2GB in side, we
# can instead pull the windows-servercore-cache image, which is only a few MBs in size.
# The image contains the netapi32.dll we need.
FROM --platform=linux/amd64 gcr.io/k8s-staging-e2e-test-images/windows-servercore-cache:1.0-linux-${ARCH}-$OSVERSION as servercore-helper

FROM mcr.microsoft.com/windows/nanoserver:$OSVERSION

ARG OSVERSION
ARG ARCH

COPY --from=servercore-helper /Windows/System32/netapi32.dll /Windows/System32/netapi32.dll
COPY bin/simple-server-${ARCH}.exe /simple-server.exe
USER ContainerAdministrator
ENTRYPOINT ["/simple-server.exe"]