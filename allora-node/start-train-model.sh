#!/bin/bash

# Xây dựng Docker image cho việc training
# Sử dụng Dockerfile dành riêng cho việc huấn luyện mô hình

docker build -f Dockerfile_train_models -t allora-train-model:1.0.0 .

# Xóa container cũ nếu nó đã tồn tại để tránh xung đột
if [ $(docker ps -a -q -f name=allora-train-model) ]; then
  docker rm -f allora-train-model
fi

# Chạy Docker container để huấn luyện mô hình
# Sử dụng GPU, chia sẻ thư mục dữ liệu và mô hình với container
# Thiết lập biến môi trường DATABASE_PATH để trỏ đến cơ sở dữ liệu

docker run --gpus all -v $(pwd)/models:/app/models -v $(pwd)/source-data:/app/data -e DATABASE_PATH=/app/data/prices.db --name allora-train-model allora-train-model:1.0.0
