# EACjsEasyLauncher
Launch Ethereum Alarm Clock javascript client easily

## What does this script do?

The script will create a linux container and install all dependencies to run an Ethereum Alarm Clock client for executing other people transactions.

## What do I have to do?

You need to make sure you have at least docker installed on any Linux distribution or MacOS.

The other requirements will be installed automatically in a docker container by the script.

Simply run the script like this:

```
bash launch_eacjs.sh
```

This procedure will take some time.
After everything is correctly installed, you will be asked to type a password 3 times to create a new account.
Your password will be saved in plain text in the "password" file, and the ethereum address will be in the "account" file.
Parity configuration files will be placed under the parity-config directory.
By default the script will ask parity to connect to the "kovan" network.

First launch will take some time until parity is fully synchronized.

Once you see the eac.js console type ".start" to start looking for transactions to execute and that's all.

To check parity synchronization status, simply run the following command in another terminal:

```
docker logs $(docker ps -q -a --filter ancestor=eac| head -1)
```

Enjoy!
