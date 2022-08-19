FROM ubuntu:20.04 as builder

RUN set -ex; \
	apt-get update; \
	apt-get install -y --no-install-recommends \
		git \
		curl \
		patch \
		openjdk-8-jdk-headless \
	; \
	rm -rf /var/lib/apt/lists/*

RUN useradd -m -u 1000 -s /bin/bash tron
USER tron

ARG VERSION

RUN set -ex; \
    git clone --depth 1 -b GreatVoyage-v${VERSION} https://github.com/tronprotocol/java-tron.git /home/tron/tron

RUN set -ex; \
	cd /home/tron/tron; \
	./gradlew build -x test


FROM ubuntu:20.04

RUN set -ex; \
	apt-get update; \
	apt-get install -y --no-install-recommends \
		curl \
		patch \
		openjdk-8-jre-headless \
	; \
	rm -rf /var/lib/apt/lists/*

COPY --from=builder /home/tron/tron/build/libs/FullNode.jar /opt/

RUN curl -o /opt/config.conf -L https://raw.githubusercontent.com/tronprotocol/TronDeployment/master/main_net_config.conf

RUN useradd -m -u 1000 -s /bin/bash tron
USER tron
WORKDIR /opt
