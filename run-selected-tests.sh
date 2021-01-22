#!/bin/bash

# TODO:
# This is a quick hack.  If want to use this more generally, it needs
#  better 'work filtering'starting with code standards only on test file
#
# Args to this script should be either single file, list or array perhaps.

##
# Run selected tests!
RESULT=0

# Fix ownership of code base.
docker exec -t drupal bash -c "chown -R docker:docker /var/www/html"

# Ensure everything is up to date.
docker exec -u docker -t drupal bash -c "cd /var/www/html && composer install"

# Coding standards checks.
echo "Checking coding standards"
docker exec -t drupal bash -c "cd /var/www/html && ./bin/phpcs"
if [ $? -ne 0 ]; then
  ((RESULT++))
fi

# Deprecated code checks.
echo "Checking for deprecated code"
docker exec -t drupal bash -c "cd /var/www/html && ./bin/phpstan analyse -c ./phpstan.neon ./web/profiles/contrib/localgov/ ./web/modules/contrib/localgov_*"
if [ $? -ne 0 ]; then
  ((RESULT++))
fi

# .TODO:  Use script arguments.  Php or just class name?
# PHPUnit test supplied test files.
shouldBeParameter="web/modules/contrib/localgov_services/tests/src/FunctionalJavascript/ServicesMenuGroupTest.php"
echo "Running tests on: $shouldBeParameter"
docker exec -t drupal bash -c "mkdir -p /var/www/html/web/sites/simpletest && chmod 777 /var/www/html/web/sites/simpletest"
# Update PHPUnit's env var declarations; Paratest does not pass these to PHPUnit :(
docker exec -u docker -t drupal bash -c 'sed -i "s#http://localgov.lndo.site#http://drupal#; s#mysql://database:database@database/database#sqlite://localhost//dev/shm/test.sqlite#" /var/www/html/phpunit.xml.dist'

# TODO: Where does paratest get it's todo list from?
# ... change it to the supplied test files
# Experiment: with number of processes to test if it's disk/db/? bound
# docker exec -u docker -t drupal bash -c "cd /var/www/html && ./bin/paratest --processes=4 --verbose=1"
# TODO:: Substitute $shouldBeParameter here:
docker exec -u docker -t drupal bash -c "cd /var/www/html && /usr/bin/php7.4 '/var/www/html/vendor/phpunit/phpunit/phpunit' '--configuration' '/var/www/html/phpunit.xml.dist' '--log-junit' '/tmp' '/var/www/html/web/modules/contrib/localgov_services/tests/src/FunctionalJavascript/ServicesMenuGroupTest.php'"

if [ $? -ne 0 ]; then
  ((RESULT++))
fi

# Set return code depending on number of tests that failed.
exit $RESULT
