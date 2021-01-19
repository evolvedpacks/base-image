# --- BUILD HEALTHCHECK TOOL STAGE ---------------------------------

FROM golang:1.15-alpine AS healthcheck-build
WORKDIR /build

RUN apk add git
RUN git clone https://github.com/evolvedpacks/healthcheck \
        --branch master --depth 1 .
RUN go mod download
RUN go build -v -o healthcheck ./cmd/healthcheck/main.go

# --- FINAL IMAGE STAGE --------------------------------------------

FROM openjdk:8-alpine AS final

ENV XMS=1G
ENV XMX=3G

RUN apk add curl git

COPY --from=healthcheck-build /build/healthcheck /bin/healthcheck
# 90 Retries * 10s -> 15 Minutes Startup Time Assumption
HEALTHCHECK --interval=10s --timeout=10s --retries=90 \
    CMD /bin/healthcheck -addr localhost:25565 -validateResponse

ENV VERSION=$VERSION

WORKDIR /var/server

COPY ./scripts/entrypoint.sh ./entrypoint.sh
COPY ./banner.txt ./_docker_data/default-banner.txt

EXPOSE 25565 25575

ENTRYPOINT ["sh", "./entrypoint.sh"]