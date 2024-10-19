#!/bin/bash

set -euo pipefail  # Dừng script nếu có lỗi và bắt lỗi trong các pipeline

# Định nghĩa màu sắc cho thông báo
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'  # No Color

# Các biến liên quan đến khôi phục snapshot
RESTORED_FLAG="${APP_HOME}/snapshot-restored.txt"
S3_BUCKET="allora-edgenet-backups"
LATEST_BACKUP_FILE_NAME="latest_backup.txt"
RCLONE_S3_NAME="allora_s3"  #! Thay thế bằng tên rclone S3 của bạn

LOGFILE="${APP_HOME}/restore.log"

echo -e "Please ensure ${GREEN}allorad, rclone, and zstd${NC} are installed and configured on your machine before running this script."
echo -e "For rclone, set ${GREEN}requester_pays: true${NC} in the advanced configuration."
read -p "$(echo -e ${YELLOW}'Press [Enter] to continue if dependencies are installed... '${NC})"

# Kiểm tra xem snapshot đã được khôi phục trước đó chưa
if [ ! -f "$RESTORED_FLAG" ]; then
    echo "Restoring the node from backup..."

    # Lấy tên tệp snapshot mới nhất từ S3
    LATES
