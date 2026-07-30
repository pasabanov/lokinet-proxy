FROM debian:bookworm-slim@sha256:7b140f374b289a7c2befc338f42ebe6441b7ea838a042bbd5acbfca6ec875818

ENV DEBIAN_FRONTEND=noninteractive
ENV SOCKS_PORT=1051
ENV LOKINET_WORKER_THREADS=1
ENV LOKINET_HOPS=3
ENV LOKINET_PATHS=6
ENV LOKINET_UPSTREAM_DNS=9.9.9.9
ENV LOKINET_EXIT_NODE=exit.loki

# Added ca-certificates because slim images may not have it by default, which causes curl HTTPS certificate errors
RUN apt-get update && apt-get install -y --no-install-recommends \
	curl ca-certificates iproute2 dante-server && \
	curl -so /etc/apt/trusted.gpg.d/oxen.gpg https://deb.oxen.io/pub.gpg && \
	echo 'deb https://deb.oxen.io bookworm main' > /etc/apt/sources.list.d/oxen.list && \
	apt-get update && apt-get install -y --no-install-recommends lokinet && \
	# Removing build dependencies
	apt-get purge --auto-remove -y curl ca-certificates && \
	# Clean apt cache, this step is key to keeping the image small
	apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

COPY docker-entrypoint.sh /docker-entrypoint.sh
RUN chmod +x /docker-entrypoint.sh

EXPOSE ${SOCKS_PORT}

CMD ["/docker-entrypoint.sh"]