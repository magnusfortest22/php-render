#!/usr/bin/env bash
set -euo pipefail

cd /app

# --- Config (can be overridden by environment variable EXCLUDE_REGEX) ---
HOST=${HOST:-127.0.0.1}
PORT=${PORT:-80}
START_PATH=${START_PATH:-/index.php}
START_URL="http://${HOST}:${PORT}${START_PATH}"

# reject-pattern for wget --reject-regex (simple OR list). You can override with EXCLUDE_REGEX env var.
EXCLUDE_REGEX="${EXCLUDE_REGEX:-admin|test|wp-admin|private|/tmp/}"

# Timeouts/retries
WGET_RETRIES=${WGET_RETRIES:-2}
WGET_TIMEOUT=${WGET_TIMEOUT:-10}

echo "Starting PHP dev server..."
php -S 0.0.0.0:${PORT} -t /app >/tmp/php-server.log 2>&1 &
PHP_PID=$!
echo "PHP PID: $PHP_PID"
sleep 2

mkdir -p static_html_directory

echo "Crawling ${START_URL} (reject-regex='${EXCLUDE_REGEX}') ..."
# mirror site starting from START_URL; do NOT create host directory (--no-host-directories)
# --adjust-extension will add .html to files that look like HTML
# --ignore-errors / || true ensures we don't exit on single-page 4xx/5xx
wget --mirror \
     --convert-links \
     --adjust-extension \
     --page-requisites \
     --no-parent \
     --no-host-directories \
     --directory-prefix=static_html_directory \
     --execute robots=off \
     --reject-regex="${EXCLUDE_REGEX}" \
     --tries=${WGET_RETRIES} \
     --timeout=${WGET_TIMEOUT} \
     "${START_URL}" || echo "wget finished with non-zero exit code; continuing"

echo "Post-processing filenames..."
# Convert *.php.html and *.php => *.html (keeps directory structure)
# Works for normal server-rendered pages.
find static_html_directory -type f -print0 | while IFS= read -r -d '' file; do
  case "${file}" in
    *.php.html)
      target="${file%.php.html}.html"
      mkdir -p "$(dirname "${target}")"
      mv -f -- "${file}" "${target}"
      ;;
    *.php)
      target="${file%.php}.html"
      mkdir -p "$(dirname "${target}")"
      mv -f -- "${file}" "${target}"
      ;;
    *)
      # leave other files (css/js/images) alone
      ;;
  esac
done

# Optional: remove empty directories (if any)
find static_html_directory -type d -empty -delete || true

# Stop PHP server
kill "${PHP_PID}" || true

echo "Static export complete. Files are in static_html_directory/"
exit 0
