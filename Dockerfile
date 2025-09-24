FROM php:8.2-cli

WORKDIR /app
COPY . /app

# install wget (for crawling) and ca-certificates
RUN apt-get update && \
    apt-get install -y --no-install-recommends wget ca-certificates && \
    rm -rf /var/lib/apt/lists/*

# copy crawler runner script
COPY generate-static.sh /usr/local/bin/generate-static.sh
RUN chmod +x /usr/local/bin/generate-static.sh

# container runs the script which starts php server, crawls, postprocesses and exits 0
CMD ["bash", "/usr/local/bin/generate-static.sh"]
