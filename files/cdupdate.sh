
# we should be in newroot ${NEW_ROOT} and other nice things are unavailable
echo "  Running cdupdate.sh in $(pwd)"
echo "  Started as: $0 args: $*"

scriptpath=$(dirname $0)
echo " found scriptpath: ${scriptpath}"

set -x
cp ${scriptpath}/setup.start etc/local.d/
chmod +x etc/local.d/setup.start

if [ -f "${scriptpath}/authorized_keys" ]; then
	mkdir -p root/.ssh
	cp "${scriptpath}/authorized_keys" root/.ssh/authorized_keys
	chmod 600 root/.ssh/authorized_keys
fi

set +x
