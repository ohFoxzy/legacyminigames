FROM sapmachine:latest

ENV MC_VERSION=1.21.4
ENV MC_MEMORY=2048M
ENV EULA=TRUE
ENV PORT=25565

RUN apt-get update && apt-get install -y \
    curl \
    jq \
    wget \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

RUN LATEST_BUILD=$(curl -s "https://api.papermc.io/v2/projects/paper/versions/${MC_VERSION}/builds" | jq -r '.builds[-1].build') && \
    if [ -z "$LATEST_BUILD" ]; then \
        echo "Error: Could not fetch the latest build number."; \
        exit 1; \
    fi && \
    echo "Fetching PaperMC build ${LATEST_BUILD}... for version ${MC_VERSION}" && \
    wget "https://api.papermc.io/v2/projects/paper/versions/${MC_VERSION}/builds/${LATEST_BUILD}/downloads/paper-${MC_VERSION}-${LATEST_BUILD}.jar" -O /app/paper.jar && \
    if [ ! -f "/app/paper.jar" ]; then \
        echo "Error: Failed to download the PaperMC server jar."; \
        exit 1; \
    fi

RUN echo "eula=${EULA}" > /app/eula.txt

EXPOSE ${PORT}

CMD java -Xmx${MC_MEMORY} -Xms${MC_MEMORY} -jar /app/paper.jar nogui
