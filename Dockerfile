FROM ubuntu:18.04

RUN set -ex; \
	apt-get update; \
	apt-get install -y --no-install-recommends \
		curl \
		software-properties-common \
		patch \
	; \
	apt-add-repository ppa:webupd8team/java; \
	apt-get update; \
	echo "oracle-java8-installer shared/accepted-oracle-license-v1-1 select true" | debconf-set-selections; \
	apt-get install -y --no-install-recommends \
		oracle-java8-installer \
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

RUN set -ex; \
	curl -o config.conf -L https://raw.githubusercontent.com/tronprotocol/TronDeployment/master/main_net_config.conf
