FROM ubuntu:18.04 as builder

RUN set -ex; \
	apt-get update; \
	apt-get install -y --no-install-recommends \
		curl \
		patch \
		openjdk-8-jdk-headless \
		openjfx=8u161-b12-1ubuntu2 \
		libopenjfx-java=8u161-b12-1ubuntu2 \
		libopenjfx-jni=8u161-b12-1ubuntu2 \
	; \
	rm -rf /var/lib/apt/lists/*

RUN useradd -m -u 1000 -s /bin/bash tron
USER tron

ARG VERSION

RUN set -ex; \
	mkdir /home/tron/tron; \
	curl -L https://github.com/tronprotocol/java-tron/archive/Odyssey-v${VERSION}.tar.gz | tar -xz --strip-components=1 -C /home/tron/tron

WORKDIR /home/tron/tron

RUN set -ex; \
	./gradlew build -x test; \
	cp build/libs/FullNode.jar build/libs/SolidityNode.jar ./


FROM ubuntu:18.04

RUN set -ex; \
	apt-get update; \
	apt-get install -y --no-install-recommends \
		curl \
		patch \
		openjdk-8-jre-headless \
		openjfx=8u161-b12-1ubuntu2 \
		libopenjfx-java=8u161-b12-1ubuntu2 \
		libopenjfx-jni=8u161-b12-1ubuntu2 \
	; \
	rm -rf /var/lib/apt/lists/*

COPY --from=builder /home/tron/tron/build/libs/FullNode.jar /home/tron/tron/build/libs/SolidityNode.jar /opt/

RUN curl -o /opt/config.conf -L https://raw.githubusercontent.com/tronprotocol/TronDeployment/master/main_net_config.conf

RUN useradd -m -u 1000 -s /bin/bash tron
USER tron
WORKDIR /opt
