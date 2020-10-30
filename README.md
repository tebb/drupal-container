# LocalGovDrupal Docker container

Container for LocalGovDrupal CI, includes Apache, PHP and Composer.

## Docker Compose

To use with the the included `docker-compose.yml` file, create a LocalGovDrupal
install in an html directory in the git root, start `docker-compose` and then
run the tests.

Something like:

```bash
git clone git@github.com:localgovdrupal/drupal-container.git localgovdrupal-testing
cd localgovdrupal-testing
docker-compose up -d
docker exec -u docker -t drupal /usr/local/bin/composer create-project --stability dev localgovdrupal/localgov-project /var/www/html
./run-tests.sh
docker-compose stop
```
