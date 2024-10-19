#!/bin/bash

set -ex  # Dừng script nếu có lỗi và hiển thị các lệnh đang thực hiện

# Các biến mặc định
NETWORK="${NETWORK:-allora-testnet-1}"  # Thay thế với tên mạng của bạn nếu cần
GENESIS_URL="https://raw.githubusercontent.com/allora-network/networks/main/${NETWORK}/genesis.json"
SEEDS_URL="https://raw.githubusercontent.com/allora-network/networks/main/${NETWORK}/seeds.txt"
PEERS_URL="https://raw.githubusercontent.com/allora-network/networks/main/${NETWORK}/peers.txt"

export APP_HOME="${APP_HOME:-./data}"
INIT_FLAG="${APP_HOME}/.initialized"
MONIKER="${MONIKER:-$(hostname)}"
KEYRING_BACKEND="test"  # Tùy chọn: Thay đổi backend nếu cần
GENESIS_FILE="${APP_HOME}/config/genesis.json"
DENOM="uallo"
RPC_PORT="${RPC_PORT:-26657}"

# Kiểm tra và hiển thị thông báo khởi tạo lại
echo "To re-initiate the node, remove the file: ${INIT_FLAG}"

if [ ! -f "$INIT_FLAG" ]; then
    # Xóa cấu hình cũ nếu có
    echo "Removing old configuration..."
    rm -rf "${APP_HOME}/config"

    # Tạo symlink cho cấu hình allorad
    echo "Creating symlink for allorad configuration..."
    ln -sf "${APP_HOME}" "${HOME}/.allorad"

    # Khởi tạo node với thông số chuỗi và denom
    echo "Initializing node..."
    allorad --home="${APP_HOME}" init "${MONIKER}" --chain-id="${NETWORK}" --default-denom="${DENOM}"

    # Tải tệp genesis
    echo "Downloading genesis file..."
    rm -f "$GENESIS_FILE"
    curl -Lo "$GENESIS_FILE" "$GENESIS_URL"

    # Tạo tài khoản và ghi thông tin ra file
    echo "Creating allorad account..."
    allorad --home="$APP_HOME" keys add "${MONIKER}" --keyring-backend="$KEYRING_BACKEND" > "${APP_HOME}/${MONIKER}.account_info" 2>&1

    # Cấu hình allorad client
    echo "Setting up allorad client..."
    allorad --home="${APP_HOME}" config set client chain-id "${NETWORK}"
    allorad --home="${APP_HOME}" config set client keyring-backend "${KEYRING_BACKEND}"

    # Giảm thiểu spam trong mempool
    echo "Configuring mempool to prevent spam attacks..."
    dasel put mempool.max_txs_bytes -t int -v 2097152 -f "${APP_HOME}/config/config.toml"
    dasel put mempool.size -t int -v 1000 -f "${APP_HOME}/config/config.toml"

    # Đánh dấu khởi tạo thành công
    touch "$INIT_FLAG"
fi

echo "Node is initialized."

# Lấy danh sách seeds và peers
SEEDS=$(curl -Ls "${SEEDS_URL}")
PEERS=$(curl -Ls "${PEERS_URL}")

# Cấu hình State Sync nếu có RPC được cung cấp
if [ -n "${STATE_SYNC_RPC1}" ]; then
    echo "Enabling state sync..."

    TRUST_HEIGHT=$(curl -s "${STATE_SYNC_RPC1}/block" | jq -r '.result.block.header.height')
    TRUST_HEIGHT=$(($TRUST_HEIGHT - ($TRUST_HEIGHT % 1000)))  # Làm tròn xuống block gần nhất

    TRUST_HASH=$(curl -s "${STATE_SYNC_RPC1}/block?height=${TRUST_HEIGHT}" | jq -r '.result.block_id.hash')

    echo "Trust height: ${TRUST_HEIGHT}, Trust hash: ${TRUST_HASH}"

    dasel put statesync.enable -t bool -v true -f "${APP_HOME}/config/config.toml"
    dasel put statesync.rpc_servers -t string -v "${STATE_SYNC_RPC1},${STATE_SYNC_RPC2}" -f "${APP_HOME}/config/config.toml"
    dasel put statesync.trust_height -t string -v "${TRUST_HEIGHT}" -f "${APP_HOME}/config/config.toml"
    dasel put statesync.trust_hash -t string -v "${TRUST_HASH}" -f "${APP_HOME}/config/config.toml"
fi

# Khởi động node validator
echo "Starting validator node..."
/cosmovisor/upgrades/v0.5.0/bin/allorad \
    --home="${APP_HOME}" \
    start \
    --moniker="${MONIKER}" \
    --minimum-gas-prices="0${DENOM}" \
    --rpc.laddr="tcp://0.0.0.0:${RPC_PORT}" \
    --p2p.seeds="${SEEDS}" \
    --p2p.persistent_peers="${PEERS}"
