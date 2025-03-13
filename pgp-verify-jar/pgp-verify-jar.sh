#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

show_help() {
	cat <<EOF
Usage: ${0##*/} [options] [coordinates]
Checks the signature of jars from an artifact repository.

Options:
 
 -h                                 display this help and exit
 -v, --verification-mode MODE       use the corresponding verification mode
                                    (online or offline). In online mode, keys
                                    are downloaded from a keyserver. In offline
                                    mode, keys are read from local key store.
                                    Default is online.
 -r, --repo-base-url URL            use the provided URL to fecth signature
                                    files. Default is https://repo1.maven.org/maven2.
 -k, --keyserver SERVER             use the provided keyserver for online
                                    operations. Default is keyserver.ubuntu.com.
 -b, --bootstrap-online-keys KEYS   download from the keyserver the keys with
                                    the provided IDs (typically key-signing keys
                                    used to boostrap the chain of trust). This
                                    option argument can be a single ID or a
                                    comma-separated list of IDs.
 -o, --online-keys KEYS             download from the keyserver only the keys
                                    with the provided IDs instead of
                                    automatically downloading any key that was
                                    used to sign a jar. This option argument can
                                    be a single ID or a comma-separated list of
                                    IDs.

Coordinates:

  One or more set of coordinates using the Gradle syntax:

  groupId:artifactId:version:classifier@packaging

  The classifier (and the preceding colon) is optional.
  The packaging (and the preceding at sign) is also optional.
EOF
}

die() {
	printf 'pgp-verify-jar: ERROR: %s\n' "$1" >&2
	exit 1
}

if [ $# -ne 0 ]; then
	while :; do
		case ${1} in
		-h | -\? | --help)
			show_help
			exit
			;;
		-v | --verification-mode)
			if [ -z ${2+x} ]; then
				if [ "${2}" = 'online' ] || [ "${2}" = 'offline' ]; then
					VERIFICATION_MODE=${2}
					shift
				else
					die '"--verification-mode" option argument must be "online" or "offline".'
				fi
			else
				die '"--verification-mode" requires an option argument.'
			fi
			;;
		--verification-mode=?*)
			if [ "${1#*=}" ]; then
				if [ "${1#*=}" = 'online' ] || [ "${1#*=}" = 'offline' ]; then
					VERIFICATION_MODE=${1#*=}
					shift
				else
					die '"--verification-mode" value must be "online" or "offline".'
				fi
			else
				die '"--verification-mode" requires an option argument.'
			fi
			;;
		--verification-mode=)
			die '"--verification-mode" requires an option argument.'
			;;
		-r | --repo-base-url)
			if [ -z ${2+x} ]; then
				REPO_BASE_URL=${2}
				shift
			else
				die '"--repo-base-url" requires an option argument.'
			fi
			;;
		--repo-base-url=?*)
			if [ "${1#*=}" ]; then
				REPO_BASE_URL=${1#*=}
				shift
			else
				die '"--repo-base-url" requires an option argument.'
			fi
			;;
		--repo-base-url=)
			die '"--repo-base-url" requires an option argument.'
			;;
		-k | --keyserver)
			if [ -z ${2+x} ]; then
				KEYSERVER=${2}
				shift
			else
				die '"--keyserver" requires an option argument.'
			fi
			;;
		--keyserver=?*)
			if [ "${1#*=}" ]; then
				KEYSERVER=${1#*=}
				shift
			else
				die '"--keyserver" requires an option argument.'
			fi
			;;
		--keyserver=)
			die '"--keyserver" requires an option argument.'
			;;
		-b | --bootstrap-online-keys)
			if [ -z ${2+x} ]; then
				BOOTSTRAP_ONLINE_KEYS=${2}
				shift
			else
				die '"--bootstrap-online-keys" requires an option argument.'
			fi
			;;
		--bootstrap-online-keys=?*)
			if [ "${1#*=}" ]; then
				BOOTSTRAP_ONLINE_KEYS=${1#*=}
				shift
			else
				die '"--bootstrap-online-keys" requires an option argument.'
			fi
			;;
		--bootstrap-online-keys=)
			die '"--bootstrap-online-keys" requires an option argument.'
			;;
		-o | --online-keys)
			if [ -z ${2+x} ]; then
				ONLINE_KEYS=${2}
				shift
			else
				die '"--online-keys" requires an option argument.'
			fi
			;;
		--online-keys=?*)
			if [ "${1#*=}" ]; then
				ONLINE_KEYS=${1#*=}
				shift
			else
				die '"--online-keys" requires an option argument.'
			fi
			;;
		--online-keys=)
			die '"--online-keys" requires an option argument.'
			;;
		--)
			shift
			break
			;;
		-?*)
			die 'Unknown option (%s).'
			;;
		*)
			break
			;;
		esac
	done
fi

if [ -z ${DOWNLOAD_DIR+x} ]; then
	DOWNLOAD_DIR='/tmp/pgp-verify-jar'
fi

if [ -z ${REPO_BASE_URL+x} ]; then
	REPO_BASE_URL='https://repo1.maven.org/maven2'
fi

if [ -z ${VERIFICATION_MODE+x} ]; then
	VERIFICATION_MODE='online'
fi

if [ "${VERIFICATION_MODE}" = 'online' ]; then
	\echo pgp-verify-jar: Using online verification mode.
	if [ -z ${KEYSERVER+x} ]; then
		KEYSERVER='keyserver.ubuntu.com'
	fi
	if [ -z ${BOOTSTRAP_ONLINE_KEYS+x} ]; then
		\echo pgp-verify-jar: No boostrap online key specified.
	else
		\echo pgp-verify-jar: Downloading boostrap keys "${BOOTSTRAP_ONLINE_KEYS}" from server "${KEYSERVER}"
		IFS=',' read -ra keys <<<"${BOOTSTRAP_ONLINE_KEYS}"
		\gpg --batch --verbose --keyserver "${KEYSERVER}" --recv-keys "${keys[@]}"
	fi
	if [ -z ${ONLINE_KEYS+x} ]; then
		\echo pgp-verify-jar: WARN: No online key specified, all keys from server "${KEYSERVER}" can be used.
	else
		\echo pgp-verify-jar: Downloading keys "${ONLINE_KEYS}" from server "${KEYSERVER}"
		IFS=',' read -ra keys <<<"${ONLINE_KEYS}"
		\gpg --batch --verbose --keyserver "${KEYSERVER}" --recv-keys "${keys[@]}"
	fi
else
	\echo pgp-verify-jar: Using offline verification mode.
	\unset KEYSERVER
	\unset ONLINE_KEYS
fi

declare -a artifacts

if [ $# -ne 0 ]; then
	\echo pgp-verify-jar: Using artifacts from arguments
	artifacts=("${@}")
elif [ -n "${ARTIFACTS+x}" ]; then
	\echo pgp-verify-jar: Using artifacts from ARTIFACTS environment variable
	IFS=',' read -r -a artifacts <<<"${ARTIFACTS}"
else
	die 'No artifact provided'
fi

for artifact in "${artifacts[@]}"; do
	\echo pgp-verify-jar: Checking "${artifact}"
	if [[ "${artifact}" == *\@* ]]; then
		artifactPrefix="${artifact%\@*}"
		artifactExtension="${artifact##*\@}"
	else
		artifactPrefix="${artifact}"
		artifactExtension='jar'
	fi
	IFS=':' read -ra coordinates <<<"${artifactPrefix}"
	groupId="${coordinates[0]}"
	artifactId="${coordinates[1]}"
	artifactVersion="${coordinates[2]}"
	if [ -z ${coordinates[3]+x} ]; then
		artifactClassifierSuffix=''
	else
		artifactClassifierSuffix="-${coordinates[3]}"
	fi
	artifactFile="${artifactId}-${artifactVersion}${artifactClassifierSuffix}.${artifactExtension}"
	artifactUrl="${REPO_BASE_URL}/${groupId//\.//}/${artifactId}/${artifactVersion}/${artifactFile}"
	signatureUrl="${artifactUrl}.asc"
	signatureFile="${artifactFile}.asc"
	mkdir -m 777 "${DOWNLOAD_DIR}"
	\echo pgp-verify-jar: Downloading "${artifactUrl}"
	\curl -f -s -S -o "${DOWNLOAD_DIR}/${artifactFile}" "${artifactUrl}"
	\echo pgp-verify-jar: Downloading "${signatureUrl}"
	\curl -f -s -S -o "${DOWNLOAD_DIR}/${signatureFile}" "${signatureUrl}"
	if [ "${VERIFICATION_MODE}" = 'online' ] && [ -z ${ONLINE_KEYS+x} ]; then
		\gpg --auto-key-locate keyserver --keyserver "${KEYSERVER}" --keyserver-options auto-key-retrieve --verify "${DOWNLOAD_DIR}/${signatureFile}" "${DOWNLOAD_DIR}/${artifactFile}"
	else
		\gpg --verify "${signatureFile}" "${DOWNLOAD_DIR}/${artifactFile}"
	fi
done
