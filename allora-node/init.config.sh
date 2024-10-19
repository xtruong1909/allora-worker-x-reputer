#!/bin/bash

set -e  # Dừng script khi có lỗi

show_help() {
    echo "Usage: $0 [--i] <node_name> <mnemonic> <cgc_api_key>"
    echo
    echo "Options:"
    echo "  --i          Skip argument check and use default or no values"
    echo "  --help       Show this help message and exit"
    echo
    echo "Arguments:"
    echo "  <node_name>      Node name to set in config.json"
    echo "  <mnemonic>       Mnemonic to set in config.json"
    echo "  <cgc_api_key>    CGC API key to set in docker-compose.yaml"
}

# Hiển thị help và thoát nếu có tùy chọn --help
if [[ "$1" == "--help" ]]; then
    show_help
    exit 0
fi

# Kiểm tra xem config.json có tồn tại không
if [ ! -f config.json ]; then
    echo "Error: config.json file not found. Please provide one."
    exit 1
fi

# Tạo các thư mục cần thiết nếu chưa có
mkdir -p ./source-data ./worker-data

# Nếu người dùng không muốn nhập tham số
if [[ "$1" == "--i" ]]; then
    shift
else
    # Kiểm tra đủ 3 tham số, nếu không sẽ hiển thị help
    if [ $# -ne 3 ]; then
        show_help
        exit 1
    fi

    # Thay thế giá trị trong config.json và docker-compose.yaml
    sed -i "s/\"addressKeyName\": \".*\"/\"addressKeyName\": \"$1\"/" config.json
    sed -i "s/\"addressRestoreMnemonic\": \".*\"/\"addressRestoreMnemonic\": \"$2\"/" config.json
    sed -i "s/CGC_API_KEY=.*/CGC_API_KEY=$3/" docker-compose.yaml
fi

# Lấy nodeName từ config.json
nodeName=$(jq -r '.wallet.addressKeyName' config.json)
if [ -z "$nodeName" ]; then
    echo "No wallet name provided. Please set 'wallet.addressKeyName' in config.json."
    exit 1
fi

# Chuyển đổi nội dung JSON sang dạng chuỗi
json_content=$(jq -c . config.json)

# Lấy mnemonic từ config.json
mnemonic=$(jq -r '.wallet.addressRestoreMnemonic' config.json)

# Nếu mnemonic đã có, ghi vào env_file và thoát
if [ -n "$mnemonic" ]; then
    cat <<EOF > ./worker-data/env_file
ALLORA_OFFCHAIN_NODE_CONFIG_JSON='$json_content'
NAME=$nodeName
ENV_LOADED=true
EOF

    echo "Wallet mnemonic is already provided. Config loaded. Proceed to run docker-compose."
    exit 0
fi

# Nếu env_file chưa tồn tại, tạo mới
if [ ! -f ./worker-data/env_file ]; then
    echo "ENV_LOADED=false" > ./worker-data/env_file
fi

# Đọc trạng thái ENV_LOADED từ env_file
ENV_LOADED=$(grep '^ENV_LOADED=' ./worker-data/env_file | cut -d '=' -f 2)

# Nếu ENV_LOADED=false, khởi chạy Docker để cấu hình lại
if [ "$ENV_LOADED" = "false" ]; then
    docker run -it --entrypoint=bash \
        -v "$(pwd)/worker-data:/data" \
        -v "$(pwd)/scripts:/scripts" \
        -e NAME="${nodeName}" \
        -e ALLORA_OFFCHAIN_NODE_CONFIG_JSON="${json_content}" \
        alloranetwork/allora-chain:latest \
        -c "bash /scripts/init.sh"

    echo "config.json saved to ./worker-data/env_file"
else
    echo "Config is already loaded. To reload, set ENV_LOADED=false in ./worker-data/env_file."
fi
