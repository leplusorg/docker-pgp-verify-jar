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
    if [ -z ${ONLINE_KEYS+x} ]; then
	\echo No online key specified, all keys from server "${KEYSERVER}" can be used.
    else
	for key in ${ONLINE_KEYS//,/ }; do
	    \echo Downloading key "${key}" from server "${KEYSERVER}"
	    \gpg --keyserver "${KEYSERVER}" --recv-keys "${key}"
	done
    fi
else
    \echo "Using offline verification mode."
    unset KEYSERVER
    unset ONLINE_KEYS
fi
    
for artifact in "$@"
do
    \echo Checking "${artifact}"
    IFS=':' read -ra coordinates <<< "${artifact}"
    groupId="${coordinates[0]}"
    artifactId="${coordinates[1]}"
    artifactVersion="${coordinates[2]}"
    artifactUrl="https://repo1.maven.org/maven2/${groupId//\.//}/${artifactId}/${artifactVersion}/${artifactId}-${artifactVersion}.jar"
    artifactFile="${artifactId}-${artifactVersion}.jar"
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
