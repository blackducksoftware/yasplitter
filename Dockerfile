FROM alpine:3.19

# Small scanner image that runs the repo's scanlargefolder.sh script.
# It installs bash, curl and CA certs so the script can call external services.

# Black Duck server URL (set at runtime)
ENV BD_URL=""
ENV JAVA_HOME="/usr/lib/jvm/java-11-openjdk"
# Default DETECT_SERIAL_MODE to 1 (true-ish). Users can override at runtime.
ENV DETECT_SERIAL_MODE="true"

WORKDIR /app

# install runtime deps
RUN apk add --no-cache grep pcre bash curl ca-certificates findutils openjdk11-jre && update-ca-certificates && \
	apk upgrade

# Copy only the scanner script(s) we need. Keep permissions.

# Copy scanner script and an entrypoint that will load secrets if mounted
COPY src/*.sh /app/
RUN chmod +x /app/*.sh

# Use the secure entrypoint which exports secrets (if provided) and then
# execs the scanner script while forwarding any CLI args.
ENTRYPOINT ["/bin/bash", "/app/docker-entrypoint.sh"]
WORKDIR /app

# By using ENTRYPOINT, `docker run <image> <args...>` will pass <args...>
# to the script. 