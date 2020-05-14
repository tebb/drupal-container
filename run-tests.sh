#!/bin/bash

##
# Run all tests!

# Ensure everything is up to date
docker exec -u docker -t drupal bash -c "cd /var/www/html && composer install"

# Coding standards
echo "Checking coding standards"
docker exec -t drupal bash -c "cd /var/www/html && ./bin/phpcs"

# Deprecated code
echo "Checking for deprecated code"
docker exec -t drupal bash -c "cd /var/www/html && ./bin/phpstan analyse -c ./phpstan.neon ./web/profiles/contrib/localgov/ ./web/modules/contrib/localgov_*"

# Tests
echo "Running tests"
docker exec -t drupal bash -c "mkdir -p /var/www/html/web/sites/simpletest && chmod 777 /var/www/html/web/sites/simpletest"
docker exec -u docker -t drupal bash -c "cd /var/www/html && ./bin/phpunit --testdox"

