#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

if [ -z ${KEYSERVER+x} ]; then
    KEYSERVER="keyserver.ubuntu.com"
fi

for artifact in "$@"
do
    echo Checking ${artifact}
    IFS=':' read -ra coordinates <<< "${artifact}"
    groupId="${coordinates[0]}"
    artifactId="${coordinates[1]}"
    artifactVersion="${coordinates[2]}"
    artifactUrl="https://repo1.maven.org/maven2/${groupId//\.//}/${artifactId}/${artifactVersion}/${artifactId}-${artifactVersion}.jar"
    artifactFile="${artifactId}-${artifactVersion}.jar"
    signatureUrl="${artifactUrl}.asc"
    signatureFile="${artifactFile}.asc"
    echo Downloading ${artifactUrl}
    curl -f -s -S -o "${artifactFile}" "${artifactUrl}"
    echo Downloading ${signatureUrl}
    curl -f -s -S -o "${signatureFile}" "${signatureUrl}"
    gpg --auto-key-locate keyserver --keyserver "${KEYSERVER}" --keyserver-options auto-key-retrieve --verify "${signatureFile}" "${artifactFile}"
done
