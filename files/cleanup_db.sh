#!/bin/bash
DBOARD_DIR=/usr/share/puppet-dashboard
cd ${DBOARD_DIR}
rake RAILS_ENV=production reports:prune upto=1 unit=mon
rake RAILS_ENV=production reports:prune:orphaned upto=1 unit=mon
rake RAILS_ENV=production db:raw:optimize
