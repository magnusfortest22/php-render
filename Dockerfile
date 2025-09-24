FROM php:8.2-cli

WORKDIR /app
COPY . /app

# Install curl
RUN apt-get update && apt-get install -y curl

# Serve PHP and fetch all pages
CMD php -S 0.0.0.0:80 -t /app & \
    sleep 2 && \
    for file in $(find /app -name '*.php'); do \
      url="http://localhost:80/${file#/app/}"; \
      output="${file%.php}.html"; \
      echo "Fetching $url -> $output"; \
      curl -s "$url" -o "$output"; \
    done && \
    pkill php
