# Ardor blockchain's Docker image.

[![LICENSE: MIT](https://img.shields.io/github/license/rylorin/docker-ardor)](LICENSE)
[![GitHub contributors](https://img.shields.io/github/contributors/rylorin/docker-ardor)](https://github.com/rylorin/docker-ardor/graphs/contributors)

![Docker Automated build](https://img.shields.io/docker/automated/rylorin/ardor.svg) ![Docker Build Status](https://img.shields.io/docker/build/rylorin/ardor.svg) ![Docker Stars](https://img.shields.io/docker/stars/rylorin/ardor.svg) ![Docker Pulls](https://img.shields.io/docker/pulls/rylorin/ardor.svg)

## Note
This ReadMe file is for rylorin/ardor image.
If you are looking for rylorin/nxt readme please refer to https://github.com/rylorin/docker-ardor/blob/master/nxt/README.md.
This is probably related to a DockerHub issue.

## Intro
Ardor (http://www.ardorplatform.org) a blockchain-as-a-service platform that will allow people to utilize the blockchain technology of Nxt through the use of child chains.

## A word about this image
This is a Docker container to run Ardor on testnet or mainnet. This image is based on @chevdor work at https://github.com/chevdor/docker-nxt
You can find this image on the docker hub at: https://hub.docker.com/r/rylorin/ardor/

NOTE: In order to save a few MB a few things have been removed from the official NRS: .exe, changelog, ...

## Creating and running the container

### Configuration

You can remap the following volumes
/ardor/conf: can store your custom configuration files
/ardor/db: used to store database files. It's generally a good idea to map this volume to a persistent volume on your host otherwise you will loose your configuration and will have to download blockchain from scratch again when you will upgrade your image.

### Environment variables

NXTNET

Optionnal: test or main
Default value: test
By default, the container will run on testnet.

BLOCKCHAINDL

Optional: URL to a zip containing the blockchain to limit the amount of blocks your container will have to download.
Default: none

NOTE: If you leave this ENV variable empty, no blockchain will be pre-downloaded so it will take a while until your container fully catches up.

PLUGINS

URL to a text file. See format below:
<sha256> TAB http://192.168.0.1/plugin1.zip
<sha256> TAB http://192.168.0.1/plugin2.zip
<sha256> TAB http://192.168.0.1/plugin3.zip
EMPTY LINE

WARNING: Don´t omit the last empty line, if you do so, the last plugin will be skipped.

SCRIPT

Optional: URL to a script to run before NRS starts
Default: none

ADMINPASSWD

If provided, it will append the following line to the default config:
   nxt.adminPassword=<your pick>

MYADDRESS

If provided, it will append the following line to the default config:
   nxt.myAddress=<your pick>

MYPLATFORM

If provided, it will append the following line to the default config:
   nxt.myPlatform=<your pick>

### Testnet

To run the container, use the following command where:

   docker run -it -p 26876:26876 -e NXTNET=test --name mytestnet rylorin/ardor:latest

Here is what the options are:

* +-p ABCD:26876+ means you map the port ABCD (the on you will access) to the port 26876 of the container (26876 being the port for testnet).
* +--name whatever+ allows you to name your container. That makes things easier.
* +rylorin/ardor:latest+ is the name of the image

For more options or explanations about the options, please refer to the Docker documentation.

If you are curious about the image and would like to have a look at what it does first, you can issue the following command:

   docker run -it -p 26876:26876 --name mytestnet rylorin/ardor:latest bash

Notice the +bash+ at the end. Instead of starting off the start script, you will be dumped in a shell and can look around. When you do that, the blockchain is *not* downloaded and the NRS client does *not* start automagically.

### Mainnet

You may request the container to run on the mainnet by specifying the ENV variable +NXTNET=main+ as shown below:

	docker run -d --restart always -e NXTNET=main -p 27874:27874 -p 27876:27876 -v ~/ardor-db:/ardor/db rylorin/ardor:latest

## Blockchain bootstrapping

When you start the container, it will immediately connect and start downloading the blockchain if required. The testnet blockchain is much smaller than the mainnet blockchain (which is why the container default to testnet unless you specifically say you want to run on the mainnet). In any case, downloading the blockchain may take up to several hours. Be patient!

As we speak, the current size for the blockchain (zipped) is approximately:

- Mainnet: ??? MB
- Testnet: ??? MB

## Bootstraping the blockchain
Downloading the blockchain the first time may take quite some time... lots of time.
We can improve that!

You will need to create a zip file of the blockchain and make it available on your network. Your zip file can be named as you like. When unzipped, you must get a single folder called +nxt_main_db+ or +nxt_test_db+.

You make your zip available on a web server and note the address. You should have something similar to http://192.168.0.1/blockchain/mainnet-2015-07-12.zip You could of course put that on a Dropbox or similar service but the best is to keep it local within your network to ensure that the download will be as fast as it can.

WARNING: Downloading an unknown blockchain from an unknown/untrusted source is risky and not recommended at all.
Don´t do that except if you... just don´t do that!

You can tell the container to start off your zip file in case it has no blockchain (which is the case by default).

   docker run -it -p 26876:26876 -e BLOCKCHAINDL=http://192.168.0.1/blockchain/nxt_test_db.zip rylorin/ardor:latest

NOTE: The container will attempt to download the blockchain from your zip file only if the database folder is unavailable.
You can leave the ENV variable as it is even if you restart the container. The container will see that you already have a databse folder and skip the download. If you want redownload the blockchain from your zip, you will have to either delete the database folder manually in the container or simple kick off a brand new container.

## Update

The update from a version to the next is easy if you use a volume.

* First stop the first container (the old version)
* In your volume, delete the +conf/version+ file (no need to back it up, it is an empty file)
* Start the second with the new version, pointing to your volume

NOTE: Once you upgraded to a new version, you will not be able to revert to an older version. So make it easy for you to revert, I suggest you create a ZIP of your current database. See chapters above.

NOTE: When upgrading to a new version, the NRS client will only be available once the update is finished. If you cannot wait, you can watch the logs :)

## Creating and running via docker compose

I prefer to run the container using de docker compose file (and stack)

Docker compose example:

	version: '3.7'
	services:
	  ardor:
	    image: rylorin/ardor:latest
	    environment:
	      NXTNET: main
	      ADMINPASSWD: Manhattan
	      BLOCKCHAINDL: https://www.jelurida.com/Ardor-nxt_db.zip
	      MYADDRESS: ardor.123-group.com
	      MYPLATFORM: '@rylorin'
	    volumes:
	      - db:/ardor/db:rw
	    ports:
	      - 27874:27874/tcp
	      - 27876:27876/tcp
	    deploy:
	      placement:
	        constraints:
	          - node.platform.os == linux
	volumes:
	  db:
  
In this example, using a named volume will prevent the db to be wiped when you upgrade the container image.
I also prefer (but not shown in this example) not to expose the UI port and use a firewall, that will also bring https support.
