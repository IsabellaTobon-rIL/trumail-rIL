# syntax=docker/dockerfile:1

########## Build stage ##########
FROM golang:1.24-alpine AS build
WORKDIR /app
ENV CGO_ENABLED=0 GOOS=linux GOPROXY=https://goproxy.io,direct

# Descargar módulos primero para cache
COPY go.mod go.sum ./
RUN --mount=type=cache,target=/go/pkg/mod go mod download

# Copiar código y compilar desde la RAÍZ
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
ENTRYPOINT ["/app/trumail"]
