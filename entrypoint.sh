#!/bin/bash

set -xe

TFSEC_VERSION="latest"
if [ "$INPUT_VERSION" != "latest" ]; then
  TFSEC_VERSION="tags/${INPUT_VERSION}"
fi

wget -O - -q "$(wget -q https://api.github.com/repos/aquasecurity/tfsec/releases/${TFSEC_VERSION} -O - | grep -o -E "https://.+?tfsec-linux-amd64" | head -n1)" > tfsec
install tfsec /usr/local/bin/

if [ -n "${GITHUB_WORKSPACE}" ]; then
  cd "${GITHUB_WORKSPACE}" || exit
fi

if [ -n "${INPUT_ADDITIONAL_ARGS}" ]; then
  TFSEC_ARGS_OPTION="${INPUT_ADDITIONAL_ARGS}"
fi

if [ -n "${INPUT_SOFT_FAIL}" ]; then
  SOFT_FAIL="--soft-fail"
fi

FORMAT=${INPUT_FORMAT:-default}

CMD_OUTPUT=$(tfsec  --format=${FORMAT} ${SOFT_FAIL} ${TFSEC_ARGS_OPTION} "${INPUT_WORKING_DIRECTORY}" 2>&1)

CMD_OUTPUT=`echo ${CMD_OUTPUT} | tr 'LOW' ":blue_circle: LOW" | tr 'MEDIUM' ":yellow_circle: MEDIUM" | tr 'HIGH' ":red_circle: HIGH"`

echo 'tfsec-output<<EOF' >> $GITHUB_OUTPUT
echo $CMD_OUTPUT >> $GITHUB_OUTPUT
echo 'EOF' >> $GITHUB_OUTPUT
