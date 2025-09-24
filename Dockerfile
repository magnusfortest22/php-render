FROM php:8.2-cli

WORKDIR /app
COPY . /app

RUN apt-get update && apt-get install -y curl wget

CMD php -S 0.0.0.0:80 -t /app & \
    PHP_PID=$! && \
    sleep 2 && \
    wget --mirror \
         --convert-links \
         --adjust-extension \
         --page-requisites \
         --no-parent \
         -P static_html_directory \
         http://localhost:80/index.php && \
    kill $PHP_PID
