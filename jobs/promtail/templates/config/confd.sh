#!/usr/bin/env bash
#
set -e # exit immediately if a simple command exits with a non-zero status
set -u # report the usage of uninitialized variables

JOBS_DIR="/var/vcap/jobs"
LOGS_DIR="/var/vcap/sys/log"
CONFD_DIR=${CONF_DIR:-/var/vcap/jobs/promtail/config/bosh}


function get_jobs {
  local base_path="${1}"

  for job in $(find ${base_path} -maxdepth 1 ! -path ${base_path})
  do
    basename $job
  done
}


function delete_scrapes {
  local base_path="${1}"

  find ${base_path} -name '*.yaml' -exec rm -f {} \;
}


function define_scrape_job {
  local job="${1}"

cat <<EOF > "${CONFD_DIR}/${job}.yaml"
---
- targets: [ localhost ]
  labels:
    source: bosh
    job: ${job}
    __path__: ${LOGS_DIR}/${job}/*.log
EOF
}


#####

mkdir -p "${CONFD_DIR}"
delete_scrapes "${CONFD_DIR}"
for job in $(get_jobs "${JOBS_DIR}")
do
  define_scrape_job "${job}"
done

