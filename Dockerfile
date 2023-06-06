FROM ghcr.io/graalvm/graalvm-ce:22.3.1 as builder

ARG UID=1001
ARG USER=appuser

COPY --from=maven:3.8.7-eclipse-temurin-17-alpine /usr/share/maven /opt/maven
ENV MAVEN_HOME=/opt/maven
RUN adduser \
    -u $UID \
    -s /bin/false \
    --no-create-home \
    $USER
COPY pom.xml .
RUN /opt/maven/bin/mvn dependency:resolve dependency:resolve-plugins
COPY src src
RUN /opt/maven/bin/mvn -B verify -Pnative
RUN file target/native.bin

FROM scratch

COPY --from=builder /etc/passwd /etc/passwd
COPY --from=builder --chown=${UID} /app/target/native.bin /native.bin
USER $USER
ENV PORT=9999
EXPOSE ${PORT}
ENTRYPOINT ["/native.bin"]