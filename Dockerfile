# syntax=docker/dockerfile:1

########## Build stage ##########
FROM golang:1.25-alpine AS build
WORKDIR /app
# OJO: no fijamos GOTOOLCHAIN=local
ENV CGO_ENABLED=0 GOOS=linux GOPROXY=https://goproxy.io,direct

COPY go.mod go.sum ./
RUN --mount=type=cache,target=/go/pkg/mod go mod download

COPY . .
RUN --mount=type=cache,target=/root/.cache/go-build \
    go build -o /app/trumail .

########## Runtime stage ##########
FROM alpine:3.20
RUN apk add --no-cache ca-certificates tzdata && adduser -D -H app
USER app
WORKDIR /app
COPY --from=build /app/trumail /app/trumail
ENV SOURCE_ADDR=""
EXPOSE 8080
ENV PORT=8080
ENTRYPOINT ["/app/trumail"]

HEALTHCHECK --interval=30s --timeout=10s --start-period=30s --retries=5 \
  CMD wget -q -O - http://localhost:8080/v1/health >/dev/null 2>&1 || exit 1
