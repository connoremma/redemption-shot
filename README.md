# Quilibrium Voucher Redeemer
(✿◠‿◠) *Redeeming vouchers in bulk like a boss 💰*

* Instructions for setting up a node, configuring your environment, transferring and redeeming your vouchers are described below.
* This script is meant to be run directly on a Quilibrium node, your vouchers should also be copied over to your node.

This guide assumes you only want to redeem all of your vouchers and bridge them to ETH L1. If you're interested in actually running a node, look here: https://docs.quilibrium.one/start

# Prerequisites:
### 💻 You will need to be able to open a terminal and copy paste commands in there.

### 1. Quilibrium Node
(_Skip this step if you already have a node_)

**Note:** You only need the node for the time you plan to redeem the vouchers. It is easy to setup and you have no obligation to keep it running once the redemption is complete. I have my node running on WSL (Windows subsystem for Linux) You can also do this on a macbook or any other Unix based system. 

### Node setup instructions:
Once you've found a machine to run the node on, **follow steps 4 & 5 using these instructions**: https://docs.quilibrium.one/start/node-auto-installer#id-4-install-the-node-software 
**You can skip setting up GRPC calls and setting up daily backups on step 5.**

### 2. Environment Setup
Make these folders in your home directory, then install a few CLI tools:
```
mkdir -p quil_vouchers/{ValidVouchers,InvalidVouchers,BurnedVouchers}
```
Your home directory should look like this:
```
/home
└───/quil_vouchers
│   │   voucher1.hex
│   │   voucher2.hex
│   │   ...
│   └───/ValidVouchers
│   └───/InvalidVouchers
│   └───/BurnedVouchers
└───/ceremonyclient
```

Then go ahead and move your vouchers into the `quil_vouchers` folder.

### Remove Invalid Vouchers
Switch into and sort your voucher directory: 
```
cd quil_vouchers && \
curl -O https://source.quilibrium.com/quilibrium/ceremonyclient/-/raw/main/node/execution/intrinsics/token/ceremony_vouchers.json && \
curl -O https://raw.githubusercontent.com/connoremma/redemption-shot/refs/heads/main/process_vouchers.py && \
python3 process_vouchers.py
```

### Install the `jq` CLI tool:

**Ubuntu/WSL:**
```
sudo apt install jq
```
**MacOS:** 
```
brew install jq
```
:bulb: If you don't have `brew`, get it here: https://brew.sh/

# ❗❗❗ Note down your peerPrivKey
Your node will be configured with an initial peer private key that will serve as the master address for receiving all of your QUIL tokens. 
**Note it down somewhere safe:**
```
grep 'peerPrivKey:' /home/$USER/ceremonyclient/node/.config/config.yml | sed 's/peerPrivKey: //'
```

