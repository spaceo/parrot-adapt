#!/bin/bash

# Run post-provision.drush scripts
for script in `find /vagrant_sites/* -type f -name 'post-provision.drush'`
do
 /usr/bin/drush --root=$(dirname $script)/htdocs php-script $script
done
