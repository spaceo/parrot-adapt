#!/bin/bash

if [ -f /usr/bin/dropdb ]
then
  /usr/bin/dropdb -e gst
fi

if [ -f /vagrant/sql/pre_kms_live.sql ]
then
  /usr/bin/psql -f /vagrant/sql/pre_kms_live.sql
fi

if [ -f /vagrant/sql/kms_live.sql ]
then
  /usr/bin/pg_restore -i -h localhost -U vagrant -d gst -v "/vagrant/sql/kms_live.sql"
fi

