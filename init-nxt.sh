#!/bin/sh

if [ ! -f "/ardor/conf/version" ]; then
	echo -e " init-nxt.sh: Performing version $NRSVersion init..."

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
		echo " PLUGINS not provided"
	fi

	# We figure out what is the current db folder
	if [ "$NXTNET" = "main" ]; then
		DB="nxt_db"
	else
		DB="nxt_test_db"
	fi

	# just to be sure :)
	echo " Database is $DB"

	# if we need to bootstrap, we do that first.
	# Warning, bootstrapping will delete the current blockchain.
	# $BLOCKCHAINDL must point to a zip that contains the nxt_db folder itself.
	if [ -n "${BLOCKCHAINDL-}" ] && [ ! -d "$DB" ]; then
		echo " init-nxt.sh: $DB not found, downloading blockchain from $BLOCKCHAINDL";
		wget "$BLOCKCHAINDL" && unzip *.zip && rm *.zip
		echo " init-nxt.sh: Blockchain download complete"
	else
		echo " BLOCKCHAINDL not provided"
	fi

	# if the admin password is defined in the ENV variable, we append to the config
	if [ -n "${ADMINPASSWD-}" ]; then
		echo " ADMINPASSWD provided"
	else
		echo " ADMINPASSWD not provided"
	fi

	echo " init-nxt.sh: Linking config to ${NXTNET}"
	sed -e "s/ADMINPASSWD/${ADMINPASSWD-}/g" </nxt-boot/conf/nxt-${NXTNET}.properties >/ardor/conf/nxt.properties

	# If we did all of that, we dump a file that will signal next time that we
	# should not run the init-script again
	echo $NRSVersion >/ardor/conf/version
else
	echo -e " init-nxt.sh: Init already done, skipping init."
fi

./run.sh
