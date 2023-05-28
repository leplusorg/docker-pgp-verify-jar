#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

show_help() {
cat << EOF
Usage: ${0##*/} [options] [coordinates]
Checks the signature of jars from an artifact repository.

Options:
 
 -h                                 display this help and exit
 -v, --verification-mode MODE       use the corresponding verification mode
                                    (online or offline). Default is online.
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
    printf '%s\n' "$1" >&2
    exit 1
}

while :; do
    case ${1} in
        -h|-\?|--help)
            show_help
            exit
            ;;
        -v|--verification-mode)
            if [ -z ${2+x} ]; then
		if [ "${2}" = 'online' ] || [ "${2}" = 'offline' ]; then
                    VERIFICATION_MODE=${2}
                    shift
		else
                    die 'ERROR: "--verification-mode" option argument must be "online" or "offline".'
		fi
            else
                die 'ERROR: "--verification-mode" requires an option argument.'
            fi
            ;;
        --verification-mode=?*)
            if [ "${1#*=}" ]; then
		if [ "${1#*=}" = 'online' ] || [ "${1#*=}" = 'offline' ]; then
                    VERIFICATION_MODE=${1#*=}
                    shift
		else
                    die 'ERROR: "--verification-mode" value must be "online" or "offline".'
		fi
            else
                die 'ERROR: "--verification-mode" requires an option argument.'
            fi
            ;;
        --verification-mode=)
            die 'ERROR: "--verification-mode" requires an option argument.'
            ;;
        -k|--keyserver)
            if [ -z ${2+x} ]; then
                KEYSERVER=${2}
                shift
            else
                die 'ERROR: "--keyserver" requires an option argument.'
            fi
            ;;
        --keyserver=?*)
            if [ "${1#*=}" ]; then
                KEYSERVER=${1#*=}
                shift
            else
                die 'ERROR: "--keyserver" requires an option argument.'
            fi
            ;;
        --keyserver=)
            die 'ERROR: "--keyserver" requires an option argument.'
            ;;
        -b|--bootstrap-online-keys)
            if [ -z ${2+x} ]; then
                BOOTSTRAP_ONLINE_KEYS=${2}
                shift
            else
                die 'ERROR: "--bootstrap-online-keys" requires an option argument.'
            fi
            ;;
        --bootstrap-online-keys=?*)
            if [ "${1#*=}" ]; then
                BOOTSTRAP_ONLINE_KEYS=${1#*=}
                shift
            else
                die 'ERROR: "--bootstrap-online-keys" requires an option argument.'
            fi
            ;;
        --bootstrap-online-keys=)
            die 'ERROR: "--bootstrap-online-keys" requires an option argument.'
            ;;
        -o|--online-keys)
            if [ -z ${2+x} ]; then
                ONLINE_KEYS=${2}
                shift
            else
                die 'ERROR: "--online-keys" requires an option argument.'
            fi
            ;;
        --online-keys=?*)
            if [ "${1#*=}" ]; then
                ONLINE_KEYS=${1#*=}
                shift
            else
                die 'ERROR: "--online-keys" requires an option argument.'
            fi
            ;;
        --online-keys=)
            die 'ERROR: "--online-keys" requires an option argument.'
            ;;
        --)
            shift
            break
            ;;
        -?*)
            die 'ERROR: Unknown option (%s).'
            ;;
        *)
            break
    esac

    shift
done

if [ -z ${VERIFICATION_MODE+x} ]; then
    VERIFICATION_MODE='online'
fi

if [ "${VERIFICATION_MODE}" = 'online' ]; then
    \echo "Using online verification mode."
    if [ -z ${KEYSERVER+x} ]; then
	KEYSERVER='keyserver.ubuntu.com'
    fi
    if [ -z ${BOOTSTRAP_ONLINE_KEYS+x} ]; then
	\echo No boostrap online key specified.
    else
	\echo Downloading boostrap keys "${BOOTSTRAP_ONLINE_KEYS}" from server "${KEYSERVER}"
	IFS=',' read -ra keys <<< "${BOOTSTRAP_ONLINE_KEYS}"
	\gpg --batch --verbose --keyserver "${KEYSERVER}" --recv-keys "${keys[@]}"
    fi
    if [ -z ${ONLINE_KEYS+x} ]; then
	\echo No online key specified, all keys from server "${KEYSERVER}" can be used.
    else
	\echo Downloading keys "${ONLINE_KEYS}" from server "${KEYSERVER}"
	IFS=',' read -ra keys <<< "${ONLINE_KEYS}"
	\gpg --batch --verbose --keyserver "${KEYSERVER}" --recv-keys "${keys[@]}"
    fi
else
    \echo "Using offline verification mode."
    \unset KEYSERVER
    \unset ONLINE_KEYS
fi
    
for artifact in "$@"
do
    \echo Checking "${artifact}"
    if [[ "${artifact}" == *\@* ]]; then
	artifactPrefix="${artifact%\@*}"
	artifactExtension="${artifact##*\@}"
    else
	artifactPrefix="${artifact}"
	artifactExtension='jar'
    fi
    IFS=':' read -ra coordinates <<< "${artifactPrefix}"
    groupId="${coordinates[0]}"
    artifactId="${coordinates[1]}"
    artifactVersion="${coordinates[2]}"
    if [ -z ${coordinates[3]+x} ]; then
	artifactClassifierSuffix=''
    else
	artifactClassifierSuffix="-${coordinates[3]}"
    fi
    artifactUrl="https://repo1.maven.org/maven2/${groupId//\.//}/${artifactId}/${artifactVersion}/${artifactId}-${artifactVersion}${artifactClassifierSuffix}.${artifactExtension}"
    artifactFile="${artifactId}-${artifactVersion}${artifactClassifierSuffix}.${artifactExtension}"
    signatureUrl="${artifactUrl}.asc"
    signatureFile="${artifactFile}.asc"
    \echo Downloading "${artifactUrl}"
    \curl -f -s -S -o "${artifactFile}" "${artifactUrl}"
    \echo Downloading "${signatureUrl}"
    \curl -f -s -S -o "${signatureFile}" "${signatureUrl}"
    if [ "${VERIFICATION_MODE}" = 'online' ] && [ -z ${ONLINE_KEYS+x} ]; then
	\gpg --auto-key-locate keyserver --keyserver "${KEYSERVER}" --keyserver-options auto-key-retrieve --verify "${signatureFile}" "${artifactFile}"
    else
	\gpg --verify "${signatureFile}" "${artifactFile}"
    fi
done
