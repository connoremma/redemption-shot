#!/bin/bash

# Define functions for updating peerPrivKey and posting the coin address
updatePeerPrivKey() {
    local new_key="$1"
    echo "Updating peerPrivKey"
    sed -i "s/^\( *peerPrivKey: *\).*/\1$new_key/" /home/$USER/ceremonyclient/node/.config/config.yml

    if [[ $? -ne 0 ]]; then
        echo "Error: Failed to run sed command to update peerPrivKey"
        return 1
    fi

    # Check if the update was successful
    if ! grep $new_key /home/$USER/ceremonyclient/node/.config/config.yml; then
        echo "Warning: peerPrivKey not updated in the config file"
        return 1
    fi
}

postCoinAddress() {
    # echo "Posting to bridge-layer for account address $1..."
    curl -s -X POST https://bridge-layer.quilibrium.com/coins -H "Content-Type: application/json" -d "{\"address\": \"$1\"}"
}

# Specify number of vouchers to process, default to all if not provided
NUM_VOUCHERS=${1:-0}

# Set directories and initialize counters
VALID_VOUCHERS_DIR="$HOME/quil_vouchers/ValidVouchers"
BURNED_VOUCHERS_DIR="$HOME/quil_vouchers/BurnedVouchers"
MASTER_ACCOUNT="0x_YOUR_ACCOUNT_ADDRESS"
COUNTER=0

# Loop through each .hex file in ValidVouchers
for hex_file in "$VALID_VOUCHERS_DIR"/*.hex; do
    filename=$(basename "$hex_file")

    # Skip if already processed
    if [[ "$filename" == "quihex1.hex" || "$filename" == "quihex2.hex" || "$filename" == "quihex3.hex" ]]; then
        echo "Skipping processed voucher $filename."
        continue
    fi

    # Break if we've reached the specified number of vouchers
    if [[ "$NUM_VOUCHERS" -gt 0 && "$COUNTER" -ge "$NUM_VOUCHERS" ]]; then
        break
    fi

    echo "Processing voucher: $filename"

    # Step 1: Load the private key and update peerPrivKey
    private_key=$(cat "$hex_file")
    updatePeerPrivKey "$private_key" || { echo "Failed to update peerPrivKey for $filename"; exit 1; }

    # Verify the update
    updated_key=$(awk -F': ' '/^peerPrivKey:/ {print $2}' /home/$USER/ceremonyclient/node/.config/config.yml)
    echo "Updated $updated_key" || { echo "Failed to read updated peerPrivKey for $filename"; exit 1; }

    # Step 2: Run qclient to get the account address
    echo "Retrieving account address..."
    balance_output=$(./ceremonyclient/client/qclient-2.0.2.4-linux-amd64 token balance --config /home/$USER/ceremonyclient/node/.config) || { echo "Failed to retrieve account balance for $filename"; exit 1; }
    echo "Balance output: $balance_output"

    # Extract account address from the balance output
    account_address=$(echo "$balance_output" | awk '/Total balance:/ && $3 != "0.000000000000" {print $NF}' | tr -d ')') || { echo "Failed to extract account address for $filename"; exit 1; }


    # Check if we found an address with a non-zero balance
if [[ -z "$account_address" ]]; then
    echo "Error: No account with nonzero balance found."
    exit 1
else
    echo "Account address with nonzero balance: $account_address"
fi

    # Step 3: Run postCoinAddress to get coins with non-zero balance
    echo "Posting to bridge-layer for account address $account_address"
    post_response=$(postCoinAddress "$account_address")

    # Check if post_response contains valid JSON with "coins"
    if ! echo "$post_response" | jq -e .coins >/dev/null 2>&1; then
        echo "Warning: Unexpected response from postCoinAddress for $account_address. Skipping this voucher."
        echo "Response was: $post_response"
        continue
    fi

    # Extract coin addresses with balance of 50
    coin_addresses=$(echo "$post_response" | jq -r '.coins[] | select(.amount != "0.000000000000") | .address')
    echo "Coin addresses with balance 50: $coin_addresses"

    # Check if any coin addresses were found
    if [[ -z "$coin_addresses" ]]; then
        echo "Error: No coin addresses with nonzero balance found for this voucher."
        exit 1
    else
        echo "Coin addresses with nonzero balance: $coin_addresses"
    fi

    # Step 4: Transfer each eligible coin to the master account
    for coin_address in $coin_addresses; do
        echo "Transferring 50 coins from $coin_address to master account $MASTER_ACCOUNT..."
        ./ceremonyclient/client/qclient-2.0.2.4-linux-amd64 token transfer "$MASTER_ACCOUNT" "$coin_address" --config /home/$USER/ceremonyclient/node/.config || { echo "Failed to transfer coins from $coin_address"; exit 1; }
    done

    # Step 5: Move processed .hex file to BurnedVouchers
    echo "Moving $filename to BurnedVouchers."
    mv "$hex_file" "$BURNED_VOUCHERS_DIR" || { echo "Failed to move $filename to BurnedVouchers"; exit 1; }
    ((COUNTER++))

    echo "Completed processing of voucher: $filename"
done

echo "Script completed successfully. Processed $COUNTER vouchers."
