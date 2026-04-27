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

# Keep the container alive so Unraid's Console button works
CMD ["tail", "-f", "/dev/null"]
