import os
import json

# Directory paths
base_dir = os.getcwd()
valid_vouchers_dir = os.path.join(base_dir, "ValidVouchers")
invalid_vouchers_dir = os.path.join(base_dir, "InvalidVouchers")

# Ensure output directories exist
os.makedirs(valid_vouchers_dir, exist_ok=True)
os.makedirs(invalid_vouchers_dir, exist_ok=True)

# Load ceremony vouchers from JSON file
with open("ceremony_vouchers.json", "r") as f:
    valid_vouchers = {voucher[2:] if voucher.startswith("0x") else voucher for voucher in json.load(f)}

# Process each .hex file in the current directory
for filename in os.listdir(base_dir):
    if filename.endswith(".hex"):
        file_path = os.path.join(base_dir, filename)

        # Read the last 114 characters of the .hex file
        with open(file_path, "r") as hex_file:
            hex_content = hex_file.read().strip()[-114:]

        # Check if the extracted content is a valid voucher
        if hex_content in valid_vouchers:
            os.rename(file_path, os.path.join(valid_vouchers_dir, filename))
            print(f"{filename} is valid and moved to ValidVouchers.")
        else:
            os.rename(file_path, os.path.join(invalid_vouchers_dir, filename))
            print(f"{filename} is invalid and moved to InvalidVouchers.")
