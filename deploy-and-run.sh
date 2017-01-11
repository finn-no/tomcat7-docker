#!/bin/bash

set -o errexit
set -o pipefail
set -o nounset

validate_cgroups_memory_limit_is_set() {
 # Unset value is 2^64 on Linux and 2^63 on Mac with Docker.app
  # 2^64 has 20 numbers, while 2^63 has 19 numbers
  local max_number_length=19
  local cgroups_mem=$(cat /sys/fs/cgroup/memory/memory.limit_in_bytes)
  local meminfo_mem=$(($(awk '/MemTotal/ {print $2}' /proc/meminfo)*1024))

  # If length of the cgroups_mem number is 19 or more then fail
  if [ ${#cgroups_mem} -ge $max_number_length ]; then
    echo "ERROR: Memory limit for container is not set"
    exit 78 # Configuration error
  fi

  if [ $cgroups_mem -gt $meminfo_mem ]; then
    echo "ERROR: Memory limit for container is set to more than what is available to the host"
    exit 78 # Configuration error
  fi
}

# Calculate -Xmx using JVM_HEAP_RATIO and max memory set for the container
calculate_xmx() {
  local cgroups_mem=$(cat /sys/fs/cgroup/memory/memory.limit_in_bytes)
  local meminfo_mem=$(($(awk '/MemTotal/ {print $2}' /proc/meminfo)*1024))
  local jvm_heap_ratio=${JVM_HEAP_RATIO:-0.5}

  local xmx=$(awk '{printf("%d",$1*$2/1024^2)}' <<<" ${cgroups_mem} ${jvm_heap_ratio} ")

  echo "-Xmx${xmx}m"
}

startup() {
  validate_cgroups_memory_limit_is_set

  local webappsDir="/opt/tomcat7/webapps"
  local appDir="/app"
  local warCount=$(ls -l $appDir/*.war | wc -l)

  if [ $warCount != 1 ]; then
    echo "Error: found $warCount war files in $appDir, must be 1"
    exit 1
  fi

  : ${CONTEXT_PATH:="/"}

  local webappPath=$webappsDir/ROOT.war

  if [ $CONTEXT_PATH != "/" ]; then
      webappPath=$webappsDir/$(echo $CONTEXT_PATH | tr "/" "#").war
  fi

  ln -s $appDir/*.war $webappPath

  # Use faster (though more unsecure) random number generator
  export CATALINA_OPTS="$(calculate_xmx) -Djava.security.egd=file:/dev/./urandom"
  /opt/apache-tomcat-${TOMCAT_VERSION}/bin/catalina.sh run
}

startup $*
