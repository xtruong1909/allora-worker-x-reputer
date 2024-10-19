#!/bin/bash

set -e  # Dừng script nếu có lỗi

# Biến để đặt tên image và container
IMAGE_NAME="allora-train-model:1.0.0"
CONTAINER_NAME="allora-train-model"

# Build Docker image
echo "Building Docker image..."
docker build -f Dockerfile_train_models -t $IMAGE_NAME .

# Kiểm tra nếu container đang chạy, dừng và xóa nó
if [ "$(docker ps -q -f name=$CONTAINER_NAME)" ]; then
    echo "Stopping existing container..."
    docker stop $CONTAINER_NAME
    docker rm $CONTAINER_NAME
fi

# Chạy container mới với GPU và volume gắn kèm
echo "Starting Docker container with GPU..."
docker run --gpus all \
  -v $(pwd)/models:/app/models \
  -v $(pwd)/source-data:/app/data \
  -e DATABASE_PATH=/app/data/prices.db \
  --name $CONTAINER_NAME \
  -d $IMAGE_NAME

echo "Container $CONTAINER_NAME started successfully."

# Theo dõi logs của container
echo "Attaching to container logs..."
docker logs -f $CONTAINER_NAME
