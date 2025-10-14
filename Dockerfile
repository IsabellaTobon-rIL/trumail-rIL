# syntax=docker/dockerfile:1

########## Build ##########
FROM golang:1.24-alpine AS build
WORKDIR /app
ENV CGO_ENABLED=0 GOOS=linux GOPROXY=https://goproxy.io,direct
COPY go.mod go.sum ./
RUN --mount=type=cache,target=/go/pkg/mod go mod download
COPY . .
RUN --mount=type=cache,target=/root/.cache/go-build \
    go build -o /usr/local/bin/trumail .

########## Runtime ##########
FROM alpine:3.20
RUN apk add --no-cache ca-certificates tzdata && adduser -D -H app
USER app
EXPOSE 8080
ENV SOURCE_ADDR=""
ENTRYPOINT ["/usr/local/bin/trumail"]
