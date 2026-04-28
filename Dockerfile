# syntax=docker/dockerfile:1
FROM --platform=$BUILDPLATFORM golang:1.23-alpine AS builder

ARG TARGETPLATFORM
ARG BUILDPLATFORM
ARG TARGETOS
ARG TARGETARCH
ARG TARGETVARIANT

WORKDIR /app
COPY . .

# Build for the target platform
RUN --mount=type=cache,target=/go/pkg/mod \
    --mount=type=cache,target=/root/.cache/go-build \
    GOOS=${TARGETOS} GOARCH=${TARGETARCH} GOARM=${TARGETVARIANT#v} \
    CGO_ENABLED=0 go build -trimpath -ldflags="-s -w" -o audiobook-organizer

FROM --platform=$TARGETPLATFORM alpine:latest

# Put the binary on PATH so it can be called by name from the console
COPY --from=builder /app/audiobook-organizer /usr/local/bin/audiobook-organizer

# Apply umask 000 to every sh session, including docker exec consoles.
# Alpine's sh (busybox ash) sources $ENV on startup for interactive shells.
RUN echo 'umask 0000' > /etc/umask.sh
ENV ENV="/etc/umask.sh"

# Quick-reference for running the organizer from the container console
RUN printf 'audiobook-organizer --replace-special "" --layout=author-series-title --rename-files --dry-run\n' > /help.txt

# Keep the container alive. Run via sh so umask 0000 is applied to
# the process before tail starts, ensuring child processes inherit it.
CMD ["sh", "-c", "umask 0000 && exec tail -f /dev/null"]
