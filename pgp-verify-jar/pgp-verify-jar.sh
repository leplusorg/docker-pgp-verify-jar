#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

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
	\gpg --keyserver "${KEYSERVER}" --recv-keys ${BOOTSTRAP_ONLINE_KEYS//,/ }
    fi
    if [ -z ${ONLINE_KEYS+x} ]; then
	\echo No online key specified, all keys from server "${KEYSERVER}" can be used.
    else
	\echo Downloading keys "${ONLINE_KEYS}" from server "${KEYSERVER}"
	\gpg --keyserver "${KEYSERVER}" --recv-keys ${ONLINE_KEYS//,/ }
    fi
else
    \echo "Using offline verification mode."
    unset KEYSERVER
    unset ONLINE_KEYS
fi
    
for artifact in "$@"
do
    \echo Checking "${artifact}"
    artifactPrefix="${artifact%@*}"
    artifactExtension="${artifact##*@}"
    if [ -z ${artifactExtension+x} ]; then
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
