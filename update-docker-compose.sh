#!/bin/bash
# Copyright 2017-2018 Jean-Christophe Berthon
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

## WARNING: this script is NOT production ready. A few checks are done.
# It is given as a basis for building a production ready one, but you need
# to add verifications for each stage.

## Quick Changelog
# - made the script a bit more robust/safe (download the files unprivileged first
#   and "activate" them after simple verification when possible)
# - corrected all feedback provided by [shellcheck](https://github.com/koalaman/shellcheck)

set -eu

function myerror {
	echo >&2 "$@"
	exit 1
}

if ! MYTEMPDIR="$(mktemp -d)"; then
  MYTEMPDIR="/tmp/dc-$(dd status=none if=/dev/urandom bs=1 count=32 | sha256sum | cut -c-8)"
  mkdir "${MYTEMPDIR}" || myerror "ERROR: could not create temporary directory."
fi


# First download the latest release (no draft or prerelease, only full releases) of Docker Compose and
# install it under /usr/local/bin/
files_list="$(curl -s https://api.github.com/repos/docker/compose/releases/latest | grep browser_download_url \
    | grep "docker-compose-$(uname -s)-$(uname -m)" | cut -d '"' -f 4)"
curl -s -L "$(echo "${files_list}" | grep "docker-compose-$(uname -s)-$(uname -m)$")" \
    -o "${MYTEMPDIR}/docker-compose"
curl -s -L "$(echo "${files_list}" | grep "docker-compose-$(uname -s)-$(uname -m).sha256$")" \
    -o "${MYTEMPDIR}/docker-compose.sha256"

cksum_computed="$(sha256sum "${MYTEMPDIR}/docker-compose" | cut -c-64)"
cksum_given="$(cut -c-64 "${MYTEMPDIR}/docker-compose.sha256")"
if [ "${cksum_computed}" != "${cksum_given}" ]; then
  myerror "ERROR: SHA256 downloaded does not match the file"
fi

# Make sure the permissions are correct
chmod 0755 "${MYTEMPDIR}/docker-compose"

# Docker Compose shall print its version information now
"${MYTEMPDIR}/docker-compose" version

# Install Docker Compose
sudo mv "${MYTEMPDIR}/docker-compose" /usr/local/bin/docker-compose
sudo chown root:root /usr/local/bin/docker-compose

# (optional) Install BASH completion for Docker Compose
curl -s -L "https://raw.githubusercontent.com/docker/compose/$(docker-compose version --short)/contrib/completion/bash/docker-compose" \
    -o "${MYTEMPDIR}/docker-compose"
sudo mv "${MYTEMPDIR}/docker-compose" /etc/bash_completion.d/docker-compose
# Make sure the permissions are correct
sudo chmod 0644 /etc/bash_completion.d/docker-compose

# Deleting temporary files and directories
rm -Rf "${MYTEMPDIR}"

exit 0
