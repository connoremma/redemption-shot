# Quilibrium Voucher Redeemer
(✿◠‿◠) *Redeeming vouchers in bulk like a boss 💰*

* Instructions for setting up a node, configuring your environment, transferring and redeeming your vouchers are described below.
* This script is meant to be run directly on a Quilibrium node, your vouchers should also be copied over to your node.

This guide assumes you only want to redeem all of your vouchers and bridge them to ETH L1. If you're interested in actually running a node, look here: https://docs.quilibrium.one/start

# Setup:
### 💻 You will need to be able to open a terminal and copy paste commands in there.

## 1. Quilibrium Node
(_Skip this step if you already have a node_)

**Note:** You only need the node for the time you plan to redeem the vouchers. It is easy to setup and you have no obligation to keep it running once the redemption is complete. I have my node running on WSL (Windows subsystem for Linux) You can also do this on a macbook or any other Unix based system. 

### Node setup instructions:
Once you've found a machine to run the node on, **follow steps 4 & 5 using these instructions**: https://docs.quilibrium.one/start/node-auto-installer#id-4-install-the-node-software 
**You can skip setting up GRPC calls and setting up daily backups on step 5.**

## 2. Environment Setup
Once the node is installed and configured, install the **qclient**
```
curl -sSL https://raw.githubusercontent.com/lamat1111/QuilibriumScripts/main/tools/qclient_install.sh | bash
```

### Remove Invalid Vouchers
Switch into and sort your voucher directory: 
```
cd quil_vouchers && \
curl -O https://source.quilibrium.com/quilibrium/ceremonyclient/-/raw/main/node/execution/intrinsics/token/ceremony_vouchers.json && \
curl -O https://raw.githubusercontent.com/connoremma/redemption-shot/refs/heads/main/process_vouchers.py && \
python3 process_vouchers.py
```
Then go ahead and move your vouchers into the `quil_vouchers` folder.

🏠 Your home directory should look like this:
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

### Install the `jq` CLI tool:

**Ubuntu/WSL:**
```
sudo apt install jq
```
**MacOS:** 
```
brew install jq
```
🍺 If you don't have `brew`, get it here: https://brew.sh/

## 3. Get your master address
# ❗❗❗ Note down your peerPrivKey
Your node will be configured with an initial peer private key that will serve as the master address for receiving all of your QUIL tokens. 
**Note it down somewhere safe:**
```
grep 'peerPrivKey:' /home/$USER/ceremonyclient/node/.config/config.yml | sed 's/peerPrivKey: //'
```
### Obtain your public address that will be used to hold your coins in bulk
```
cd /home/$USER/ceremonyclient/node && ./../client/qclient-2.0.2.4-linux-amd64 token balance
```
You should see something like this. Copy the account address:
```
Signature check passed
gRPC not enabled, using light node
Total balance: 123.000000000000 QUIL (Account 0x111111111111111111111111111111111111111111)
```
Download the Voucher Consolidation script
```
curl -O https://raw.githubusercontent.com/connoremma/redemption-shot/refs/heads/main/consolidate_vouchers.sh
```
Open the script in a text editor and replace `0x_YOUR_ACCOUNT_ADDRESS` with the address you copied above. On most systems you can use `nano`.
```
nano consolidate_vouchers.sh
```
Make the script executable 
```
chmod +x consolidate_vouchers.sh
```
## 4. Run the Script
You can tell the script how many vouchers you want to process by adding a number in case you don't want to bridge them all at once. Remember that each voucher contains 50 QUIL, so you're moving multiples of 50 at a time. This command will run the script once for a single voucher:
```
./consolidate_vouchers 1
```
The script should output something like this for each voucher successfully processed:
```
Processing voucher: quilhex1.hex
Updating peerPrivKey to: 
  peerPrivKey:
Updated
Retrieving account address...
Balance output: Signature check passed
gRPC not enabled, using light node
Total balance: 0.000000000000 QUIL (Account 0x0000000000000000000000000000000000000000000000000000000000000000)
Total balance: 50.000000000000 QUIL (Account 0x0000000000000000000000000000000000000000000000000000000000000000)
Account address with nonzero balance: 0x0000000000000000000000000000000000000000000000000000000000000000
Posting to bridge-layer for account address 0x0000000000000000000000000000000000000000000000000000000000000000
Coin addresses with balance 50: 0x0000000000000000000000000000000000000000000000000000000000000000
Coin addresses with nonzero balance: 0x0000000000000000000000000000000000000000000000000000000000000000
Transferring 50 coins from 0x0000000000000000000000000000000000000000000000000000000000000000 to master account 0x0000000000000000000000000000000000000000000000000000000000000000...
Signature check passed
gRPC not enabled, using light node
Moving quilhex1.hex to BurnedVouchers.
Completed processing of voucher: quihex10.hex
Script completed successfully. Processed 1 vouchers.
```
