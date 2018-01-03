#!/bin/sh

# if the admin password is defined in the ENV variable, we append to the config
if [ -n "${ADMINPASSWD-}" ]; then
	echo "ADMINPASSWD provided"
else
	echo "ADMINPASSWD not provided"
fi

# We figure out what is the current db folder
if [ "${NXTNET:=test}" = "main" ]; then
	# main net
	TESTNET=false
	NXTNET=main
else
	# everything else defaults to test net
	TESTNET=true
	NXTNET=test
fi

if [ ! -f "/ardor/conf/version" ]; then
	echo -e "init-nxt.sh: Performing version $NRSVersion init..."

	# If there is no .init, this can be a new install
	# or an upgrade...

	# if a script was provided, we download it locally
	# then we run it before anything else starts
	if [ -n "${SCRIPT-}" ]; then
		filename=$(basename "$SCRIPT")
		wget "$SCRIPT" -O "/nxt-boot/scripts/$filename"
		chmod u+x "/nxt-boot/scripts/$filename"
		/nxt-boot/scripts/$filename
	fi

	if [ -n "${PLUGINS-}" ]; then
		/nxt-boot/scripts/install-plugins.sh "$PLUGINS"
	else
		echo "PLUGINS not provided"
	fi

	# $BLOCKCHAINDL must point to a zip that contains the nxt_db folder itself.
	if [ -n "${BLOCKCHAINDL-}" ]; then
		echo "init-nxt.sh: downloading blockchain from $BLOCKCHAINDL";
		wget "$BLOCKCHAINDL" && unzip *.zip && mv nxt_db nxt_${NXTNET}_db && rm *.zip
		echo "init-nxt.sh: Blockchain download complete"
	else
		echo "BLOCKCHAINDL not provided"
	fi

	# If we did all of that, we dump a file that will signal next time that we
	# should not run the init-script again
	echo ${NRSVersion} >/ardor/conf/version
fi

echo "init-nxt.sh: Preparing config for ${NXTNET} net"
sed -e "s/ADMINPASSWD/${ADMINPASSWD}/g" \
	-e "s/TESTNET/${TESTNET}/g" \
	-e "s/NXTNET/${NXTNET}/g" \
	-e "s/MYPLATFORM/${MYPLATFORM:-Docker}/g" \
	-e "s/MYADDRESS/${MYADDRESS}/g" \
	-e 's/\r$//g' \
	</nxt-boot/conf/nxt-${NXTNET:-test}.properties >/ardor/conf/nxt.properties

./run.sh
