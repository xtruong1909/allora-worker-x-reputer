#!/bin/bash

set -e  # Dừng script nếu có lỗi

echo "Initializing Allora node..."

# Xóa thư mục dữ liệu cũ nếu tồn tại
if [ -d "$HOME/.allorad" ]; then
    echo "Removing old Allora data..."
    rm -rf "$HOME/.allorad"
fi

# Kiểm tra xem allorad có được cài đặt không
ALLORAD_BIN=$(which allorad || true)
if [ -z "$ALLORAD_BIN" ]; then
    echo "Error: 'allorad' binary not found. Please install it and try again."
    exit 1
fi

echo "Allorad binary found at: $ALLORAD_BIN"

# Cấu hình allorad
$ALLORAD_BIN config set client chain-id demo
$ALLORAD_BIN config set client keyring-backend test

# Thêm key cho các tài khoản
echo "Creating keys for Alice and Bob..."
$ALLORAD_BIN keys add alice --keyring-backend test || true
$ALLORAD_BIN keys add bob --keyring-backend test || true

# Khởi tạo cấu hình chuỗi khối
echo "Initializing Allora blockchain..."
$ALLORAD_BIN init test --chain-id demo --default-denom uallo

# Thêm tài khoản vào genesis
echo "Adding genesis accounts..."
$ALLORAD_BIN genesis add-genesis-account alice 10000000allo --keyring-backend test
$ALLORAD_BIN genesis add-genesis-account bob 10000000allo --keyring-backend test

# Tạo validator mặc định từ tài khoản Alice
echo "Creating default validator..."
$ALLORAD_BIN genesis gentx alice 1000allo --chain-id demo

# Thu thập tất cả các tệp gentx vào genesis
echo "Collecting gentxs..."
$ALLORAD_BIN genesis collect-gentxs

echo "Allora node initialized successfully!"
