# syntax=docker/dockerfile:1.3-labs

FROM quay.io/webcenter/developer-image:base-ubi9-latest

LABEL summary="Java developer image"
LABEL description="Image to develop with java"
LABEL io.k8s.display-name="Java"

ENV HOME=/home/tooling

# Java
RUN curl -fsSL "https://get.sdkman.io/?rcupdate=false" | bash \
    && bash -c ". /home/tooling/.sdkman/bin/sdkman-init.sh \
             && sed -i "s/sdkman_auto_answer=false/sdkman_auto_answer=true/g" /home/tooling/.sdkman/etc/config \
	     && sed -i "s/sdkman_auto_env=false/sdkman_auto_env=true/g" /home/tooling/.sdkman/etc/config \
             && sdk install java 8.0.432-tem \
             && sdk install java 11.0.25-tem \
             && sdk install java 17.0.13-tem \
             && sdk install java 21.0.5-tem \
             && sdk install java 23.1.5.r21-mandrel \
             && sdk default java 17.0.13-tem \
             && sdk install gradle \
             && sdk install maven \
             && sdk install jbang \
             && sdk flush archives \
             && sdk flush temp" \
         && chgrp -R 0 /home/tooling && chmod -R g=u /home/tooling

# sdk home java <version>
ENV JAVA_HOME_8=/home/tooling/.sdkman/candidates/java/8.0.432-tem
ENV JAVA_HOME_11=/home/tooling/.sdkman/candidates/java/11.0.25-tem
ENV JAVA_HOME_17=/home/tooling/.sdkman/candidates/java/17.0.13-tem
ENV JAVA_HOME_21=/home/tooling/.sdkman/candidates/java/21.0.5-tem

# Java-related environment variables are described and set by ${PROFILE_EXT}, which will be loaded by ~/.bashrc
# To make Java working for dash and other shells, it needs to initialize them in the Dockerfile.
ENV SDKMAN_CANDIDATES_API="https://api.sdkman.io/2"
ENV SDKMAN_CANDIDATES_DIR="/home/tooling/.sdkman/candidates"
ENV SDKMAN_DIR="/home/tooling/.sdkman"
RUN if [ "$TARGETARCH" = "arm64" ]; then \
        export SDKMAN_PLATFORM="linuxarm64"; \
    else \
        export SDKMAN_PLATFORM="linuxx64"; \
    fi
ENV SDKMAN_PLATFORM=${SDKMAN_PLATFORM}
ENV SDKMAN_VERSION="5.18.2"

ENV GRADLE_HOME="/home/tooling/.sdkman/candidates/gradle/current"
ENV JAVA_HOME="/home/tooling/.sdkman/candidates/java/current"
ENV MAVEN_HOME="/home/tooling/.sdkman/candidates/maven/current"

ENV GRAALVM_HOME=/home/tooling/.sdkman/candidates/java/23.1.5.r21-mandrel

ENV PATH="/home/tooling/.krew/bin:$PATH"
ENV PATH="/home/tooling/.sdkman/candidates/maven/current/bin:$PATH"
ENV PATH="/home/tooling/.sdkman/candidates/java/current/bin:$PATH"
ENV PATH="/home/tooling/.sdkman/candidates/gradle/current/bin:$PATH"
ENV PATH="/home/tooling/.local/share/coursier/bin:$PATH"

# Scala
RUN curl -fLo cs https://git.io/coursier-cli && \
    chmod +x cs && \
    mv cs /usr/local/bin/
RUN curl -fLo sbt https://raw.githubusercontent.com/dwijnand/sbt-extras/master/sbt && \
    chmod +x sbt && \
    mv sbt /usr/local/bin/
RUN curl -fLo mill https://raw.githubusercontent.com/lefou/millw/main/millw && \
    chmod +x mill && \
    mv mill /usr/local/bin/

ENV HOME=/home/user