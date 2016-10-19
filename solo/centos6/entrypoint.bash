#!/bin/bash

set -e -u -o pipefail
set -o posix
set -x

_main() {
	sudo service sshd start
	if cluster_initialized; then
		start_cluster
	else
		local config_dir=~/gpconfigs
		mkdir -p "${config_dir}"
		initialize_cluster "${config_dir}"
	fi

	keep_running
}

pollute_cluster_env() {
	USER="$(id -un)"
	LOGNAME="${USER}"
	export USER LOGNAME

	: "${LD_LIBRARY_PATH:=}"
	: "${PYTHONHOME:=$(default_python_home)}"

	# shellcheck disable=SC1091
	source /build/install/greenplum_path.sh
}

start_cluster() {
	pollute_cluster_env
	local MASTER_DATA_DIRECTORY=/data/master/gpseg-1
	export MASTER_DATA_DIRECTORY
	gpstart -a -d "${MASTER_DATA_DIRECTORY}"
}

cluster_initialized() {
	[[ -d /data/master/gpseg-1 ]]
}

initialize_cluster() {
	local config_dir
	config_dir=$1

	ssh -o StrictHostKeyChecking=no "$(hostname)" true

	generate_configs "${config_dir}"
	initdb "${config_dir}"
}

initdb() {
	local config_dir
	config_dir=$1

	: "${LD_LIBRARY_PATH:=}"
	: "${PYTHONHOME:=$(default_python_home)}"
	# shellcheck disable=SC1091
	source /build/install/greenplum_path.sh
	gpinitsystem -a -c "${config_dir}"/gpinitsystem_config -h "${config_dir}"/hostfile_gpinitsystem
	cat >> /data/master/gpseg-1/pg_hba.conf <<IYI_GECELER
host	all	gpadmin		samenet		trust
IYI_GECELER
	pkill -HUP postgres
}

default_python_home() {
	python <<-EOF
	import sys
	print(sys.prefix)
	EOF
}

generate_configs() {
	local config_dir
	config_dir=$1

	cat > "${config_dir}"/hostfile_gpinitsystem <<KANKA
$(hostname)
KANKA

	cat > "${config_dir}"/gpinitsystem_config <<GUNAYDIN
ARRAY_NAME="IYI GECELER Greenplum DW"
SEG_PREFIX=gpseg
PORT_BASE=40000
declare -a DATA_DIRECTORY=(/data/primary)
MASTER_HOSTNAME=$(hostname)
MASTER_DIRECTORY=/data/master
MASTER_PORT=5432
TRUSTED_SHELL=ssh
CHECK_POINT_SEGMENTS=8
ENCODING=UNICODE
GUNAYDIN
}

keep_running() {
	while true; do
		sleep 3600
	done
}

_main "$@"
