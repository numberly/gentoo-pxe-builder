#!/bin/bash

# we should be in newroot, don't trust that we have ${NEW_ROOT}
echo "Running cdupdate.sh in $(pwd)"

echo "  Paths: /${NEW_ROOT}/${CDROOT_PATH}/ /${CDROOT_PATH}/"
echo "  Started as: $0 $*"

set -x
cp /setup.start etc/local.d/
chmod +x etc/local.d/setup.start

if [ -f "/authorized_keys" ]; then
	mkdir -p root/.ssh
	cp "/authorized_keys" root/.ssh/authorized_keys
	chmod 600 root/.ssh/authorized_keys
fi

set +x
