FROM ghcr.io/graalvm/graalvm-ce:22.3.1 as builder

COPY pom.xml .
COPY src .
COPY --from=maven:3.9.2 /usr/share/maven /opt/maven
RUN /opt/maven/bin/mvn verify -P native
RUN file target/native.bin