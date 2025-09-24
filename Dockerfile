FROM php:8.2-cli

WORKDIR /app
COPY . /app

RUN apt-get update && apt-get install -y curl

CMD php -S 0.0.0.0:80 -t /app & \
    PHP_PID=$! && \
    sleep 2 && \
    for file in $(find /app -name '*.php'); do \
      url="http://localhost:80/${file#/app/}"; \
      output="${file%.php}.html"; \
      echo "Fetching $url -> $output"; \
      curl -s "$url" -o "$output"; \
    done && \
    kill $PHP_PID
